import 'package:dio/dio.dart';
import 'package:frontend/features/lactation/data/models/bulk_lactation_dto.dart';
import 'package:frontend/features/lactation/data/models/create_bulk_lactation_dto.dart';
import 'package:frontend/features/lactation/data/models/lactation_daily_summary_dto.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:frontend/core/network/network_providers.dart';
import '../../domain/entities/lactation_validation.dart';

import '../models/create_lactation_dto.dart';
import '../models/lactation_dto.dart';
import '../models/paged_response_dto.dart';

final lactationApiProvider = Provider<LactationApi>((ref) {
  final client = ref.read(dioClientProvider);
  return LactationApi(client.dio);
});

class LactationApi {
  final Dio _dio;
  LactationApi(this._dio);

  Future<LactationDto> create(CreateLactationDto dto) async {
    final r = await _dio.post('/lactations', data: dto.toJson());
    return LactationDto.fromJson(r.data as Map<String, dynamic>);
  }

  Future<LactationDto> getById(int id) async {
    final r = await _dio.get('/lactations/$id');
    return LactationDto.fromJson(r.data as Map<String, dynamic>);
  }

  Future<LactationDto> update({
    required int id,
    required Map<String, dynamic> body, // или сделаем UpdateLactationDto
  }) async {
    final r = await _dio.put('/lactations/$id', data: body);
    return LactationDto.fromJson(r.data as Map<String, dynamic>);
  }

  Future<void> delete(int id) async {
    await _dio.delete('/lactations/$id');
  }

  Future<PagedResponseDto<LactationDto>> getByCattle({
    required int cattleId,
    int page = 0,
    int size = 20,
    String sortBy = 'milkingDateTime',
    String sortDirection = 'DESC',
    CancelToken? cancelToken,
  }) async {
    final r = await _dio.get(
      '/lactations/cattle/$cattleId',
      cancelToken: cancelToken,
      queryParameters: {
        'page': page,
        'size': size,
        'sortBy': sortBy,
        'sortDirection': sortDirection,
      },
    );

    return PagedResponseDto.fromJson(
      r.data as Map<String, dynamic>,
      (m) => LactationDto.fromJson(m),
    );
  }

  Future<PagedResponseDto<BulkLactationDto>> getBulk({
    int page = 0,
    int size = 20,
    String? dateFrom, // yyyy-MM-dd
    String? dateTo, // yyyy-MM-dd
    CancelToken? cancelToken,
  }) async {
    final qp = <String, dynamic>{'page': page, 'size': size};
    if (dateFrom != null) qp['dateFrom'] = dateFrom;
    if (dateTo != null) qp['dateTo'] = dateTo;

    final r = await _dio.get(
      '/lactations/bulk',
      queryParameters: qp,
      cancelToken: cancelToken,
    );

    return PagedResponseDto.fromJson(
      r.data as Map<String, dynamic>,
      (m) => BulkLactationDto.fromJson(m),
    );
  }

  Future<BulkLactationDto> createBulk(CreateBulkLactationDto dto) async {
    final r = await _dio.post('/lactations/bulk', data: dto.toJson());
    return BulkLactationDto.fromJson(r.data as Map<String, dynamic>);
  }

  Future<LactationDailySummaryDto> getDailySummary({
    required String date,
    CancelToken? cancelToken,
  }) async {
    final r = await _dio.get(
      '/lactations/user/daily-summary',
      queryParameters: {'date': date},
      cancelToken: cancelToken,
    );
    final result = LactationDailySummaryDto.fromJson(
      r.data as Map<String, dynamic>,
    );
    if (result.date != date) throw LactationValidationError.incompleteData;
    return result;
  }

  Future<List<LactationDto>> getAllByCattle(
    int cattleId, {
    CancelToken? cancelToken,
  }) => _allPages(
    (page) => getByCattle(
      cattleId: cattleId,
      page: page,
      size: 100,
      cancelToken: cancelToken,
    ),
    (item) => item.id,
    cancelToken,
  );

  Future<List<BulkLactationDto>> getAllBulk({
    required String dateFrom,
    required String dateTo,
    CancelToken? cancelToken,
  }) => _allPages(
    (page) => getBulk(
      page: page,
      size: 100,
      dateFrom: dateFrom,
      dateTo: dateTo,
      cancelToken: cancelToken,
    ),
    (item) => item.id,
    cancelToken,
  );

  Future<List<T>> _allPages<T>(
    Future<PagedResponseDto<T>> Function(int) fetch,
    int? Function(T) idOf,
    CancelToken? cancelToken,
  ) async {
    final result = <T>[];
    final ids = <int>{};
    int? total;
    for (var number = 0; ; number++) {
      if (cancelToken?.isCancelled ?? false) throw cancelToken!.cancelError!;
      final page = await fetch(number);
      total ??= page.totalElements;
      if (page.number != number || page.totalElements != total) {
        throw LactationValidationError.incompleteData;
      }
      for (final item in page.content) {
        final id = idOf(item);
        if (id == null || !ids.add(id)) {
          throw LactationValidationError.incompleteData;
        }
        result.add(item);
      }
      if (number + 1 >= page.totalPages) {
        if (result.length != total) {
          throw LactationValidationError.incompleteData;
        }
        return result;
      }
      if (page.content.isEmpty) throw LactationValidationError.incompleteData;
    }
  }

  Future<List<LactationDailySummaryDto>> getDailySummaries({
    required DateTime from,
    required DateTime to,
    CancelToken? cancelToken,
  }) async {
    // UTC is used only for calendar arithmetic, never for changing a milking date.
    final start = DateTime.utc(from.year, from.month, from.day);
    final end = DateTime.utc(to.year, to.month, to.day);
    final days = end.difference(start).inDays + 1;
    if (days < 1 || days > maxLactationPeriodDays) {
      throw LactationValidationError.periodTooLong;
    }
    final result = <LactationDailySummaryDto>[];
    // Bound concurrency and stop scheduling requests when the filter is disposed.
    for (var offset = 0; offset < days; offset += 4) {
      if (cancelToken?.isCancelled ?? false) throw cancelToken!.cancelError!;
      final batch = <Future<LactationDailySummaryDto>>[];
      for (var i = offset; i < offset + 4 && i < days; i++) {
        final date = start
            .add(Duration(days: i))
            .toIso8601String()
            .substring(0, 10);
        batch.add(getDailySummary(date: date, cancelToken: cancelToken));
      }
      result.addAll(await Future.wait(batch));
    }
    return result;
  }
}
