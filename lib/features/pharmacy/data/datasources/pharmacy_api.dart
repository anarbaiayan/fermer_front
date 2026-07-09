import 'package:dio/dio.dart';
import 'package:frontend/core/network/api_exceptions.dart';
import 'package:frontend/core/network/network_providers.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../models/create_vet_drug_request_dto.dart';
import '../models/drug_action_dto.dart';
import '../models/drug_group_dto.dart';
import '../models/pharmacy_company_dto.dart';
import '../models/vet_drug_dto.dart';
import '../models/vet_drug_request_dto.dart';

final pharmacyApiProvider = Provider<PharmacyApi>((ref) {
  final dio = ref.read(dioClientProvider).dio;
  return PharmacyApi(dio);
});

/// Пользовательские endpoint'ы аптеки (`/api/pharmacy/*`). Админские
/// (`/admin/*`) в этот модуль не входят.
class PharmacyApi {
  final Dio _dio;
  PharmacyApi(this._dio);

  Never _fail(DioException e, String fallback) {
    throw ApiException(
      extractApiMessage(e, fallback: fallback),
      e.response?.statusCode,
    );
  }

  Future<List<DrugActionDto>> getActions() async {
    try {
      final r = await _dio.get('/pharmacy/actions');
      final list = (r.data as List).cast<Map<String, dynamic>>();
      return list.map(DrugActionDto.fromJson).toList();
    } on DioException catch (e) {
      _fail(e, 'Ошибка при загрузке списка действий');
    }
  }

  Future<List<PharmacyCompanyDto>> getCompanies() async {
    try {
      final r = await _dio.get('/pharmacy/companies');
      final list = (r.data as List).cast<Map<String, dynamic>>();
      return list.map(PharmacyCompanyDto.fromJson).toList();
    } on DioException catch (e) {
      _fail(e, 'Ошибка при загрузке производителей');
    }
  }

  /// Единый каталог со сравнением цен (группы по действующему веществу).
  /// Поддерживает только `actionId` и `search`.
  Future<List<DrugGroupDto>> getCatalog({int? actionId, String? search}) async {
    try {
      final r = await _dio.get(
        '/pharmacy/catalog',
        queryParameters: _query(actionId: actionId, search: search),
      );
      final list = (r.data as List).cast<Map<String, dynamic>>();
      return list.map(DrugGroupDto.fromJson).toList();
    } on DioException catch (e) {
      _fail(e, 'Ошибка при загрузке каталога');
    }
  }

  /// Плоский список препаратов. Поддерживает фильтр по производителю
  /// (`companyId`), которого нет у `/catalog`.
  Future<List<VetDrugDto>> getDrugs({
    int? companyId,
    int? actionId,
    String? search,
  }) async {
    try {
      final r = await _dio.get(
        '/pharmacy/drugs',
        queryParameters: _query(
          companyId: companyId,
          actionId: actionId,
          search: search,
        ),
      );
      final list = (r.data as List).cast<Map<String, dynamic>>();
      return list.map(VetDrugDto.fromJson).toList();
    } on DioException catch (e) {
      _fail(e, 'Ошибка при загрузке каталога');
    }
  }

  Future<VetDrugRequestDto> createRequest(CreateVetDrugRequestDto dto) async {
    try {
      final r = await _dio.post('/pharmacy/requests', data: dto.toJson());
      return VetDrugRequestDto.fromJson(r.data as Map<String, dynamic>);
    } on DioException catch (e) {
      _fail(e, 'Не удалось отправить заявку');
    }
  }

  Future<List<VetDrugRequestDto>> getMyRequests() async {
    try {
      final r = await _dio.get('/pharmacy/requests');
      final list = (r.data as List).cast<Map<String, dynamic>>();
      return list.map(VetDrugRequestDto.fromJson).toList();
    } on DioException catch (e) {
      _fail(e, 'Ошибка при загрузке заявок');
    }
  }

  Map<String, dynamic>? _query({
    int? companyId,
    int? actionId,
    String? search,
  }) {
    final trimmed = search?.trim();
    final map = <String, dynamic>{
      if (companyId != null) 'companyId': companyId,
      if (actionId != null) 'actionId': actionId,
      if (trimmed != null && trimmed.isNotEmpty) 'search': trimmed,
    };
    return map.isEmpty ? null : map;
  }
}
