import 'package:dio/dio.dart';
import 'package:frontend/core/network/api_exceptions.dart';
import 'package:frontend/core/network/network_providers.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../models/vet_consultant_dto.dart';

final vetConsultantsApiProvider = Provider<VetConsultantsApi>((ref) {
  final dio = ref.read(dioClientProvider).dio;
  return VetConsultantsApi(dio);
});

/// Пользовательские endpoint'ы ветконсультаций (`/api/vet-consultants`).
/// Админские (`/admin/*`) в этот модуль не входят.
class VetConsultantsApi {
  final Dio _dio;
  VetConsultantsApi(this._dio);

  Never _fail(DioException e, String fallback) {
    throw ApiException(
      extractApiMessage(e, fallback: fallback),
      e.response?.statusCode,
    );
  }

  Future<List<VetConsultantDto>> getConsultants() async {
    try {
      final r = await _dio.get('/vet-consultants');
      final list = (r.data as List).cast<Map<String, dynamic>>();
      return list.map(VetConsultantDto.fromJson).toList();
    } on DioException catch (e) {
      _fail(e, 'Ошибка при загрузке списка ветврачей');
    }
  }

  /// Фиксирует переход пользователя в WhatsApp (нужно только для статистики
  /// на стороне админа). Отвечает 204 без тела.
  Future<void> registerClick(int consultantId) async {
    try {
      await _dio.post(
        '/vet-consultants/$consultantId/click',
        options: Options(responseType: ResponseType.plain),
      );
    } on DioException catch (e) {
      _fail(e, 'Не удалось зафиксировать обращение');
    }
  }
}
