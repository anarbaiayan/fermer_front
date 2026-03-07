import 'package:dio/dio.dart';
import 'package:frontend/core/network/api_exceptions.dart';
import 'package:frontend/core/network/network_providers.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../models/ration_catalog_item_dto.dart';
import '../models/user_ration_dto.dart';
import '../models/create_user_rations_dto.dart';
import '../models/cattle_ration_dto.dart';

final rationsApiProvider = Provider<RationsApi>((ref) {
  final dio = ref.read(dioClientProvider).dio;
  return RationsApi(dio);
});

class RationsApi {
  final Dio _dio;
  RationsApi(this._dio);

  Never _fail(DioException e, String fallback) {
    throw ApiException(
      extractApiMessage(e, fallback: fallback),
      e.response?.statusCode,
    );
  }

  // -------- user rations (запасы) --------

  Future<List<RationCatalogItemDto>> getCatalog({String? type}) async {
    try {
      final path = type == null
          ? '/user-rations/catalog'
          : '/user-rations/catalog/type/$type';

      final r = await _dio.get(path);
      final list = (r.data as List).cast<Map<String, dynamic>>();
      return list.map(RationCatalogItemDto.fromJson).toList();
    } on DioException catch (e) {
      _fail(e, 'Ошибка при получении каталога кормов');
    }
  }

  Future<List<UserRationDto>> getUserRations() async {
    try {
      final r = await _dio.get('/user-rations');
      final list = (r.data as List).cast<Map<String, dynamic>>();
      return list.map(UserRationDto.fromJson).toList();
    } on DioException catch (e) {
      _fail(e, 'Ошибка при получении запасов');
    }
  }

  Future<List<UserRationDto>> getAvailableUserRations() async {
    try {
      final r = await _dio.get('/user-rations/available');
      final list = (r.data as List).cast<Map<String, dynamic>>();
      return list.map(UserRationDto.fromJson).toList();
    } on DioException catch (e) {
      _fail(e, 'Ошибка при получении доступных запасов');
    }
  }

  Future<void> createUserRations(CreateUserRationsDto dto) async {
    try {
      await _dio.post(
        '/user-rations',
        data: dto.toJson(),
        options: Options(responseType: ResponseType.plain),
      );
    } on DioException catch (e) {
      _fail(e, 'Ошибка при создании запасов');
    }
  }

  Future<void> deleteUserRation(int id) async {
    try {
      await _dio.delete('/user-rations/$id');
    } on DioException catch (e) {
      _fail(e, 'Ошибка при удалении запаса');
    }
  }

  Future<UserRationDto> toggleUserRation(int id) async {
    try {
      final r = await _dio.patch('/user-rations/$id/toggle');
      return UserRationDto.fromJson(r.data as Map<String, dynamic>);
    } on DioException catch (e) {
      _fail(e, 'Ошибка при смене статуса запаса');
    }
  }

  // -------- cattle rations (НОВОЕ) --------

  // GET /api/cattle/rations
  Future<List<CattleRationDto>> getAllCattleRations() async {
    try {
      final r = await _dio.get('/cattle/rations');
      final list = (r.data as List).cast<Map<String, dynamic>>();
      return list.map(CattleRationDto.fromJson).toList();
    } on DioException catch (e) {
      _fail(e, 'Ошибка при получении рационов');
    }
  }

  // GET /api/cattle/{id}/ration
  // ВАЖНО: тут может происходить первичная генерация -> увеличиваем receiveTimeout
  Future<CattleRationDto> getCattleRation(int cattleId) async {
    try {
      final r = await _dio.get(
        '/cattle/$cattleId/ration',
        options: Options(receiveTimeout: const Duration(seconds: 90)),
      );
      return CattleRationDto.fromJson(r.data as Map<String, dynamic>);
    } on DioException catch (e) {
      _fail(e, 'Ошибка при получении рациона животного');
    }
  }

  // POST /api/cattle/{id}/ration/regenerate
  Future<CattleRationDto> regenerateCattleRation(int cattleId) async {
    try {
      final r = await _dio.post(
        '/cattle/$cattleId/ration/regenerate',
        options: Options(receiveTimeout: const Duration(seconds: 90)),
      );
      return CattleRationDto.fromJson(r.data as Map<String, dynamic>);
    } on DioException catch (e) {
      _fail(e, 'Ошибка при генерации рациона');
    }
  }

  // DELETE /api/cattle/rations/{rationId}
  Future<void> deleteCattleRation(int rationId) async {
    try {
      await _dio.delete('/cattle/rations/$rationId');
    } on DioException catch (e) {
      _fail(e, 'Ошибка при удалении рациона');
    }
  }
}