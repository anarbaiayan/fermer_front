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
import '../../data/models/create_custom_feed_dto.dart';
import '../../data/models/create_user_rations_dto.dart';
import '../../data/models/ration_catalog_item_dto.dart';
import '../../data/models/user_ration_dto.dart';

class AddUserRationsScreen extends ConsumerStatefulWidget {
  const AddUserRationsScreen({super.key});

  @override
  ConsumerState<AddUserRationsScreen> createState() =>
      _AddUserRationsScreenState();
}

class _AddUserRationsScreenState extends ConsumerState<AddUserRationsScreen>
    with SingleTickerProviderStateMixin {
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

  static const List<String> _customTypes = [
    'COARSE',
    'JUICY',
    'CONCENTRATED',
    'VITAMINS_SUPPLEMENTS',
  ];

  final _customNameController = TextEditingController();
  final _customNameKkController = TextEditingController();
  final _customPriceController = TextEditingController();
  String _customType = 'COARSE';

  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_onTabChanged);
  }

  @override
  void dispose() {
    _customNameController.dispose();
    _customNameKkController.dispose();
    _customPriceController.dispose();
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (!mounted) return;
    if (_tabController.indexIsChanging) return;
    setState(() {});
  }

  String _typeTitle(BuildContext context, String type) {
    final l10n = context.l10n;

    switch (type.toUpperCase()) {
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

  Future<void> _submitStockSelection() async {
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

  Future<void> _submitCustomFeed() async {
    final l10n = context.l10n;
    final name = _customNameController.text.trim();
    final nameKk = _customNameKkController.text.trim();
    final priceText = _customPriceController.text.trim().replaceAll(',', '.');
    final price = double.tryParse(priceText);

    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.addUserRationsCustomNameRequired)),
      );
      return;
    }

    if (nameKk.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.addUserRationsCustomNameKkRequired)),
      );
      return;
    }

    if (price == null || price <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.addUserRationsCustomPriceInvalid)),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      final createCustom = ref.read(createCustomFeedProvider);
      await createCustom(
        CreateCustomFeedDto(
          name: name,
          nameKk: nameKk,
          type: _customType,
          pricePerKg: price,
        ),
      );

      _customNameController.clear();
      _customNameKkController.clear();
      _customPriceController.clear();
      _customType = 'COARSE';

      if (!mounted) return;
      _tabController.animateTo(0);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.addUserRationsCustomAdded)),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.errorPrefix(_errorText(e)))));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  InputDecoration _fieldDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(fontSize: 14, color: Color(0xFF9E9E9E)),
      filled: true,
      fillColor: const Color(0xFFF3F4F6),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(40),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(40),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(40),
        borderSide: BorderSide.none,
      ),
    );
  }

  Widget _buildStockSelectionTab(
    BuildContext context,
    WidgetRef ref,
    String languageCode,
  ) {
    final l10n = context.l10n;
    final catalogAsync = ref.watch(rationCatalogProvider);
    final userRationsAsync = ref.watch(userRationsProvider);

    return userRationsAsync.when(
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
          loading: () => const Center(child: CircularProgressIndicator()),
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
                      border: Border.all(color: AppColors.additional2),
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
                                  isOpen ? Icons.expand_less : Icons.expand_more,
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
                                            _selected[x.id] = v == true;
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
    );
  }

  Widget _buildCustomFeedTab(BuildContext context) {
    final l10n = context.l10n;

    return ListView(
      padding: const EdgeInsets.only(bottom: 12),
      children: [
        Text(
          l10n.addUserRationsCustomNameLabel,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppColors.primary3,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _customNameController,
          enabled: !_saving,
          decoration: _fieldDecoration(l10n.addUserRationsCustomNameHint),
        ),
        const SizedBox(height: 16),
        Text(
          l10n.addUserRationsCustomNameKkLabel,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppColors.primary3,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _customNameKkController,
          enabled: !_saving,
          decoration: _fieldDecoration(l10n.addUserRationsCustomNameKkHint),
        ),
        const SizedBox(height: 16),
        Text(
          l10n.addUserRationsCustomTypeLabel,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppColors.primary3,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          initialValue: _customType,
          decoration: _fieldDecoration(l10n.addUserRationsCustomTypeHint),
          items: _customTypes
              .map(
                (type) => DropdownMenuItem<String>(
                  value: type,
                  child: Text(_typeTitle(context, type)),
                ),
              )
              .toList(),
          onChanged: _saving
              ? null
              : (v) {
                  if (v == null) return;
                  setState(() => _customType = v);
                },
        ),
        const SizedBox(height: 16),
        Text(
          l10n.addUserRationsCustomPriceLabel,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppColors.primary3,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _customPriceController,
          enabled: !_saving,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: _fieldDecoration(l10n.addUserRationsCustomPriceHint),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final languageCode = Localizations.localeOf(context).languageCode;

    final saveLabel = _tabController.index == 0
        ? l10n.save
        : l10n.addUserRationsCustomSave;
    final onSave = _tabController.index == 0
        ? _submitStockSelection
        : _submitCustomFeed;

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
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: const Color(0xFFE9ECEF),
                borderRadius: BorderRadius.circular(22),
              ),
              child: TabBar(
                controller: _tabController,
                isScrollable: false,
                dividerColor: Colors.transparent,
                labelColor: Colors.white,
                unselectedLabelColor: AppColors.primary3,
                labelPadding: EdgeInsets.zero,
                indicatorSize: TabBarIndicatorSize.tab,
                indicatorPadding: EdgeInsets.zero,
                indicator: BoxDecoration(
                  color: AppColors.primary1,
                  borderRadius: BorderRadius.circular(18),
                ),
                tabs: [
                  Tab(
                    child: SizedBox(
                      height: 40,
                      child: Center(
                        child: Text(
                          l10n.addUserRationsTabFromCatalog,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ),
                  Tab(
                    child: SizedBox(
                      height: 40,
                      child: Center(
                        child: Text(
                          l10n.addUserRationsTabCustomFeed,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildStockSelectionTab(context, ref, languageCode),
                  _buildCustomFeedTab(context),
                ],
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
                        onPressed: _saving ? null : onSave,
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
                                saveLabel,
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
