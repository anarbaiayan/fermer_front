import 'dart:async';

import 'package:flutter/material.dart';
import 'package:frontend/core/icons/app_icons.dart';
import 'package:frontend/core/localization/l10n_extension.dart';
import 'package:frontend/core/network/api_exceptions.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/widgets/app_page.dart';
import 'package:frontend/core/widgets/app_scaffold.dart';
import 'package:frontend/features/pharmacy/application/pharmacy_providers.dart';
import 'package:frontend/features/pharmacy/data/models/drug_action_dto.dart';
import 'package:frontend/features/pharmacy/data/models/pharmacy_company_dto.dart';
import 'package:frontend/features/pharmacy/presentation/widgets/drug_group_card.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class PharmacyScreen extends ConsumerStatefulWidget {
  const PharmacyScreen({super.key});

  @override
  ConsumerState<PharmacyScreen> createState() => _PharmacyScreenState();
}

class _PharmacyScreenState extends ConsumerState<PharmacyScreen> {
  late final TextEditingController _searchController;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController(
      text: ref.read(pharmacyFilterProvider).search,
    );
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      ref
          .read(pharmacyFilterProvider.notifier)
          .update((f) => f.copyWith(search: value));
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final lang = Localizations.localeOf(context).languageCode;
    final filter = ref.watch(pharmacyFilterProvider);
    final actions = ref.watch(pharmacyActionsProvider).valueOrNull ?? const [];
    final companies =
        ref.watch(pharmacyCompaniesProvider).valueOrNull ?? const [];
    final catalogAsync = ref.watch(pharmacyCatalogProvider);

    final selectedCompany = filter.companyId == null
        ? null
        : companies.cast<PharmacyCompanyDto?>().firstWhere(
            (c) => c?.id == filter.companyId,
            orElse: () => null,
          );
    final selectedAction = filter.actionId == null
        ? null
        : actions.cast<DrugActionDto?>().firstWhere(
            (a) => a?.id == filter.actionId,
            orElse: () => null,
          );

    return AppScaffold(
      farmName: l10n.farmName,
      body: AppPage(
        child: Column(
          children: [
            const SizedBox(height: 6),
            _Header(
              title: l10n.pharmacyTitle,
              onBack: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go('/home');
                }
              },
              onRequests: () => context.push('/pharmacy/requests'),
            ),
            const SizedBox(height: 14),
            _SearchField(
              controller: _searchController,
              hint: l10n.pharmacySearchHint,
              onChanged: _onSearchChanged,
            ),
            const SizedBox(height: 12),
            _FilterDropdown(
              icon: Icons.storefront_outlined,
              label: selectedCompany?.name ?? l10n.pharmacyFilterAllProducers,
              active: selectedCompany != null,
              onTap: () => _openProducerPicker(context, companies),
            ),
            const SizedBox(height: 10),
            _FilterDropdown(
              icon: Icons.tune_rounded,
              label:
                  selectedAction?.localizedName(lang) ??
                  l10n.pharmacyFilterAllActions,
              active: selectedAction != null,
              onTap: () => _openActionPicker(context, actions, lang),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: catalogAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => _ErrorState(
                  message: _errorText(e),
                  onRetry: () => ref.invalidate(pharmacyCatalogProvider),
                ),
                data: (groups) {
                  return RefreshIndicator(
                    onRefresh: () async {
                      ref.invalidate(pharmacyCatalogProvider);
                      await ref.read(pharmacyCatalogProvider.future);
                    },
                    child: groups.isEmpty
                        ? const _EmptyCatalog()
                        : ListView.separated(
                            padding: const EdgeInsets.only(top: 4, bottom: 28),
                            physics: const AlwaysScrollableScrollPhysics(),
                            itemCount: groups.length,
                            itemBuilder: (_, i) => DrugGroupCard(
                              group: groups[i],
                              onTap: () => context.push(
                                '/pharmacy/group',
                                extra: groups[i],
                              ),
                            ),
                            separatorBuilder: (_, _) => const Divider(
                              height: 1,
                              thickness: 1,
                              color: Color(0xFFEFEDE6),
                            ),
                          ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openProducerPicker(
    BuildContext context,
    List<PharmacyCompanyDto> companies,
  ) async {
    final l10n = context.l10n;
    final current = ref.read(pharmacyFilterProvider).companyId;

    final selected = await showModalBottomSheet<_FilterChoice>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: ListView(
            shrinkWrap: true,
            padding: const EdgeInsets.symmetric(vertical: 8),
            children: [
              _PickerTile(
                title: l10n.pharmacyFilterAllProducers,
                selected: current == null,
                onTap: () => Navigator.of(ctx).pop(const _FilterChoice(null)),
              ),
              for (final c in companies)
                _PickerTile(
                  title: c.name,
                  selected: current == c.id,
                  onTap: () => Navigator.of(ctx).pop(_FilterChoice(c.id)),
                ),
            ],
          ),
        );
      },
    );

    if (selected == null) return;
    ref
        .read(pharmacyFilterProvider.notifier)
        .update(
          (f) => selected.id == null
              ? f.copyWith(clearCompany: true)
              : f.copyWith(companyId: selected.id),
        );
  }

  Future<void> _openActionPicker(
    BuildContext context,
    List<DrugActionDto> actions,
    String lang,
  ) async {
    final l10n = context.l10n;
    final current = ref.read(pharmacyFilterProvider).actionId;

    final selected = await showModalBottomSheet<_FilterChoice>(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(ctx).size.height * 0.7,
            ),
            child: ListView(
              shrinkWrap: true,
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                _PickerTile(
                  title: l10n.pharmacyFilterAllActions,
                  selected: current == null,
                  onTap: () => Navigator.of(ctx).pop(const _FilterChoice(null)),
                ),
                for (final a in actions)
                  _PickerTile(
                    title: a.localizedName(lang),
                    selected: current == a.id,
                    onTap: () => Navigator.of(ctx).pop(_FilterChoice(a.id)),
                  ),
              ],
            ),
          ),
        );
      },
    );

    if (selected == null) return;
    ref
        .read(pharmacyFilterProvider.notifier)
        .update(
          (f) => selected.id == null
              ? f.copyWith(clearAction: true)
              : f.copyWith(actionId: selected.id),
        );
  }

  String _errorText(Object error) {
    if (error is ApiException) return error.message;
    return error.toString();
  }
}

