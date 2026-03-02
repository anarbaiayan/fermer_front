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

class AddUserRationsScreen extends ConsumerStatefulWidget {
  const AddUserRationsScreen({super.key});

  @override
  ConsumerState<AddUserRationsScreen> createState() =>
      _AddUserRationsScreenState();
}

class _AddUserRationsScreenState extends ConsumerState<AddUserRationsScreen> {
  final Map<int, bool> _selected = {};
  final Map<int, TextEditingController> _kgControllers = {};

  bool _saving = false;

  // раскрытие секций по типам
  final Map<String, bool> _expanded = {
    'COARSE': true,
    'JUICY': true,
    'CONCENTRATED': true,
    'VITAMINS_SUPPLEMENTS': true,
  };

  @override
  void dispose() {
    for (final c in _kgControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  double? _parseKg(String s) {
    final v = s.trim().replaceAll(',', '.');
    return double.tryParse(v);
  }

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

  Future<void> _submit() async {
    // собрать только выбранное и валидировать кг
    final Map<int, double> payload = {};
    for (final entry in _selected.entries) {
      if (entry.value != true) continue;
      final id = entry.key;
      final ctrl = _kgControllers[id];
      final kg = _parseKg(ctrl?.text ?? '');
      if (kg == null || kg <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Укажите количество кг для выбранных кормов'),
          ),
        );
        return;
      }
      payload[id] = kg;
    }

    if (payload.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Выберите хотя бы один корм')),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      final create = ref.read(createUserRationsProvider);
      await create(
        CreateUserRationsDto(rationQuantity: payload, isAvailable: true),
      );

      if (!mounted) return;

      await showAppSuccessDialog(
        context,
        title: 'Рацион успешно\nдобавлен!',
        buttonText: 'Перейти к списку',
        onButtonPressed: () {
          context.go('/rations');
        },
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
              child: catalogAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (e, _) => Center(child: Text('Ошибка: $e')),
                data: (catalog) {
                  // группируем по type
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
                                onTap: () =>
                                    setState(() => _expanded[type] = !isOpen),
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

                                  _kgControllers.putIfAbsent(
                                    x.id,
                                    () => TextEditingController(),
                                  );

                                  return Container(
                                    color: checked
                                        ? const Color(0xFFF3F4F6)
                                        : Colors.white,
                                    child: ListTile(
                                      dense: true,
                                      leading: Checkbox(
                                        value: checked,
                                        activeColor: AppColors.primary1,
                                        onChanged: (v) {
                                          setState(() {
                                            _selected[x.id] = v == true;
                                            if (v != true) {
                                              _kgControllers[x.id]?.text = '';
                                            }
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
                                      trailing: checked
                                          ? SizedBox(
                                              width: 110,
                                              child: TextField(
                                                controller:
                                                    _kgControllers[x.id],
                                                keyboardType:
                                                    const TextInputType.numberWithOptions(
                                                      decimal: true,
                                                    ),
                                                decoration: InputDecoration(
                                                  hintText: 'кг',
                                                  hintStyle: TextStyle(
                                                    fontSize: 14,
                                                    color: const Color.fromARGB(
                                                      255,
                                                      95,
                                                      95,
                                                      95,
                                                    ),
                                                  ),
                                                  isDense: true,
                                                  filled: true,
                                                  fillColor:
                                                      const Color.fromARGB(
                                                        255,
                                                        239,
                                                        239,
                                                        239,
                                                      ),
                                                  contentPadding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 16,
                                                        vertical: 10,
                                                      ),
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          40,
                                                        ),
                                                    borderSide: BorderSide.none,
                                                  ),
                                                  enabledBorder:
                                                      OutlineInputBorder(
                                                        borderRadius:
                                                            BorderRadius.circular(
                                                              40,
                                                            ),
                                                        borderSide:
                                                            BorderSide.none,
                                                      ),
                                                ),
                                              ),
                                            )
                                          : null,
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
              ),
            ),

            // bottom buttons (как на макете)
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
                                'Добавить',
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
