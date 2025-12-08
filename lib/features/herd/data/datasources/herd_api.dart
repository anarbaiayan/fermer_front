import 'package:dio/dio.dart';
import 'package:flutter/rendering.dart';
import 'package:frontend/core/network/api_exceptions.dart';
import 'package:frontend/core/network/network_providers.dart';
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

  // список животных (без details)
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
        // бэк отдал сразу массив
        list = data;
      } else if (data is Map<String, dynamic>) {
        // типичный ответ пагинации: { content: [...], ... }
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

  // получить одно животное с details
  Future<CattleDto> getCattleById(int id) async {
    try {
      final response = await _dio.get('/cattle/$id');
      return CattleDto.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException(
        e.message ?? 'Ошибка при получении животного',
        e.response?.statusCode,
      );
    }
  }

  Future<CattleDto> createCattle(CattleDto dto) async {
    try {
      final response = await _dio.post('/cattle', data: dto.toJson());
      return CattleDto.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      final status = e.response?.statusCode;
      final data = e.response?.data;

      String msg = 'Не удалось создать животное';

      if (data is Map<String, dynamic>) {
        if (data['message'] is String) {
          msg = data['message'] as String;
        } else if (data['error'] is String) {
          msg = data['error'] as String;
        }
      } else if (e.message != null) {
        msg = e.message!;
      }

      throw ApiException(msg, status);
    }
  }

  // обновить details (шаг 2 формы)
  Future<CattleDetailsDto> updateDetails({
    required int id,
    required CattleDetailsDto details,
  }) async {
    try {
      final json = details.toJson();
      debugPrint('PATCH /cattle/$id/details payload: $json');

      final response = await _dio.patch('/cattle/$id/details', data: json);

      debugPrint(
        'PATCH /cattle/$id/details status=${response.statusCode}, body=${response.data}',
      );

      return CattleDetailsDto.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      debugPrint('PATCH /cattle/$id/details DioException: ${e.response?.statusCode} ${e.response?.data}');
      throw ApiException(
        e.message ?? 'Ошибка при обновлении деталей',
        e.response?.statusCode,
      );
    }
  }

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
}
