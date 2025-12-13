import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:frontend/core/network/api_exceptions.dart';
import 'package:frontend/core/network/network_providers.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../models/cattle_event_dto.dart';
import '../models/create_cattle_event_dto.dart';
import '../models/paged_response_dto.dart';

final cattleEventsApiProvider = Provider<CattleEventsApi>((ref) {
  final client = ref.read(dioClientProvider);
  return CattleEventsApi(client.dio);
});

class CattleEventsApi {
  final Dio _dio;
  CattleEventsApi(this._dio);

  Future<PagedResponseDto<CattleEventDto>> getEvents({
    required int cattleId,
    int page = 0,
    int size = 20,
    List<String>? sort, // пример: ["eventDate,desc"]
  }) async {
    try {
      final response = await _dio.get(
        '/events/$cattleId',
        queryParameters: {
          'page': page,
          'size': size,
          if (sort != null) 'sort': sort,
        },
      );

      return PagedResponseDto.fromJson(
        response.data as Map<String, dynamic>,
        (json) => CattleEventDto.fromJson(json),
      );
    } on DioException catch (e) {
      throw ApiException(
        e.message ?? 'Ошибка при получении событий',
        e.response?.statusCode,
      );
    }
  }

  Future<CattleEventDto> createEvent({
    required int cattleId,
    required CreateCattleEventDto body,
  }) async {
    try {
      final payload = body.toJson();
      debugPrint('POST /events/$cattleId payload: $payload');

      final response = await _dio.post('/events/$cattleId', data: payload);
      return CattleEventDto.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException(
        e.message ?? 'Ошибка при создании события',
        e.response?.statusCode,
      );
    }
  }

  Future<void> deleteEvent({
    required int cattleId,
    required int eventId,
  }) async {
    try {
      await _dio.delete('/events/$cattleId/$eventId');
    } on DioException catch (e) {
      throw ApiException(
        e.message ?? 'Ошибка при удалении события',
        e.response?.statusCode,
      );
    }
  }

  Future<List<String>> getAvailableTypes({required int cattleId}) async {
    try {
      final response = await _dio.get('/events/$cattleId/available-types');
      final data = response.data;

      if (data is List) {
        return data.map((e) => e.toString()).toList();
      }

      throw ApiException(
        'Неожиданный формат available-types',
        response.statusCode,
      );
    } on DioException catch (e) {
      throw ApiException(
        e.message ?? 'Ошибка при получении доступных типов',
        e.response?.statusCode,
      );
    }
  }
}
