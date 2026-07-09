import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../data/datasources/pharmacy_api.dart';
import '../data/models/create_vet_drug_request_dto.dart';
import '../data/models/drug_action_dto.dart';
import '../data/models/drug_group_dto.dart';
import '../data/models/pharmacy_company_dto.dart';
import '../data/models/vet_drug_request_dto.dart';
import 'pharmacy_filter.dart';

/// Справочник действий для чипов-фильтров.
final pharmacyActionsProvider = FutureProvider<List<DrugActionDto>>((
  ref,
) async {
  final api = ref.read(pharmacyApiProvider);
  return api.getActions();
});

/// Справочник производителей для дропдауна-фильтра.
final pharmacyCompaniesProvider = FutureProvider<List<PharmacyCompanyDto>>((
  ref,
) async {
  final api = ref.read(pharmacyApiProvider);
  return api.getCompanies();
});

/// Текущие фильтры каталога (search обновляется с debounce из UI).
final pharmacyFilterProvider = StateProvider<PharmacyFilter>(
  (ref) => const PharmacyFilter(),
);

/// Каталог, завязанный на [pharmacyFilterProvider].
///
/// Источник переключается: если задан `companyId` — берём `/drugs` и группируем
/// на клиенте (у `/catalog` нет фильтра по производителю); иначе `/catalog`.
final pharmacyCatalogProvider = FutureProvider.autoDispose<List<DrugGroupDto>>((
  ref,
) async {
  final filter = ref.watch(pharmacyFilterProvider);
  final api = ref.read(pharmacyApiProvider);

  if (filter.companyId != null) {
    final drugs = await api.getDrugs(
      companyId: filter.companyId,
      actionId: filter.actionId,
      search: filter.search,
    );
    return DrugGroupDto.groupFromDrugs(drugs);
  }

  return api.getCatalog(actionId: filter.actionId, search: filter.search);
});

/// «Мои заявки».
final myPharmacyRequestsProvider =
    FutureProvider.autoDispose<List<VetDrugRequestDto>>((ref) async {
      final api = ref.read(pharmacyApiProvider);
      return api.getMyRequests();
    });

/// Создание заявки. После успеха инвалидирует список заявок.
final createPharmacyRequestProvider =
    Provider<Future<VetDrugRequestDto> Function(CreateVetDrugRequestDto)>((
      ref,
    ) {
      return (dto) async {
        final api = ref.read(pharmacyApiProvider);
        final created = await api.createRequest(dto);
        ref.invalidate(myPharmacyRequestsProvider);
        return created;
      };
    });
