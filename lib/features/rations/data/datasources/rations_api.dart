import 'package:dio/dio.dart';
import 'package:frontend/core/network/network_providers.dart';
import 'package:frontend/core/network/api_exceptions.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../models/ration_catalog_item_dto.dart';
import '../models/user_ration_dto.dart';
import '../models/create_user_rations_dto.dart';
import '../models/ration_template_dto.dart';
import '../models/generate_ration_template_dto.dart';

final rationsApiProvider = Provider<RationsApi>((ref) {
  final dio = ref.read(dioClientProvider).dio;
  return RationsApi(dio);
});

class RationsApi {
  final Dio _dio;
  RationsApi(this._dio);

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
      throw ApiException(
        e.message ?? 'Ошибка при получении каталога кормов',
        e.response?.statusCode,
      );
    }
  }

  Future<List<UserRationDto>> getUserRations() async {
    try {
      final r = await _dio.get('/user-rations');
      final list = (r.data as List).cast<Map<String, dynamic>>();
      return list.map(UserRationDto.fromJson).toList();
    } on DioException catch (e) {
      throw ApiException(
        e.message ?? 'Ошибка при получении запасов',
        e.response?.statusCode,
      );
    }
  }

  Future<List<UserRationDto>> getAvailableUserRations() async {
    try {
      final r = await _dio.get('/user-rations/available');
      final list = (r.data as List).cast<Map<String, dynamic>>();
      return list.map(UserRationDto.fromJson).toList();
    } on DioException catch (e) {
      throw ApiException(
        e.message ?? 'Ошибка при получении доступных запасов',
        e.response?.statusCode,
      );
    }
  }

  Future<void> createUserRations(CreateUserRationsDto dto) async {
    try {
      await _dio.post(
        '/user-rations',
        data: dto.toJson(),
        options: Options(
          responseType: ResponseType.plain, // важно
        ),
      );
    } on DioException catch (e) {
      throw ApiException(
        e.message ?? 'Ошибка при создании запасов',
        e.response?.statusCode,
      );
    }
  }

  Future<void> deleteUserRation(int id) async {
    try {
      await _dio.delete('/user-rations/$id');
    } on DioException catch (e) {
      throw ApiException(
        e.message ?? 'Ошибка при удалении запаса',
        e.response?.statusCode,
      );
    }
  }

  Future<UserRationDto> toggleUserRation(int id) async {
    try {
      final r = await _dio.patch('/user-rations/$id/toggle');
      return UserRationDto.fromJson(r.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException(
        e.message ?? 'Ошибка при смене статуса запаса',
        e.response?.statusCode,
      );
    }
  }

  // -------- ration templates (рационы) --------

  Future<List<RationTemplateDto>> getTemplates() async {
    try {
      final r = await _dio.get('/ration-templates');
      final list = (r.data as List).cast<dynamic>();
      return list
          .map((e) => RationTemplateDto.fromJson(e as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      throw ApiException(
        e.message ?? 'Ошибка при получении рационов',
        e.response?.statusCode,
      );
    }
  }

  Future<RationTemplateDto> getTemplateById(int id) async {
    try {
      final r = await _dio.get('/ration-templates/$id');
      return RationTemplateDto.fromJson(r.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException(
        e.message ?? 'Ошибка при получении рациона',
        e.response?.statusCode,
      );
    }
  }

  Future<RationTemplateDto> generate(GenerateRationTemplateDto dto) async {
    try {
      final r = await _dio.post(
        '/ration-templates/generate',
        data: dto.toJson(),
      );
      return RationTemplateDto.fromJson(r.data as Map<String, dynamic>);
    } on DioException catch (e) {
      // тут как раз прилетает 400 "Insufficient Rations"
      final msg = (e.response?.data is Map<String, dynamic>)
          ? ((e.response?.data as Map<String, dynamic>)['message']
                    ?.toString() ??
                e.message ??
                'Ошибка генерации рациона')
          : (e.message ?? 'Ошибка генерации рациона');

      throw ApiException(msg, e.response?.statusCode);
    }
  }

  Future<void> deleteTemplate(int id) async {
    try {
      await _dio.delete('/ration-templates/$id');
    } on DioException catch (e) {
      throw ApiException(
        e.message ?? 'Ошибка при удалении рациона',
        e.response?.statusCode,
      );
    }
  }

  Future<RationTemplateDto> generateTemplate(
    GenerateRationTemplateDto dto,
  ) async {
    try {
      final r = await _dio.post(
        '/ration-templates/generate',
        data: dto.toJson(),
      );
      return RationTemplateDto.fromJson(r.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw ApiException(
        e.message ?? 'Ошибка при генерации рациона',
        e.response?.statusCode,
      );
    }
  }
}