/// Обёртка вокруг выбранного `companyId` (null = все производители),
/// чтобы отличить «закрыли шит» от «выбрали Все».
class _FilterChoice {
  final int? id;
  const _FilterChoice(this.id);
}

class _Header extends StatelessWidget {
  final String title;
  final VoidCallback onBack;
  final VoidCallback onRequests;

  const _Header({
    required this.title,
    required this.onBack,
    required this.onRequests,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          padding: EdgeInsets.zero,
          icon: AppIcons.svg('arrow', size: 32),
          onPressed: onBack,
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.primary3,
            ),
          ),
        ),
        IconButton(
          tooltip: context.l10n.pharmacyMyRequests,
          padding: EdgeInsets.zero,
          icon: AppIcons.svg('checklist', size: 28, color: AppColors.primary1),
          onPressed: onRequests,
        ),
      ],
    );
  }
}

class _SearchField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final ValueChanged<String> onChanged;

  const _SearchField({
    required this.controller,
    required this.hint,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(fontSize: 14, color: Color(0xFF8A8A8A)),
        prefixIcon: Padding(
          padding: const EdgeInsets.all(12),
          child: AppIcons.svg('search', size: 20, color: AppColors.additional3),
        ),
        prefixIconConstraints: const BoxConstraints(minWidth: 44),
        filled: true,
        fillColor: const Color(0xFFF1EFEA),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class _FilterDropdown extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _FilterDropdown({
    required this.icon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final accent = active ? AppColors.primary1 : AppColors.additional3;
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: active
              ? AppColors.primary1.withValues(alpha: 0.10)
              : const Color(0xFFF1EFEA),
          borderRadius: BorderRadius.circular(14),
          border: active
              ? Border.all(color: AppColors.primary1, width: 1)
              : null,
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: accent),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: active ? FontWeight.w600 : FontWeight.w400,
                  color: active ? AppColors.primary1 : AppColors.primary3,
                ),
              ),
            ),
            Icon(Icons.keyboard_arrow_down_rounded, size: 20, color: accent),
          ],
        ),
      ),
    );
  }
}

class _PickerTile extends StatelessWidget {
  final String title;
  final bool selected;
  final VoidCallback onTap;

  const _PickerTile({
    required this.title,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        title,
        style: TextStyle(
          fontSize: 15,
          fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
          color: selected ? AppColors.primary1 : AppColors.primary3,
        ),
      ),
      trailing: selected
          ? const Icon(Icons.check, color: AppColors.primary1, size: 20)
          : null,
      onTap: onTap,
    );
  }
}

class _EmptyCatalog extends StatelessWidget {
  const _EmptyCatalog();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        const SizedBox(height: 80),
        Icon(Icons.search_off_rounded, size: 64, color: AppColors.additional2),
        const SizedBox(height: 16),
        Text(
          l10n.pharmacyEmptyCatalogTitle,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.primary3,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          l10n.pharmacyEmptyCatalogSubtitle,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 14, color: AppColors.additional3),
        ),
      ],
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            l10n.errorPrefix(message),
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.primary3),
          ),
          const SizedBox(height: 16),
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.primary1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: onRetry,
            child: Text(
              l10n.pharmacyRetry,
              style: const TextStyle(color: AppColors.primary1),
            ),
          ),
        ],
      ),
    );
  }
}
