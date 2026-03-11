import 'package:flutter/material.dart';
import 'package:frontend/core/icons/app_icons.dart';
import 'package:frontend/core/localization/l10n_extension.dart';
import 'package:frontend/core/network/api_exceptions.dart';
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

  Set<int> _initialSelectedIds = {};
  Map<int, int> _feedIdToUserRationId = {};

  bool _saving = false;
  bool _prefilled = false;

  final Map<String, bool> _expanded = {
    'COARSE': true,
    'JUICY': true,
    'CONCENTRATED': true,
    'VITAMINS_SUPPLEMENTS': true,
  };

  String _typeTitle(BuildContext context, String type) {
    final l10n = context.l10n;

    switch (type) {
      case 'COARSE':
        return l10n.rationsRoughage;
      case 'JUICY':
        return l10n.rationsSucculentFeed;
      case 'CONCENTRATED':
        return l10n.rationsConcentrates;
      case 'VITAMINS_SUPPLEMENTS':
        return l10n.rationsAdditives;
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

    for (final id in selectedIds) {
      _selected[id] = true;
    }

    _prefilled = true;
  }

  String _errorText(Object error) {
    if (error is ApiException) return error.message;
    return error.toString();
  }

  Future<void> _submit() async {
    final l10n = context.l10n;

    final currentSelectedIds = _selected.entries
        .where((e) => e.value == true)
        .map((e) => e.key)
        .toSet();

    if (currentSelectedIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.addUserRationsSelectAtLeastOne)),
      );
      return;
    }

    final toRemove = _initialSelectedIds.difference(currentSelectedIds);
    final toAdd = currentSelectedIds.difference(_initialSelectedIds);

    setState(() => _saving = true);

    try {
      if (toRemove.isNotEmpty) {
        final del = ref.read(deleteUserRationProvider);

        for (final feedId in toRemove) {
          final userRationId = _feedIdToUserRationId[feedId];
          if (userRationId == null) continue;
          await del(userRationId);
        }
      }

      if (toAdd.isNotEmpty) {
        final create = ref.read(createUserRationsProvider);

        final payload = <int, double>{};
        for (final id in toAdd) {
          payload[id] = 0;
        }

        await create(
          CreateUserRationsDto(rationQuantity: payload, isAvailable: true),
        );
      }

      if (!mounted) return;

      await showAppSuccessDialog(
        context,
        title: l10n.addUserRationsUpdatedSuccess,
        buttonText: l10n.addUserRationsGoToList,
        onButtonPressed: () => context.go('/rations'),
      );

      if (mounted) context.pop(true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.errorPrefix(_errorText(e)))));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final languageCode = Localizations.localeOf(context).languageCode;

    final catalogAsync = ref.watch(rationCatalogProvider);
    final userRationsAsync = ref.watch(userRationsProvider);

    return AppScaffold(
      bottomNavIndex: null,
      enableDrawer: false,
      showBell: false,
      showAppBar: true,
      farmName: l10n.farmName,
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
                Expanded(
                  child: Text(
                    l10n.addUserRationsTitle,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary3,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            Expanded(
              child: userRationsAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(
                  child: Text(
                    l10n.errorPrefix(_errorText(e)),
                    textAlign: TextAlign.center,
                  ),
                ),
                data: (userRations) {
                  _prefillFromUserRations(userRations);

                  return catalogAsync.when(
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (e, _) => Center(
                      child: Text(
                        l10n.errorPrefix(_errorText(e)),
                        textAlign: TextAlign.center,
                      ),
                    ),
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
                                              _typeTitle(context, type),
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
                                            x.localizedName(languageCode),
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
                        child: Text(
                          l10n.dialogCancel,
                          style: const TextStyle(
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
                            : Text(
                                l10n.save,
                                style: const TextStyle(
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
