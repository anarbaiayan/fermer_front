import 'package:frontend/features/rations/data/models/generate_ration_template_dto.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../data/datasources/rations_api.dart';
import '../data/models/ration_catalog_item_dto.dart';
import '../data/models/user_ration_dto.dart';
import '../data/models/create_user_rations_dto.dart';
import '../data/models/ration_template_dto.dart';

final rationCatalogProvider =
    FutureProvider.autoDispose<List<RationCatalogItemDto>>((ref) async {
      final api = ref.read(rationsApiProvider);
      return api.getCatalog();
    });

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
        ref.invalidate(rationTemplatesProvider);
      };
    });

final deleteUserRationProvider = Provider<Future<void> Function(int id)>((ref) {
  return (id) async {
    final api = ref.read(rationsApiProvider);
    await api.deleteUserRation(id);

    ref.invalidate(userRationsProvider);
    ref.invalidate(userAvailableRationsProvider);
    ref.invalidate(rationTemplatesProvider);
  };
});

final toggleUserRationProvider = Provider<Future<void> Function(int id)>((ref) {
  return (id) async {
    final api = ref.read(rationsApiProvider);
    await api.toggleUserRation(id);

    ref.invalidate(userRationsProvider);
    ref.invalidate(userAvailableRationsProvider);
    ref.invalidate(rationTemplatesProvider);
  };
});

final rationTemplatesProvider =
    FutureProvider.autoDispose<List<RationTemplateDto>>((ref) async {
      final api = ref.read(rationsApiProvider);
      return api.getTemplates();
    });

final rationTemplateByIdProvider =
    FutureProvider.family<RationTemplateDto, int>((ref, id) async {
      final api = ref.read(rationsApiProvider);
      return api.getTemplateById(id);
    });

final deleteRationTemplateProvider = Provider<Future<void> Function(int id)>((
  ref,
) {
  return (id) async {
    final api = ref.read(rationsApiProvider);
    await api.deleteTemplate(id);

    ref.invalidate(rationTemplatesProvider);
  };
});
final generateRationTemplateProvider =
    Provider<Future<RationTemplateDto> Function(GenerateRationTemplateDto dto)>(
      (ref) {
        return (dto) async {
          final api = ref.read(rationsApiProvider);
          final created = await api.generate(dto);

          // обновим список на основной странице
          ref.invalidate(rationTemplatesProvider);

          return created;
        };
      },
    );
