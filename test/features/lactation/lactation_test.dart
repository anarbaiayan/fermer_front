import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/core/network/dio_client.dart';
import 'package:frontend/core/network/network_providers.dart';
import 'package:frontend/features/lactation/application/control_milking_providers.dart';
import 'package:frontend/features/lactation/application/lactation_providers.dart';
import 'package:frontend/features/lactation/data/datasources/lactation_api.dart';
import 'package:frontend/features/lactation/data/models/bulk_lactation_dto.dart';
import 'package:frontend/features/lactation/data/models/create_bulk_lactation_dto.dart';
import 'package:frontend/features/lactation/data/models/create_lactation_batch_dto.dart';
import 'package:frontend/features/lactation/data/models/create_lactation_dto.dart';
import 'package:frontend/features/lactation/data/models/lactation_daily_summary_dto.dart';
import 'package:frontend/features/lactation/data/models/lactation_period_summary_mapper.dart';
import 'package:frontend/features/lactation/data/models/paged_response_dto.dart';
import 'package:frontend/features/lactation/domain/entities/control_milking.dart';
import 'package:frontend/features/lactation/domain/entities/lactation_validation.dart';
import 'package:frontend/features/lactation/domain/entities/milking_time.dart';
import 'package:frontend/features/lactation/presentation/lactation_error_message.dart';
import 'package:frontend/l10n/app_localizations_kk.dart';
import 'package:frontend/l10n/app_localizations_ru.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class _Adapter implements HttpClientAdapter {
  final FutureOr<Object?> Function(RequestOptions) handler;
  final requests = <RequestOptions>[];
  _Adapter(this.handler);

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    final data = await handler(options);
    if (data is ResponseBody) return data;
    return ResponseBody.fromString(
      jsonEncode(data),
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

Map<String, dynamic> _day(
  String date, {
  double individual = 30,
  double bulk = 300,
}) => {
  'date': date,
  'totalLiters': individual + bulk,
  'totalKg': (individual + bulk) * 1.03,
  'cowCount': 11,
  'individualLiters': individual,
  'bulkLiters': bulk,
  'bulkCowCount': 10,
  'commercialMilk': bulk - 40,
  'milkUsedForCalves': 30,
  'unsuitableMilk': 10,
  'details': <Object>[],
};

Map<String, dynamic> _page(
  List<Object> content, {
  int number = 0,
  int size = 100,
  int? total,
}) => {
  'content': content,
  'number': number,
  'size': size,
  'totalElements': total ?? content.length,
  'totalPages': ((total ?? content.length) / size).ceil(),
};

CreateBulkLactationDto _bulkRequest({
  double total = 100,
  double? calves,
  double? unsuitable,
}) => CreateBulkLactationDto(
  milkingDate: '2026-09-12',
  milkingDateTime: '2026-09-12T06:30:00',
  milkingTime: 'MORNING',
  numberOfCows: 10,
  totalMilkLiters: total,
  milkUsedForCalves: calves,
  unsuitableMilk: unsuitable,
);

void main() {
  late Dio dio;
  LactationApi apiWith(FutureOr<Object?> Function(RequestOptions) handler) {
    dio = Dio(BaseOptions(baseUrl: 'https://example.test/api'));
    dio.httpClientAdapter = _Adapter(handler);
    return LactationApi(dio);
  }

  group('Response models and totals', () {
    test('preserves all summary fields and nullable commercial milk', () {
      final json = _day('2026-09-12');
      final dto = LactationDailySummaryDto.fromJson(json);
      expect(dto.totalLiters, 330);
      expect(dto.individualLiters, 30);
      expect(dto.bulkLiters, 300);
      expect(dto.bulkCowCount, 10);
      expect(dto.commercialMilk, 260);
      expect(dto.milkUsedForCalves, 30);
      expect(dto.unsuitableMilk, 10);
      expect(
        LactationDailySummaryDto.fromJson({
          ...json,
          'commercialMilk': null,
        }).commercialMilk,
        isNull,
      );
      expect(
        LactationDailySummaryDto.fromJson({
          ...json,
          'commercialMilk': -10,
        }).commercialMilk,
        -10,
      );
    });

    test('farm statistics count bulk reports only', () {
      final summary = lactationPeriodSummaryFromDtos(
        [LactationDailySummaryDto.fromJson(_day('2026-09-12'))],
        [
          const BulkLactationDto(
            totalMilkLiters: 300,
            milkUsedForCalves: 30,
            unsuitableMilk: 10,
          ),
        ],
      );
      // В дне 30 л контрольных замеров и 300 л по ферме: в статистику
      // попадают только 300, иначе молоко учтётся дважды.
      expect(summary.totalMilkLiters, 300);
      expect(summary.reportedCowCount, 10);
      expect(summary.milkUsedForCalves, 30);
      expect(summary.unsuitableMilk, 10);
      expect(summary.hasInvalidMilkBalance, isFalse);
    });

    test('days with control milking but no farm report show zero', () {
      final summary = lactationPeriodSummaryFromDtos([
        LactationDailySummaryDto.fromJson(_day('2026-09-12', bulk: 0)),
      ], []);
      expect(summary.totalMilkLiters, 0);
      final empty = lactationPeriodSummaryFromDtos([], []);
      expect(empty.totalMilkLiters, 0);
      expect(empty.reportedCowCount, 0);
      expect(empty.hasInvalidMilkBalance, isFalse);
    });

    test('invalid records are not hidden by positive aggregate balance', () {
      final summary = lactationPeriodSummaryFromDtos([], [
        const BulkLactationDto(totalMilkLiters: 300, commercialMilk: 300),
        const BulkLactationDto(
          totalMilkLiters: 10,
          milkUsedForCalves: 10,
          unsuitableMilk: 10,
        ),
      ]);
      expect(summary.hasInvalidMilkBalance, isTrue);
      expect(summary.milkUsedForCalves, 10);
      expect(summary.unsuitableMilk, 10);
    });

    test('malformed summaries and pages are not treated as empty results', () {
      expect(
        () => LactationDailySummaryDto.fromJson({'date': '2026-09-12'}),
        throwsFormatException,
      );
      expect(
        () => PagedResponseDto.fromJson(
          <String, dynamic>{},
          BulkLactationDto.fromJson,
        ),
        throwsFormatException,
      );
      expect(
        () => PagedResponseDto.fromJson(
          _page(['invalid']),
          BulkLactationDto.fromJson,
        ),
        throwsFormatException,
      );
    });
  });

  group('Validation', () {
    test('accepts decimal comma, zero optional amounts and exact balance', () {
      expect(parseMilkAmount(' 10,5 '), 10.5);
      expect(
        _bulkRequest(calves: 40, unsuitable: 60).toJson()['milkUsedForCalves'],
        40,
      );
      expect(_bulkRequest(calves: 0).toJson()['milkUsedForCalves'], 0);
      expect(_bulkRequest().toJson().containsKey('milkUsedForCalves'), isFalse);
      expect(
        _bulkRequest(total: 0.3, calves: 0.1, unsuitable: 0.2).toJson(),
        isNotEmpty,
      );
    });

    test('rejects invalid values before serialization or network access', () {
      for (final value in [0.0, -1.0, double.nan, double.infinity]) {
        expect(
          () => _bulkRequest(total: value).toJson(),
          throwsA(LactationValidationError.milk),
        );
        final dto = CreateLactationDto(
          cattleId: 1,
          milkingDate: '2026-09-12',
          milkingDateTime: '2026-09-12T06:30:00',
          milkingTime: 'MORNING',
          milkLiters: value,
        );
        expect(dto.toJson, throwsA(LactationValidationError.milk));
      }
      expect(
        () => _bulkRequest(calves: -1).toJson(),
        throwsA(LactationValidationError.calvesMilk),
      );
      expect(
        () => _bulkRequest(unsuitable: double.nan).toJson(),
        throwsA(LactationValidationError.unsuitableMilk),
      );
      expect(
        () => _bulkRequest(calves: 80, unsuitable: 50).toJson(),
        throwsA(LactationValidationError.milkBalance),
      );
    });
  });

  group('Read API', () {
    tearDown(() => dio.close(force: true));

    test('loads every bulk page, including records beyond 200', () async {
      final api = apiWith((request) {
        final page = request.queryParameters['page'] as int;
        final start = page * 100;
        return _page(
          List.generate(page < 2 ? 100 : 5, (i) => {'id': start + i + 1}),
          number: page,
          total: 205,
        );
      });
      final records = await api.getAllBulk(
        dateFrom: '2026-01-01',
        dateTo: '2026-09-12',
      );
      expect(records.length, 205);
      expect(records.last.id, 205);
      final requests = (dio.httpClientAdapter as _Adapter).requests;
      expect(requests.length, 3);
      expect(
        requests.every((r) => r.queryParameters['dateFrom'] == '2026-01-01'),
        isTrue,
      );
    });

    test('loads individual pages using actual server pagination', () async {
      final api = apiWith((request) {
        final page = request.queryParameters['page'] as int;
        return _page(
          [
            {'id': page + 1},
          ],
          number: page,
          size: 1,
          total: 3,
        );
      });
      expect((await api.getAllByCattle(157)).map((r) => r.id), [1, 2, 3]);
    });

    test(
      'rejects repeated or incomplete pages instead of partial totals',
      () async {
        final api = apiWith(
          (request) => _page(
            [
              {'id': 1},
            ],
            number: request.queryParameters['page'] as int,
            size: 1,
            total: 2,
          ),
        );
        await expectLater(
          api.getAllByCattle(157),
          throwsA(LactationValidationError.incompleteData),
        );
      },
    );

    test(
      'loads an inclusive date range with at most four requests in flight',
      () async {
        var active = 0;
        var peak = 0;
        final dates = <String>[];
        final api = apiWith((request) async {
          active++;
          if (active > peak) peak = active;
          final date = request.queryParameters['date'] as String;
          dates.add(date);
          await Future<void>.delayed(const Duration(milliseconds: 2));
          active--;
          return _day(date);
        });
        final days = await api.getDailySummaries(
          from: DateTime(2026, 3, 28),
          to: DateTime(2026, 4, 3),
        );
        expect(days.length, 7);
        expect(dates.first, '2026-03-28');
        expect(dates.last, '2026-04-03');
        expect(peak, lessThanOrEqualTo(4));
        expect(days.fold<double>(0, (sum, day) => sum + day.totalLiters), 2310);
      },
    );

    test(
      'invalid periods and cancelled loads do not schedule requests',
      () async {
        final api = apiWith(
          (request) => _day(request.queryParameters['date'] as String),
        );
        await expectLater(
          api.getDailySummaries(from: DateTime(2020), to: DateTime(2026)),
          throwsA(LactationValidationError.periodTooLong),
        );
        final token = CancelToken()..cancel();
        await expectLater(
          api.getDailySummaries(
            from: DateTime(2026, 9, 12),
            to: DateTime(2026, 9, 12),
            cancelToken: token,
          ),
          throwsA(isA<DioException>()),
        );
        expect((dio.httpClientAdapter as _Adapter).requests, isEmpty);
      },
    );

    test(
      'a failed day prevents a partial period from being displayed',
      () async {
        final api = apiWith((request) {
          final date = request.queryParameters['date'] as String;
          if (date == '2026-09-10') return ResponseBody.fromString('{}', 500);
          return _day(date);
        });
        await expectLater(
          api.getDailySummaries(
            from: DateTime(2026, 9, 7),
            to: DateTime(2026, 9, 13),
          ),
          throwsA(isA<DioException>()),
        );
      },
    );

    test('does not send invalid bulk data', () async {
      final api = apiWith((request) => <String, dynamic>{});
      await expectLater(
        api.createBulk(_bulkRequest(calves: 150)),
        throwsA(LactationValidationError.milkBalance),
      );
      expect((dio.httpClientAdapter as _Adapter).requests, isEmpty);
    });

    test('bulk create refreshes watched summaries', () async {
      var bulk = 300.0;
      var bulkReads = 0;
      final api = apiWith((r) {
        if (r.method == 'POST') {
          bulk += 100;
          return {'id': 2, 'totalMilkLiters': 100};
        }
        if (r.path == '/lactations/bulk') {
          bulkReads++;
          return _page([
            {'id': 1, 'totalMilkLiters': bulk},
          ]);
        }
        return _day(r.queryParameters['date'] as String, bulk: bulk);
      });
      final container = ProviderContainer(
        overrides: [
          lactationApiProvider.overrideWithValue(api),
          dioClientProvider.overrideWithValue(DioClient(dio: dio)),
        ],
      );
      addTearDown(container.dispose);
      final range = container.read(lactationRangeProvider.notifier);
      range.setFrom(DateTime(2026, 9, 12));
      range.setTo(DateTime(2026, 9, 12));
      range.setFrom(DateTime(2026, 9, 12));
      container.listen(lactationPeriodSummaryProvider, (_, _) {});
      container.listen(lactationDailySummaryProvider, (_, _) {});
      expect(
        (await container.read(
          lactationPeriodSummaryProvider.future,
        )).totalMilkLiters,
        300,
      );
      await container.read(lactationDailySummaryProvider.future);
      await container.read(createBulkLactationProvider)(_bulkRequest());
      expect(
        (await container.read(
          lactationPeriodSummaryProvider.future,
        )).totalMilkLiters,
        400,
      );
      expect(
        (await container.read(lactationDailySummaryProvider.future)).bulkLiters,
        400,
      );
      expect(bulkReads, greaterThan(1));
    });

    test('control milking never changes farm statistics', () async {
      var individual = 30.0;
      final api = apiWith((r) {
        if (r.method == 'POST') {
          individual += 10;
          return [
            {
              'id': 3,
              'cattleId': 157,
              'milkingDate': '2026-09-12',
              'milkLiters': 10,
            },
          ];
        }
        if (r.path == '/lactations/bulk') {
          return _page([
            {'id': 1, 'totalMilkLiters': 300},
          ]);
        }
        return _day(
          r.queryParameters['date'] as String,
          individual: individual,
        );
      });
      final container = ProviderContainer(
        overrides: [
          lactationApiProvider.overrideWithValue(api),
          dioClientProvider.overrideWithValue(DioClient(dio: dio)),
        ],
      );
      addTearDown(container.dispose);
      final range = container.read(lactationRangeProvider.notifier);
      range.setFrom(DateTime(2026, 9, 12));
      range.setTo(DateTime(2026, 9, 12));
      range.setFrom(DateTime(2026, 9, 12));
      container.listen(lactationPeriodSummaryProvider, (_, _) {});
      expect(
        (await container.read(
          lactationPeriodSummaryProvider.future,
        )).totalMilkLiters,
        300,
      );

      final result = await container.read(saveControlMilkingProvider)(
        date: DateTime(2026, 9, 12),
        milkingTime: MilkingTime.morning,
        entries: const [
          ControlMilkingEntry(
            cattleId: 157,
            cattleTagNumber: '00123',
            liters: 10,
          ),
        ],
        duplicateCattleIds: const {},
        duplicateAction: ControlMilkingDuplicateAction.update,
      );

      expect(result.savedCount, 1);
      expect(result.savedLiters, 10);
      expect(result.hasFailures, isFalse);
      // Контрольный замер учтён отдельно: статистика фермы остаётся прежней.
      expect(
        (await container.read(
          lactationPeriodSummaryProvider.future,
        )).totalMilkLiters,
        300,
      );
    });

    List<ControlMilkingEntry> entriesFor(int count, {int firstId = 1}) => [
      for (var i = 0; i < count; i++)
        ControlMilkingEntry(
          cattleId: firstId + i,
          cattleTagNumber: 'T${firstId + i}',
          liters: 10,
        ),
    ];

    test('new milkings are sent in one batch request', () async {
      final posts = <RequestOptions>[];
      final api = apiWith((r) {
        posts.add(r);
        return [
          for (final record in (r.data as Map)['records'] as List)
            {'id': (record as Map)['cattleId'], ...record},
        ];
      });
      final container = ProviderContainer(
        overrides: [
          lactationApiProvider.overrideWithValue(api),
          dioClientProvider.overrideWithValue(DioClient(dio: dio)),
        ],
      );
      addTearDown(container.dispose);

      final result = await container.read(saveControlMilkingProvider)(
        date: DateTime(2026, 9, 12),
        milkingTime: MilkingTime.evening,
        entries: entriesFor(37),
        duplicateCattleIds: const {},
        duplicateAction: ControlMilkingDuplicateAction.update,
      );

      // 37 коров — один запрос, а не 37.
      expect(posts, hasLength(1));
      expect(posts.single.path, '/lactations/batch');
      final records = (posts.single.data as Map)['records'] as List;
      expect(records, hasLength(37));
      expect(records.first, {
        'cattleId': 1,
        'milkingDate': '2026-09-12',
        'milkingDateTime': '2026-09-12T18:30:00',
        'milkingTime': 'EVENING',
        'milkLiters': 10.0,
      });
      expect(result.savedCount, 37);
      expect(result.savedLiters, 370);
      expect(result.hasFailures, isFalse);
    });

    test(
      'more than 100 cows are split and a rejected batch is retried whole',
      () async {
        final batchSizes = <int>[];
        final api = apiWith((r) {
          final records = (r.data as Map)['records'] as List;
          batchSizes.add(records.length);
          // Второй пакет сервер отклоняет целиком — как при атомарном откате.
          if (batchSizes.length == 2) {
            return ResponseBody.fromString(
              jsonEncode({'message': 'Cattle not found'}),
              500,
              headers: {
                Headers.contentTypeHeader: [Headers.jsonContentType],
              },
            );
          }
          return [
            for (final record in records)
              {'id': (record as Map)['cattleId'], ...record},
          ];
        });
        final container = ProviderContainer(
          overrides: [
            lactationApiProvider.overrideWithValue(api),
            dioClientProvider.overrideWithValue(DioClient(dio: dio)),
          ],
        );
        addTearDown(container.dispose);

        final result = await container.read(saveControlMilkingProvider)(
          date: DateTime(2026, 9, 12),
          milkingTime: MilkingTime.morning,
          entries: entriesFor(150),
          duplicateCattleIds: const {},
          duplicateAction: ControlMilkingDuplicateAction.update,
        );

        expect(batchSizes, [100, 50]);
        // Первый пакет на сервере — повторять его нельзя, иначе будут дубли.
        expect(result.savedCount, 100);
        expect(result.processedCattleIds, {
          for (var id = 1; id <= 100; id++) id,
        });
        // Второй откатился целиком: все 50 коров остаются для повтора.
        expect(result.failures.keys.toSet(), {
          for (var id = 101; id <= 150; id++) id,
        });
      },
    );

    test('duplicates are kept or updated, never duplicated', () async {
      final posts = <RequestOptions>[];
      final puts = <RequestOptions>[];
      final api = apiWith((r) {
        if (r.method == 'POST') {
          posts.add(r);
          return {'id': 9, 'cattleId': 157, 'milkLiters': 10};
        }
        if (r.method == 'PUT') {
          puts.add(r);
          return {'id': 7, 'cattleId': 157, 'milkLiters': 10};
        }
        return _page([
          {
            'id': 7,
            'cattleId': 157,
            'milkingDate': '2026-09-12',
            'milkingTime': 'MORNING',
            'milkLiters': 18.5,
          },
        ]);
      });
      final container = ProviderContainer(
        overrides: [
          lactationApiProvider.overrideWithValue(api),
          dioClientProvider.overrideWithValue(DioClient(dio: dio)),
        ],
      );
      addTearDown(container.dispose);
      const entries = [
        ControlMilkingEntry(
          cattleId: 157,
          cattleTagNumber: '00123',
          liters: 21,
        ),
      ];

      final kept = await container.read(saveControlMilkingProvider)(
        date: DateTime(2026, 9, 12),
        milkingTime: MilkingTime.morning,
        entries: entries,
        duplicateCattleIds: const {157},
        duplicateAction: ControlMilkingDuplicateAction.keepExisting,
      );
      expect(kept.keptExistingCount, 1);
      expect(kept.savedCount, 0);
      expect(posts, isEmpty);
      expect(puts, isEmpty);

      final updated = await container.read(saveControlMilkingProvider)(
        date: DateTime(2026, 9, 12),
        milkingTime: MilkingTime.morning,
        entries: entries,
        duplicateCattleIds: const {157},
        duplicateAction: ControlMilkingDuplicateAction.update,
      );
      expect(updated.savedCount, 1);
      // Обновляем существующую запись вместо создания второй на ту же дату.
      expect(posts, isEmpty);
      expect(puts.single.path, '/lactations/7');
      expect((puts.single.data as Map)['milkLiters'], 21);
    });

    test('a vanished duplicate is created in the same batch', () async {
      final posts = <RequestOptions>[];
      final api = apiWith((r) {
        if (r.method == 'POST') {
          posts.add(r);
          return [
            for (final record in (r.data as Map)['records'] as List)
              {'id': (record as Map)['cattleId'], ...record},
          ];
        }
        // Запись, найденная при проверке дубликатов, успела исчезнуть.
        return _page([]);
      });
      final container = ProviderContainer(
        overrides: [
          lactationApiProvider.overrideWithValue(api),
          dioClientProvider.overrideWithValue(DioClient(dio: dio)),
        ],
      );
      addTearDown(container.dispose);

      final result = await container.read(saveControlMilkingProvider)(
        date: DateTime(2026, 9, 12),
        milkingTime: MilkingTime.morning,
        entries: entriesFor(3),
        duplicateCattleIds: const {2},
        duplicateAction: ControlMilkingDuplicateAction.update,
      );

      expect(posts, hasLength(1));
      final ids = [
        for (final record in (posts.single.data as Map)['records'] as List)
          (record as Map)['cattleId'],
      ];
      expect(ids, unorderedEquals([1, 2, 3]));
      expect(result.savedCount, 3);
      expect(result.hasFailures, isFalse);
    });

    test('batch body rejects empty and oversized requests locally', () {
      CreateLactationDto record(int id) => CreateLactationDto(
        cattleId: id,
        milkingDate: '2026-09-12',
        milkingDateTime: '2026-09-12T06:30:00',
        milkingTime: 'MORNING',
        milkLiters: 10,
      );

      expect(
        () => const CreateLactationBatchDto(records: []).toJson(),
        throwsArgumentError,
      );
      expect(
        () => CreateLactationBatchDto(
          records: [for (var id = 1; id <= 101; id++) record(id)],
        ).toJson(),
        throwsArgumentError,
      );
      expect(
        (CreateLactationBatchDto(
                  records: [for (var id = 1; id <= 100; id++) record(id)],
                ).toJson()['records']
                as List)
            .length,
        100,
      );
      // Ноль не уходит в пакет: сервер отклонил бы его вместе с остальными.
      expect(
        () => CreateLactationBatchDto(
          records: [
            record(1),
            const CreateLactationDto(
              cattleId: 2,
              milkingDate: '2026-09-12',
              milkingDateTime: '2026-09-12T06:30:00',
              milkingTime: 'MORNING',
              milkLiters: 0,
            ),
          ],
        ).toJson(),
        throwsA(LactationValidationError.milk),
      );
    });
  });

  group('Localized errors', () {
    final ru = AppLocalizationsRu();
    final kk = AppLocalizationsKk();
    test('preserves backend messages without the Dio exception wrapper', () {
      final request = RequestOptions(path: '/lactations');
      final error = DioException(
        requestOptions: request,
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: request,
          statusCode: 400,
          data: {'message': 'Validation message'},
        ),
      );
      expect(lactationErrorMessage(error, ru), 'Validation message');
    });
    test('translates timeouts and validation, and hides HTML', () {
      final request = RequestOptions(path: '/lactations');
      final timeout = DioException(
        requestOptions: request,
        type: DioExceptionType.connectionTimeout,
      );
      expect(lactationErrorMessage(timeout, ru), ru.lactationTimeoutError);
      expect(lactationErrorMessage(timeout, kk), kk.lactationTimeoutError);
      expect(
        lactationErrorMessage(LactationValidationError.milkBalance, kk),
        kk.lactationMilkBalanceError,
      );
      final html = DioException(
        requestOptions: request,
        type: DioExceptionType.badResponse,
        response: Response(
          requestOptions: request,
          statusCode: 502,
          data: '<html>nginx</html>',
        ),
      );
      expect(lactationErrorMessage(html, ru), ru.lactationRequestError);
    });
  });
}
