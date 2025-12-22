import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:frontend/core/network/api_exceptions.dart';
import 'package:frontend/core/network/network_providers.dart';
import 'package:frontend/features/herd/data/models/cattle_statistics_dto.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../models/cattle_dto.dart';
import '../models/cattle_details_dto.dart';

final herdApiProvider = Provider<HerdApi>((ref) {
  final client = ref.read(dioClientProvider);
  return HerdApi(client.dio);
});

class HerdApi {
  final Dio _dio;

  HerdApi(this._dio);

  /// GET /api/cattle (пагинация: { content: [...] })
  Future<List<CattleDto>> getCattleList({
    int page = 0,
    int size = 10,
    String sortBy = 'createdAt',
    String sortDirection = 'DESC',
  }) async {
    try {
      final response = await _dio.get(
        '/cattle',
        queryParameters: {
          'page': page,
          'size': size,
          'sortBy': sortBy,
          'sortDirection': sortDirection,
        },
      );

      final data = response.data;

      List<dynamic> list;
      if (data is List) {
        list = data;
      } else if (data is Map<String, dynamic>) {
        if (data['content'] is List) {
          list = data['content'] as List<dynamic>;
        } else if (data['items'] is List) {
          list = data['items'] as List<dynamic>;
        } else {
          throw ApiException(
            'Неожиданный формат ответа при загрузке списка',
            response.statusCode,
          );
        }
      } else {
        throw ApiException(
          'Неожиданный тип данных при загрузке списка',
          response.statusCode,
        );
      }

      return list
          .map((e) => CattleDto.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ApiException(
        e.message ?? 'Ошибка при получении списка животных',
        e.response?.statusCode,
      );
    }
  }

  /// GET /api/cattle/{id}
  Future<CattleDto> getCattleById(int id) async {
    try {
      final response = await _dio.get('/cattle/$id');
      debugPrint('GET /cattle/$id response: ${response.data}');
      return CattleDto.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException(
        e.message ?? 'Ошибка при получении животного',
        e.response?.statusCode,
      );
    }
  }

  /// POST /api/cattle (важно: body может содержать details)
  Future<CattleDto> createCattle(CattleDto dto) async {
    try {
      final payload = dto.toJson();
      debugPrint('POST /cattle payload: $payload');

      final response = await _dio.post('/cattle', data: payload);

      debugPrint(
        'POST /cattle status=${response.statusCode} body=${response.data}',
      );
      return CattleDto.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      final data = e.response?.data;

      String msg = 'Не удалось создать животное';

      if (data is Map<String, dynamic>) {
        if (data['message'] is String) msg = data['message'] as String;
        if (data['error'] is String) msg = data['error'] as String;
      } else if (e.message != null) {
        msg = e.message!;
      }

      throw ApiException(msg, status);
    }
  }

  /// PUT /api/cattle/{id} (основная информация)
  Future<CattleDto> updateCattleMain({
    required int id,
    required CattleDto dto,
  }) async {
    try {
      final payload = dto.toJson();
      debugPrint('PUT /cattle/$id payload: $payload');

      final response = await _dio.put('/cattle/$id', data: payload);

      debugPrint(
        'PUT /cattle/$id status=${response.statusCode} body=${response.data}',
      );
      return CattleDto.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException(
        e.message ?? 'Ошибка при обновлении животного',
        e.response?.statusCode,
      );
    }
  }

  /// PATCH /api/details/{cattleId} (детали)
  Future<CattleDetailsDto> patchDetails({
    required int cattleId,
    required CattleDetailsDto details,
  }) async {
    try {
      final payload = details.toJson();
      debugPrint('PATCH /details/$cattleId payload: $payload');

      final response = await _dio.patch('/details/$cattleId', data: payload);

      debugPrint(
        'PATCH /details/$cattleId status=${response.statusCode} body=${response.data}',
      );
      return CattleDetailsDto.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      debugPrint(
        'PATCH /details/$cattleId DioException: ${e.response?.statusCode} ${e.response?.data}',
      );
      throw ApiException(
        e.message ?? 'Ошибка при обновлении деталей',
        e.response?.statusCode,
      );
    }
  }

  /// GET /api/details/{cattleId}
  Future<CattleDetailsDto> getDetails(int cattleId) async {
    try {
      final response = await _dio.get('/details/$cattleId');
      debugPrint('GET /details/$cattleId response: ${response.data}');
      return CattleDetailsDto.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException(
        e.message ?? 'Ошибка при получении деталей',
        e.response?.statusCode,
      );
    }
  }

  /// PATCH /api/details/{cattleId}
  Future<CattleDetailsDto> updateDetails({
    required int id,
    required CattleDetailsDto details,
  }) async {
    try {
      final json = details.toJson();
      debugPrint('PATCH /details/$id send: $json');

      // 1) новый endpoint
      try {
        final r = await _dio.patch('/details/$id', data: json);
        debugPrint('PATCH /details/$id status=${r.statusCode} data=${r.data}');
        return CattleDetailsDto.fromJson(r.data as Map<String, dynamic>);
      } on DioException catch (e) {
        if (e.response?.statusCode != 404) rethrow;
        // 2) fallback на старый, если бэк ещё где-то не обновился
        final r = await _dio.patch('/cattle/$id/details', data: json);
        return CattleDetailsDto.fromJson(r.data as Map<String, dynamic>);
      }
    } on DioException catch (e) {
      throw ApiException(
        e.message ?? 'Ошибка при обновлении деталей',
        e.response?.statusCode,
      );
    }
  }

  /// DELETE /api/cattle/{id}
  Future<void> deleteCattle(int id) async {
    try {
      await _dio.delete('/cattle/$id');
    } on DioException catch (e) {
      throw ApiException(
        e.message ?? 'Ошибка при удалении животного',
        e.response?.statusCode,
      );
    }
  }

  /// GET /api/cattle/statistics
  Future<CattleStatisticsDto> getCattleStatistics() async {
    try {
      final response = await _dio.get('/cattle/statistics');

      final data = response.data;
      if (data is! Map<String, dynamic>) {
        throw ApiException(
          'Неожиданный формат статистики',
          response.statusCode,
        );
      }

      return CattleStatisticsDto.fromJson(data);
    } on DioException catch (e) {
      throw ApiException(
        e.message ?? 'Ошибка при получении статистики',
        e.response?.statusCode,
      );
    }
  }
}
