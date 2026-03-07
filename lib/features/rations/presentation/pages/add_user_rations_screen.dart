import 'package:flutter/material.dart';
import 'package:frontend/core/icons/app_icons.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/widgets/app_page.dart';
import 'package:frontend/core/widgets/app_scaffold.dart';
import 'package:frontend/core/widgets/app_success_dialog.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../application/rations_providers.dart';
import '../../data/models/create_user_rations_dto.dart';
import '../../data/models/ration_catalog_item_dto.dart';
import '../../data/models/user_ration_dto.dart';

class AddUserRationsScreen extends ConsumerStatefulWidget {
  const AddUserRationsScreen({super.key});

  @override
  ConsumerState<AddUserRationsScreen> createState() =>
      _AddUserRationsScreenState();
}

class _AddUserRationsScreenState extends ConsumerState<AddUserRationsScreen> {
  final Map<int, bool> _selected = {};

  // что было выбрано при открытии (нужно для diff)
  Set<int> _initialSelectedIds = {};
  // feedId -> userRationId (нужно для delete)
  Map<int, int> _feedIdToUserRationId = {};

  bool _saving = false;
  bool _prefilled = false;

  final Map<String, bool> _expanded = {
    'COARSE': true,
    'JUICY': true,
    'CONCENTRATED': true,
    'VITAMINS_SUPPLEMENTS': true,
  };

  String _typeTitle(String type) {
    switch (type) {
      case 'COARSE':
        return 'Грубые корма';
      case 'JUICY':
        return 'Сочные корма';
      case 'CONCENTRATED':
        return 'Концентрированные корма';
      case 'VITAMINS_SUPPLEMENTS':
        return 'Витамины, минералы и специальные добавки';
      default:
        return type;
    }
  }

  void _prefillFromUserRations(List<UserRationDto> userRations) {
    if (_prefilled) return;

    final selectedIds = <int>{};
    final map = <int, int>{};

    for (final ur in userRations) {
      selectedIds.add(ur.ration.id);
      map[ur.ration.id] = ur.id;
    }

    _initialSelectedIds = selectedIds;
    _feedIdToUserRationId = map;

    // проставляем чекбоксы
    for (final id in selectedIds) {
      _selected[id] = true;
    }

    _prefilled = true;
  }

  Future<void> _submit() async {
    // итоговый выбранный сет
    final currentSelectedIds = _selected.entries
        .where((e) => e.value == true)
        .map((e) => e.key)
        .toSet();

    if (currentSelectedIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Выберите хотя бы один корм')),
      );
      return;
    }

    // diff
    final toRemove = _initialSelectedIds.difference(currentSelectedIds);
    final toAdd = currentSelectedIds.difference(_initialSelectedIds);

    setState(() => _saving = true);

    try {
      // 1) удаляем снятые галочки
      if (toRemove.isNotEmpty) {
        final del = ref.read(deleteUserRationProvider);

        for (final feedId in toRemove) {
          final userRationId = _feedIdToUserRationId[feedId];
          if (userRationId == null) continue;
          await del(userRationId);
        }
      }

      // 2) добавляем новые (kg всегда 0)
      if (toAdd.isNotEmpty) {
        final create = ref.read(createUserRationsProvider);

        final payload = <int, double>{};
        for (final id in toAdd) {
          payload[id] = 0;
        }

        await create(
          CreateUserRationsDto(rationQuantity: payload, isAvailable: true),
        );
      } else {
        // если ничего не добавляли, но удаляли - провайдеры уже инвалидируются внутри deleteUserRationProvider
        // если ни add ни remove - просто закрываем
      }

      if (!mounted) return;

      await showAppSuccessDialog(
        context,
        title: 'Запасы успешно\nобновлены!',
        buttonText: 'Перейти к списку',
        onButtonPressed: () => context.go('/rations'),
      );

      if (mounted) context.pop(true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Ошибка: $e')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final catalogAsync = ref.watch(rationCatalogProvider);
    final userRationsAsync = ref.watch(userRationsProvider);

    return AppScaffold(
      bottomNavIndex: null,
      enableDrawer: false,
      showBell: false,
      showAppBar: true,
      farmName: 'Название фермы',
      body: AppPage(
        child: Column(
          children: [
            const SizedBox(height: 10),
            Row(
              children: [
                IconButton(
                  padding: EdgeInsets.zero,
                  icon: AppIcons.svg('arrow', size: 32),
                  onPressed: () => context.pop(false),
                ),
                const SizedBox(width: 6),
                const Text(
                  'Добавление вида корма',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary3,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            Expanded(
              child: userRationsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Ошибка: $e')),
                data: (userRations) {
                  // ✅ один раз предзаполняем чекбоксы
                  _prefillFromUserRations(userRations);

                  return catalogAsync.when(
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (e, _) => Center(child: Text('Ошибка: $e')),
                    data: (catalog) {
                      final Map<String, List<RationCatalogItemDto>> byType = {};
                      for (final x in catalog) {
                        byType.putIfAbsent(x.type, () => []).add(x);
                      }

                      return ListView(
                        padding: const EdgeInsets.only(bottom: 12),
                        children: [
                          ..._expanded.keys.map((type) {
                            final items = byType[type] ?? const [];
                            if (items.isEmpty) return const SizedBox.shrink();

                            final isOpen = _expanded[type] == true;

                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: AppColors.additional2,
                                ),
                              ),
                              child: Column(
                                children: [
                                  InkWell(
                                    onTap: () => setState(
                                      () => _expanded[type] = !isOpen,
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 12,
                                      ),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              _typeTitle(type),
                                              style: const TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500,
                                                color: AppColors.primary3,
                                              ),
                                            ),
                                          ),
                                          Icon(
                                            isOpen
                                                ? Icons.expand_less
                                                : Icons.expand_more,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  if (isOpen)
                                    const Divider(
                                      height: 1,
                                      color: AppColors.additional2,
                                    ),
                                  if (isOpen)
                                    ...items.map((x) {
                                      final checked = _selected[x.id] == true;

                                      return Container(
                                        color: checked
                                            ? const Color(0xFFF3F4F6)
                                            : Colors.white,
                                        child: ListTile(
                                          dense: true,
                                          leading: Checkbox(
                                            value: checked,
                                            activeColor: AppColors.primary1,
                                            onChanged: _saving
                                                ? null
                                                : (v) {
                                                    setState(() {
                                                      _selected[x.id] =
                                                          v == true;
                                                    });
                                                  },
                                          ),
                                          title: Text(
                                            x.name,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              color: AppColors.primary3,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      );
                                    }),
                                ],
                              ),
                            );
                          }),
                        ],
                      );
                    },
                  );
                },
              ),
            ),

            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          backgroundColor: const Color(0xFFE9ECEF),
                          side: BorderSide.none,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                        onPressed: _saving ? null : () => context.pop(false),
                        child: const Text(
                          'Отменить',
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 48,
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primary1,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                        onPressed: _saving ? null : _submit,
                        child: _saving
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                'Сохранить',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
