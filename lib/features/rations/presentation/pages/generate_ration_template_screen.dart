import 'package:flutter/material.dart';
import 'package:frontend/core/icons/app_icons.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/widgets/app_page.dart';
import 'package:frontend/core/widgets/app_scaffold.dart';
import 'package:frontend/core/widgets/app_success_dialog.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:frontend/features/herd/domain/entities/animal_category.dart';
import 'package:frontend/features/herd/domain/entities/production_state.dart';

import '../../application/rations_providers.dart';
import '../../data/models/generate_ration_template_dto.dart';

class GenerateRationTemplateScreen extends ConsumerStatefulWidget {
  const GenerateRationTemplateScreen({super.key});

  @override
  ConsumerState<GenerateRationTemplateScreen> createState() =>
      _GenerateRationTemplateScreenState();
}

class _GenerateRationTemplateScreenState
    extends ConsumerState<GenerateRationTemplateScreen> {
  final _targetCtrl = TextEditingController();
  bool _saving = false;

  AnimalCategory _category = AnimalCategory.cow;
  ProductionState _production = ProductionState.lactating;

  @override
  void dispose() {
    _targetCtrl.dispose();
    super.dispose();
  }

  double? _parseKg(String s) {
    final v = s.trim().replaceAll(',', '.');
    return double.tryParse(v);
  }

  Future<void> _submit() async {
    final target = _parseKg(_targetCtrl.text);
    if (target == null || target <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Укажите норму в день (кг)')),
      );
      return;
    }

    setState(() => _saving = true);
    try {
      final generate = ref.read(generateRationTemplateProvider);

      final effectiveProduction = _shouldHideProduction(_category)
          ? ProductionState.unknown
          : _production;

      final dto = GenerateRationTemplateDto(
        animalCategory: _category.apiValue,
        productionState: effectiveProduction.apiValue,
        targetDailyKg: target,
      );

      await generate(dto);

      if (!mounted) return;

      await showAppSuccessDialog(
        context,
        title: 'Рацион успешно\nдобавлен!',
        buttonText: 'Перейти к списку',
        onButtonPressed: () {
          // поставь свой реальный роут страницы списка рационов
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

  InputDecoration _decor({String? hint, Widget? prefixIcon}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        fontSize: 14,
        color: const Color.fromARGB(255, 95, 95, 95),
      ),
      prefixIcon: prefixIcon,
      prefixIconConstraints: const BoxConstraints(minWidth: 42, minHeight: 42),
      filled: true,
      fillColor: const Color.fromARGB(255, 239, 239, 239),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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

  List<ProductionState> _allowedProductionStates(AnimalCategory c) {
    switch (c) {
      case AnimalCategory.cow:
        return [ProductionState.lactating, ProductionState.dry];
      case AnimalCategory.bull:
        return [ProductionState.fattening, ProductionState.breeding];
      case AnimalCategory.calf:
      case AnimalCategory.heifer:
        return [ProductionState.unknown];
    }
  }

  bool _shouldHideProduction(AnimalCategory c) {
    return c == AnimalCategory.calf || c == AnimalCategory.heifer;
  }

  void _syncProductionWithCategory(AnimalCategory c) {
    final allowed = _allowedProductionStates(c);

    // если нужно скрыть - принудительно UNKNOWN
    if (_shouldHideProduction(c)) {
      _production = ProductionState.unknown;
      return;
    }

    // если текущий период не в allowed - ставим первый допустимый
    if (!allowed.contains(_production)) {
      _production = allowed.first;
    }
  }

  @override
  void initState() {
    super.initState();
    _syncProductionWithCategory(_category);
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      bottomNavIndex: null,
      farmName: 'Название фермы',
      enableDrawer: false,
      showBell: false,
      backgroundColor: AppColors.primary1,
      body: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
        child: Container(
          color: AppColors.background,
          child: AppPage(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 12),

                // header
                Row(
                  children: [
                    IconButton(
                      padding: EdgeInsets.zero,
                      icon: AppIcons.svg('arrow', size: 32),
                      onPressed: () => context.pop(false),
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Добавить/Редактировать\nрацион',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary3,
                        ),
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),

                const SizedBox(height: 18),

                const _Label('Категория скота'),
                const SizedBox(height: 6),
                _Dropdown<AnimalCategory>(
                  value: _category,
                  items: AnimalCategory.values
                      .map(
                        (x) =>
                            DropdownMenuItem(value: x, child: Text(x.display)),
                      )
                      .toList(),
                  onChanged: (v) {
                    if (v == null) return;
                    setState(() {
                      _category = v;
                      _syncProductionWithCategory(v);
                    });
                  },
                ),

                const SizedBox(height: 16),

                if (!_shouldHideProduction(_category)) ...[
                  const SizedBox(height: 16),
                  const _Label('Период'),
                  const SizedBox(height: 6),
                  _Dropdown<ProductionState>(
                    value: _production,
                    items: _allowedProductionStates(_category)
                        .map(
                          (x) => DropdownMenuItem(
                            value: x,
                            child: Text(x.display),
                          ),
                        )
                        .toList(),
                    onChanged: (v) {
                      if (v == null) return;
                      setState(() => _production = v);
                    },
                  ),
                ],

                const SizedBox(height: 16),

                const _Label('Норма в день (кг)'),
                const SizedBox(height: 6),
                SizedBox(
                  height: 48,
                  child: TextField(
                    controller: _targetCtrl,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: _decor(hint: 'Укажите норму'),
                  ),
                ),

                const Spacer(),

                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
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
                            onPressed: _saving
                                ? null
                                : () => context.pop(false),
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
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.primary3,
      ),
    );
  }
}

class _Dropdown<T> extends StatelessWidget {
  final T value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;

  const _Dropdown({
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(40),
        color: const Color.fromARGB(255, 239, 239, 239),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isExpanded: true,
          items: items,
          onChanged: onChanged,
        ),
      ),
    );
  }
}
