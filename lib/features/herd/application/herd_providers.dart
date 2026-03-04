import 'package:flutter/foundation.dart';
import 'package:frontend/features/herd/data/models/cattle_statistics_dto.dart';
import 'package:frontend/features/herd/domain/entities/herd_filter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:frontend/features/herd/data/datasources/herd_api.dart';
import 'package:frontend/features/herd/data/models/cattle_mappers.dart';
import 'package:frontend/features/herd/domain/entities/cattle.dart';

/// Загружает список животных с бэка
final cattleListProvider = FutureProvider.autoDispose<List<Cattle>>((
  ref,
) async {
  final api = ref.read(herdApiProvider);

  final dtos = await api.getCattleList(
    page: 0,
    size: 200,
    sortBy: 'createdAt',
    sortDirection: 'DESC',
  );

  return dtos.map(cattleFromDto).toList();
});

final cattleDetailsProvider = FutureProvider.autoDispose
    .family<CattleDetails?, int>((ref, id) async {
      final api = ref.read(herdApiProvider);
      debugPrint('>>> cattleDetailsProvider called for id=$id');

      try {
        final dto = await api.getDetails(id);
        debugPrint(
          '>>> cattleDetailsProvider dto.upcomingEvents=${dto.upcomingEvents?.length}',
        );
        return cattleDetailsFromDto(dto);
      } catch (e) {
        debugPrint('>>> cattleDetailsProvider ERROR: $e');
        return null;
      }
    });

final cattleByIdProvider = FutureProvider.autoDispose.family<Cattle, int>((
  ref,
  id,
) async {
  final api = ref.read(herdApiProvider);
  final dto = await api.getCattleById(id);
  return cattleFromDto(dto);
});

final cattleStatisticsProvider =
    FutureProvider.autoDispose<CattleStatisticsDto>((ref) async {
      final api = ref.read(herdApiProvider);
      return api.getCattleStatistics();
    });

final herdSearchQueryProvider = StateProvider<String>((ref) => '');

/// Активный фильтр-тип (открытые / здоровые / etc.), выставляется из HerdScreen
final activeHerdFilterProvider = StateProvider<HerdFilterType?>((ref) => null);

/// Базовая фильтрация только по поисковому запросу (без типа)
final filteredCattleProvider = Provider.autoDispose<List<Cattle>>((ref) {
  final cattleAsync = ref.watch(cattleListProvider);
  final query = ref.watch(herdSearchQueryProvider).trim().toLowerCase();

  return cattleAsync.maybeWhen(
    data: (list) {
      if (query.isEmpty) return list;

      return list.where((c) {
        final name = c.name.toLowerCase();
        final tag = c.tagNumber.toString().toLowerCase();
        return name.contains(query) || tag.contains(query);
      }).toList();
    },
    orElse: () => [],
  );
});

bool _matchesFilterType({
  required HerdFilterType filter,
  required String? reproductiveState,
  required String? productionState,
  required String? healthStatus,
}) {
  switch (filter) {
    case HerdFilterType.lactating:
      return productionState == 'LACTATING';
    case HerdFilterType.dryPeriod:
      return reproductiveState == 'DRY_PERIOD' ||
          productionState == 'DRY' ||
          productionState == 'DRY_PHASE_1' ||
          productionState == 'DRY_PHASE_2';
    case HerdFilterType.open:
      return reproductiveState == 'OPEN';
    case HerdFilterType.inseminated:
      return reproductiveState == 'INSEMINATED';
    case HerdFilterType.healthy:
      return healthStatus == 'HEALTHY';
    case HerdFilterType.sick:
      return healthStatus == 'SICK';
  }
}

/// Итоговый провайдер — учитывает и поиск, и фильтр-тип.
/// Возвращает ({list, isLoadingDetails}) чтобы UI знал показывать ли спиннер.
final visibleCattleProvider =
    Provider.autoDispose<({List<Cattle> list, bool isLoadingDetails})>((ref) {
      final baseList = ref.watch(filteredCattleProvider);
      final filterType = ref.watch(activeHerdFilterProvider);

      if (filterType == null) {
        return (list: baseList, isLoadingDetails: false);
      }

      final filtered = <Cattle>[];
      var loadingCount = 0;

      for (final c in baseList) {
        final detailsAsync = ref.watch(cattleDetailsProvider(c.id));

        if (detailsAsync.isLoading) {
          loadingCount++;
          continue;
        }

        final details = detailsAsync.valueOrNull;

        if (_matchesFilterType(
          filter: filterType,
          reproductiveState: details?.reproductiveState,
          productionState: details?.productionState,
          healthStatus: details?.healthStatus,
        )) {
          filtered.add(c);
        }
      }

      return (list: filtered, isLoadingDetails: loadingCount > 0);
    });
