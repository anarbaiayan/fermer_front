import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/core/network/dio_client.dart';
import 'package:frontend/core/network/network_providers.dart';
import 'package:frontend/features/lactation/application/lactation_providers.dart';
import 'package:frontend/features/lactation/data/datasources/lactation_api.dart';
import 'package:frontend/features/lactation/data/models/bulk_lactation_dto.dart';
import 'package:frontend/features/lactation/data/models/create_bulk_lactation_dto.dart';
import 'package:frontend/features/lactation/data/models/create_lactation_dto.dart';
import 'package:frontend/features/lactation/data/models/lactation_daily_summary_dto.dart';
import 'package:frontend/features/lactation/data/models/lactation_period_summary_mapper.dart';
import 'package:frontend/features/lactation/data/models/paged_response_dto.dart';
import 'package:frontend/features/lactation/domain/entities/lactation_validation.dart';
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

    test('includes individual milk without double-counting bulk', () {
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
      expect(summary.totalMilkLiters, 330);
      expect(summary.reportedCowCount, 11);
      expect(summary.milkUsedForCalves, 30);
      expect(summary.unsuitableMilk, 10);
      expect(summary.hasInvalidMilkBalance, isFalse);
    });

    test('individual-only and empty periods are supported', () {
      final summary = lactationPeriodSummaryFromDtos([
        LactationDailySummaryDto.fromJson(_day('2026-09-12', bulk: 0)),
      ], []);
      expect(summary.totalMilkLiters, 30);
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

    for (final bulkMutation in [true, false]) {
      test(
        '${bulkMutation ? 'bulk' : 'individual'} create refreshes watched summaries',
        () async {
          var individual = 30.0;
          var bulk = 300.0;
          var bulkReads = 0;
          final api = apiWith((r) {
            if (r.method == 'POST') {
              if (bulkMutation) {
                bulk += 100;
                return {'id': 2, 'totalMilkLiters': 100};
              }
              individual += 10;
              return {
                'id': 3,
                'cattleId': 157,
                'milkingDate': '2026-09-12',
                'milkLiters': 10,
              };
            }
            if (r.path == '/lactations/bulk') {
              bulkReads++;
              return _page([
                {'id': 1, 'totalMilkLiters': bulk},
              ]);
            }
            return _day(
              r.queryParameters['date'] as String,
              individual: individual,
              bulk: bulk,
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
          container.listen(lactationDailySummaryProvider, (_, _) {});
          expect(
            (await container.read(
              lactationPeriodSummaryProvider.future,
            )).totalMilkLiters,
            330,
          );
          await container.read(lactationDailySummaryProvider.future);
          if (bulkMutation) {
            await container.read(createBulkLactationProvider)(_bulkRequest());
          } else {
            await container.read(createLactationProvider)(
              const CreateLactationDto(
                cattleId: 157,
                milkingDate: '2026-09-12',
                milkingDateTime: '2026-09-12T06:30:00',
                milkingTime: 'MORNING',
                milkLiters: 10,
              ),
            );
          }
          final expected = bulkMutation ? 430 : 340;
          expect(
            (await container.read(
              lactationPeriodSummaryProvider.future,
            )).totalMilkLiters,
            expected,
          );
          expect(
            (await container.read(
              lactationDailySummaryProvider.future,
            )).totalLiters,
            expected,
          );
          if (bulkMutation) expect(bulkReads, greaterThan(1));
        },
      );
    }
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
