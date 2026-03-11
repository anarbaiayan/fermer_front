import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../data/datasources/rations_api.dart';
import '../data/models/ration_catalog_item_dto.dart';
import '../data/models/user_ration_dto.dart';
import '../data/models/create_user_rations_dto.dart';
import '../data/models/create_custom_feed_dto.dart';
import '../data/models/cattle_ration_dto.dart';

// catalog
final rationCatalogProvider =
    FutureProvider.autoDispose<List<RationCatalogItemDto>>((ref) async {
      final api = ref.read(rationsApiProvider);
      return api.getCatalog();
    });

// user stocks
final userRationsProvider = FutureProvider.autoDispose<List<UserRationDto>>((
  ref,
) async {
  final api = ref.read(rationsApiProvider);
  return api.getUserRations();
});

final userAvailableRationsProvider =
    FutureProvider.autoDispose<List<UserRationDto>>((ref) async {
      final api = ref.read(rationsApiProvider);
      return api.getAvailableUserRations();
    });

final createUserRationsProvider =
    Provider<Future<void> Function(CreateUserRationsDto dto)>((ref) {
      return (dto) async {
        final api = ref.read(rationsApiProvider);
        await api.createUserRations(dto);

        ref.invalidate(userRationsProvider);
        ref.invalidate(userAvailableRationsProvider);

        // важно: после добавления кормов обновим список рационов тоже
        ref.invalidate(cattleRationsProvider);
      };
    });

final createCustomFeedProvider =
    Provider<Future<void> Function(CreateCustomFeedDto dto)>((ref) {
      return (dto) async {
        final api = ref.read(rationsApiProvider);
        await api.createCustomFeed(dto);

        ref.invalidate(rationCatalogProvider);
      };
    });

final deleteUserRationProvider = Provider<Future<void> Function(int id)>((ref) {
  return (id) async {
    final api = ref.read(rationsApiProvider);
    await api.deleteUserRation(id);

    ref.invalidate(userRationsProvider);
    ref.invalidate(userAvailableRationsProvider);
    ref.invalidate(cattleRationsProvider);
  };
});

final toggleUserRationProvider = Provider<Future<void> Function(int id)>((ref) {
  return (id) async {
    final api = ref.read(rationsApiProvider);
    await api.toggleUserRation(id);

    ref.invalidate(userRationsProvider);
    ref.invalidate(userAvailableRationsProvider);
    ref.invalidate(cattleRationsProvider);
  };
});

// ✅ ВСЕ РАЦИОНЫ
final cattleRationsProvider = FutureProvider.autoDispose<List<CattleRationDto>>(
  (ref) async {
    final api = ref.read(rationsApiProvider);
    return api.getAllCattleRations();
  },
);

// ✅ РАЦИОН КОНКРЕТНОГО ЖИВОТНОГО
final cattleRationByCattleProvider = FutureProvider.autoDispose
    .family<CattleRationDto, int>((ref, cattleId) async {
      final api = ref.read(rationsApiProvider);
      return api.getCattleRation(cattleId);
    });

// ✅ REGENERATE
final regenerateCattleRationProvider =
    Provider<Future<CattleRationDto> Function(int cattleId)>((ref) {
      return (cattleId) async {
        final api = ref.read(rationsApiProvider);
        final updated = await api.regenerateCattleRation(cattleId);
        ref.invalidate(cattleRationsProvider);
        ref.invalidate(cattleRationByCattleProvider(cattleId));
        return updated;
      };
    });

// ✅ DELETE ration
final deleteCattleRationProvider =
    Provider<Future<void> Function(int rationId)>((ref) {
      return (rationId) async {
        final api = ref.read(rationsApiProvider);
        await api.deleteCattleRation(rationId);
        ref.invalidate(cattleRationsProvider);
      };
    });
