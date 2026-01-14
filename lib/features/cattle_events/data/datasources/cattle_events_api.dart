import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:frontend/core/network/api_exceptions.dart';
import 'package:frontend/core/network/network_providers.dart';
import 'package:frontend/features/cattle_events/data/models/create_bulk_event_dto.dart';
import 'package:frontend/features/cattle_events/data/models/planned_event_dto.dart';
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

  Future<void> completeEvent({required int eventId}) async {
    try {
      await _dio.patch('/events/complete/$eventId');
    } on DioException catch (e) {
      throw ApiException(
        e.message ?? 'Ошибка при завершении события',
        e.response?.statusCode,
      );
    }
  }

  Future<void> changeEventStatus({
    required int eventId,
    required String status, // "PENDING" etc.
  }) async {
    try {
      await _dio.patch(
        '/events/change/$eventId',
        queryParameters: {'status': status},
      );
    } on DioException catch (e) {
      throw ApiException(
        e.message ?? 'Ошибка при смене статуса события',
        e.response?.statusCode,
      );
    }
  }

  Future<List<CattleEventDto>> createBulkEvents({
    required CreateBulkEventDto body,
  }) async {
    try {
      final payload = body.toJson();
      debugPrint('POST /events/bulk payload: $payload');

      final response = await _dio.post('/events/bulk', data: payload);

      final data = response.data;
      if (data is List) {
        return data
            .map((e) => CattleEventDto.fromJson(e as Map<String, dynamic>))
            .toList();
      }

      throw ApiException('Неожиданный формат ответа bulk', response.statusCode);
    } on DioException catch (e) {
      throw ApiException(
        e.message ?? 'Ошибка при создании массового события',
        e.response?.statusCode,
      );
    }
  }
}

final plannedEventsApiProvider = Provider<PlannedEventsApi>((ref) {
  final client = ref.read(dioClientProvider);
  return PlannedEventsApi(client.dio);
});

class PlannedEventsApi {
  final Dio _dio;
  PlannedEventsApi(this._dio);

  Future<PagedResponseDto<PlannedEventDto>> getPlannedEvents({
    required String status, // PENDING / COMPLETED (если будет)
    int page = 0,
    int size = 50,
    List<String>? sort,
  }) async {
    try {
      final response = await _dio.get(
        '/events/planned',
        queryParameters: {
          'status': status,
          'page': page,
          'size': size,
          if (sort != null) 'sort': sort,
        },
      );

      return PagedResponseDto.fromJson(
        response.data as Map<String, dynamic>,
        (json) => PlannedEventDto.fromJson(json),
      );
    } on DioException catch (e) {
      throw ApiException(
        e.message ?? 'Ошибка при получении планируемых событий',
        e.response?.statusCode,
      );
    }
  }
}
