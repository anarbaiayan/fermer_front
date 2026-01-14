import 'package:dio/dio.dart';
import 'package:frontend/features/lactation/data/models/bulk_lactation_dto.dart';
import 'package:frontend/features/lactation/data/models/create_bulk_lactation_dto.dart';
import 'package:frontend/features/lactation/data/models/lactation_daily_summary_dto.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:frontend/core/network/network_providers.dart';
import 'package:frontend/core/network/api_exceptions.dart';

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
    try {
      final r = await _dio.post('/lactations', data: dto.toJson());
      return LactationDto.fromJson(r.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException(
        e.message ?? 'Ошибка при создании надоя',
        e.response?.statusCode,
      );
    }
  }

  Future<LactationDto> getById(int id) async {
    try {
      final r = await _dio.get('/lactations/$id');
      return LactationDto.fromJson(r.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException(
        e.message ?? 'Ошибка при получении надоя',
        e.response?.statusCode,
      );
    }
  }

  Future<LactationDto> update({
    required int id,
    required Map<String, dynamic> body, // или сделаем UpdateLactationDto
  }) async {
    try {
      final r = await _dio.put('/lactations/$id', data: body);
      return LactationDto.fromJson(r.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException(
        e.message ?? 'Ошибка при обновлении надоя',
        e.response?.statusCode,
      );
    }
  }

  Future<void> delete(int id) async {
    try {
      await _dio.delete('/lactations/$id');
    } on DioException catch (e) {
      throw ApiException(
        e.message ?? 'Ошибка при удалении надоя',
        e.response?.statusCode,
      );
    }
  }

  Future<PagedResponseDto<LactationDto>> getByCattle({
    required int cattleId,
    int page = 0,
    int size = 20,
    String sortBy = 'milkingDateTime',
    String sortDirection = 'DESC',
  }) async {
    try {
      final r = await _dio.get(
        '/lactations/cattle/$cattleId',
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
    } on DioException catch (e) {
      throw ApiException(
        e.message ?? 'Ошибка при получении надоев коровы',
        e.response?.statusCode,
      );
    }
  }

  Future<PagedResponseDto<BulkLactationDto>> getBulk({
    int page = 0,
    int size = 20,
    String? dateFrom, // yyyy-MM-dd
    String? dateTo, // yyyy-MM-dd
  }) async {
    try {
      final qp = <String, dynamic>{'page': page, 'size': size};
      if (dateFrom != null) qp['dateFrom'] = dateFrom;
      if (dateTo != null) qp['dateTo'] = dateTo;

      final r = await _dio.get('/lactations/bulk', queryParameters: qp);

      return PagedResponseDto.fromJson(
        r.data as Map<String, dynamic>,
        (m) => BulkLactationDto.fromJson(m),
      );
    } on DioException catch (e) {
      throw ApiException(
        e.message ?? 'Ошибка при получении массовых надоев',
        e.response?.statusCode,
      );
    }
  }

  Future<BulkLactationDto> createBulk(CreateBulkLactationDto dto) async {
    try {
      final r = await _dio.post('/lactations/bulk', data: dto.toJson());
      return BulkLactationDto.fromJson(r.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException(
        e.message ?? 'Ошибка при создании массового надоя',
        e.response?.statusCode,
      );
    }
  }

  Future<LactationDailySummaryDto> getDailySummary({
    required String date,
  }) async {
    try {
      final r = await _dio.get(
        '/lactations/user/daily-summary',
        queryParameters: {'date': date},
      );
      return LactationDailySummaryDto.fromJson(r.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException(
        e.message ?? 'Ошибка при получении сводки по лактации',
        e.response?.statusCode,
      );
    }
  }
}
