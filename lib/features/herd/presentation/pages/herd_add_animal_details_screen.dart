import 'package:flutter/material.dart';
import 'package:frontend/core/icons/app_icons.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/widgets/app_button.dart';
import 'package:frontend/core/widgets/app_page.dart';
import 'package:frontend/core/widgets/app_success_dialog.dart';
import 'package:frontend/core/widgets/fermer_plus_app_bar.dart';
import 'package:frontend/features/cattle_events/presentation/pages/add_cattle_event_sheet.dart';
import 'package:frontend/core/widgets/page_header.dart';
import 'package:frontend/features/herd/presentation/widgets/herd_section_title.dart';
import 'package:frontend/features/herd/presentation/widgets/herd_steps_indicator.dart';
import 'package:frontend/features/herd/presentation/widgets/herd_text_field.dart';
import 'package:frontend/features/herd/presentation/widgets/herd_input_decoration.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:frontend/features/herd/domain/entities/health_status.dart';
import 'package:frontend/features/herd/domain/entities/animal_category.dart';
import 'package:frontend/features/herd/domain/entities/animal_category_resolver.dart';
import 'package:frontend/features/herd/data/datasources/herd_api.dart';
import 'package:frontend/features/herd/data/models/cattle_details_dto.dart';
import 'package:frontend/features/herd/application/herd_providers.dart';

class HerdAddAnimalDetailsScreen extends ConsumerStatefulWidget {
  final int cattleId;

  const HerdAddAnimalDetailsScreen({super.key, required this.cattleId});

  @override
  ConsumerState<HerdAddAnimalDetailsScreen> createState() =>
      _HerdAddAnimalDetailsScreenState();
}

class _HerdAddAnimalDetailsScreenState
    extends ConsumerState<HerdAddAnimalDetailsScreen> {
  final _breedCtrl = TextEditingController();
  final _groupCtrl = TextEditingController();
  final _eventCtrl = TextEditingController();
  final _milkYieldCtrl = TextEditingController();

  final _lastCalvingCtrl = TextEditingController();
  final _lastInseminationCtrl = TextEditingController();

  DateTime? _lastCalvingDate;
  DateTime? _lastInseminationDate;

  HealthStatus? _healthStatus;
  bool? _isPregnant;
  bool? _isDryPeriod;

  bool _saving = false;

  final _ymd = DateFormat('yyyy-MM-dd');
  final _dmy = DateFormat('dd.MM.yyyy');

  @override
  void dispose() {
    _breedCtrl.dispose();
    _groupCtrl.dispose();
    _eventCtrl.dispose();
    _milkYieldCtrl.dispose();
    _lastCalvingCtrl.dispose();
    _lastInseminationCtrl.dispose();
    super.dispose();
  }

  String? _nn(String v) => v.trim().isEmpty ? null : v.trim();
  double? _dd(String v) => double.tryParse(v.replaceAll(',', '.'));

  Future<void> _pickDate({
    required String help,
    required TextEditingController ctrl,
    required void Function(DateTime d) onPicked,
  }) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(now.year - 20),
      lastDate: DateTime(now.year + 5),
      helpText: help,
    );
    if (picked == null) return;
    onPicked(picked);
    ctrl.text = _dmy.format(picked);
    setState(() {});
  }

  Widget _labeledRight({required String label, required Widget field}) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.primary3,
            ),
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(width: 170, child: field),
      ],
    );
  }

  Future<void> _save() async {
    setState(() => _saving = true);

    try {
      final details = CattleDetailsDto(
        breed: _nn(_breedCtrl.text),
        animalGroup: _nn(_groupCtrl.text),
        healthStatus: _healthStatus?.apiValue,
        lastMilkYield: _dd(_milkYieldCtrl.text),
        lastCalvingDate: _lastCalvingDate == null
            ? null
            : _ymd.format(_lastCalvingDate!),
        lastInseminationDate: _lastInseminationDate == null
            ? null
            : _ymd.format(_lastInseminationDate!),
        pregnancyStatus: _isPregnant == null
            ? null
            : (_isPregnant! ? 'PREGNANT' : 'NOT_PREGNANT'),
        isDryPeriod: _isPregnant == true ? _isDryPeriod : null,
      );

      final api = ref.read(herdApiProvider);
      await api.updateDetails(id: widget.cattleId, details: details);

      ref.invalidate(cattleListProvider);
      ref.invalidate(cattleByIdProvider(widget.cattleId));

      if (!mounted) return;
      await showAppSuccessDialog(
        context,
        title: 'Карточка животного\nуспешно создана!',
        message:
            'Все данные сохранены.\nВы можете изменить их позже в карточке животного.',
        iconAsset: 'assets/icons/success.svg',
        buttonText: 'Понятно',
      );
      if (!mounted) return;
      context.go('/herd');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Ошибка сохранения: $e')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _openAddEvent() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      builder: (_) => AddCattleEventSheet(cattleId: widget.cattleId),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cattleAsync = ref.watch(cattleByIdProvider(widget.cattleId));

    return Scaffold(
      backgroundColor: AppColors.primary1,
      appBar: const FermerPlusAppBar(),
      body: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
        child: Container(
          color: AppColors.background,
          child: cattleAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Ошибка: $e')),
            data: (cattle) {
              final resolved = AnimalCategoryResolver.resolve(
                gender: cattle.gender,
                dateOfBirth: cattle.dateOfBirth,
              );
              final isCowOrHeifer =
                  resolved.category == AnimalCategory.cow ||
                  resolved.category == AnimalCategory.heifer;

              return AppPage(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(top: 16, bottom: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      HerdPageHeader(
                        title: 'Добавление животного',
                        onBack: () => context.pop(),
                      ),
                      const SizedBox(height: 12),
                      const HerdStepsIndicator(currentStep: 2),
                      const SizedBox(height: 20),
                      const HerdSectionTitle(text: 'Дополнительная информация'),
                      const SizedBox(height: 24),

                      // Порода
                      const Text(
                        'Порода',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: AppColors.primary3,
                        ),
                      ),
                      const SizedBox(height: 8),
                      HerdTextField(
                        controller: _breedCtrl,
                        hint: 'Введите название',
                      ),

                      const SizedBox(height: 24),

                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text(
                            'Группа',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: AppColors.primary3,
                            ),
                          ),
                          const Spacer(),
                          SizedBox(
                            width: 265,
                            height: 36,
                            child: GestureDetector(
                              onTap: _saving
                                  ? null
                                  : () {
                                      // TODO: открыть выбор группы (sheet / dialog)
                                    },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: AppColors.primary1),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      _groupCtrl.text.isEmpty
                                          ? 'Выбрать группу'
                                          : _groupCtrl.text,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: _groupCtrl.text.isEmpty
                                            ? AppColors.primary1
                                            : AppColors.primary3,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    AppIcons.svg(
                                      'arrow2',
                                      size: 14,
                                      color: AppColors.primary1,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Действия
                      const Text(
                        'Действия',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: AppColors.primary3,
                        ),
                      ),
                      const SizedBox(height: 8),

                      const Text(
                        'Состояние здоровья',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: AppColors.primary3,
                        ),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<HealthStatus>(
                        initialValue: _healthStatus,
                        decoration: herdInputDecoration(
                          hint: 'Выбрать из списка',
                        ),
                        items: HealthStatus.values
                            .map(
                              (s) => DropdownMenuItem(
                                value: s,
                                child: Text(s.display),
                              ),
                            )
                            .toList(),
                        onChanged: _saving
                            ? null
                            : (v) => setState(() => _healthStatus = v),
                      ),

                      if (isCowOrHeifer) ...[
                        const SizedBox(height: 16),
                        const Text(
                          'Последний надой (л/день)',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: AppColors.primary3,
                          ),
                        ),
                        const SizedBox(height: 8),
                        HerdTextField(
                          controller: _milkYieldCtrl,
                          hint: 'Введите значение',
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                        ),

                        const SizedBox(height: 16),

                        _labeledRight(
                          label: 'Дата\nпоследнего отела',
                          field: HerdTextField(
                            controller: _lastCalvingCtrl,
                            readOnly: true,
                            hint: '31.12.2025',
                            onTap: _saving
                                ? null
                                : () => _pickDate(
                                    help: 'Дата последнего отела',
                                    ctrl: _lastCalvingCtrl,
                                    onPicked: (d) => _lastCalvingDate = d,
                                  ),
                            prefixIcon: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              child: AppIcons.svg(
                                'calendar',
                                size: 18,
                                color: AppColors.primary3,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        _labeledRight(
                          label: 'Дата последнего\nосеменения',
                          field: HerdTextField(
                            controller: _lastInseminationCtrl,
                            readOnly: true,
                            hint: '31.12.2025',
                            onTap: _saving
                                ? null
                                : () => _pickDate(
                                    help: 'Дата последнего осеменения',
                                    ctrl: _lastInseminationCtrl,
                                    onPicked: (d) => _lastInseminationDate = d,
                                  ),
                            prefixIcon: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              child: AppIcons.svg(
                                'calendar',
                                size: 18,
                                color: AppColors.primary3,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        const Text(
                          'Статус суягности',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: AppColors.primary3,
                          ),
                        ),
                        const SizedBox(height: 8),

                        DropdownButtonFormField<bool>(
                          value: _isPregnant,
                          decoration: herdInputDecoration(
                            hint: 'Выбрать из списка',
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: true,
                              child: Text('Беременна'),
                            ),
                            DropdownMenuItem(
                              value: false,
                              child: Text('Не беременна'),
                            ),
                          ],
                          onChanged: _saving
                              ? null
                              : (v) {
                                  setState(() {
                                    _isPregnant = v;

                                    // если выбрали "Не беременна" - сухостой сбрасываем
                                    if (v != true) {
                                      _isDryPeriod = null;
                                    }
                                  });
                                },
                        ),

                        // ---- Сухостой показываем ТОЛЬКО если беременна ----
                        if (_isPregnant == true) ...[
                          const SizedBox(height: 16),

                          const Text(
                            'Сухостой',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: AppColors.primary3,
                            ),
                          ),
                          const SizedBox(height: 8),

                          DropdownButtonFormField<bool>(
                            value: _isDryPeriod,
                            decoration: herdInputDecoration(
                              hint: 'Выбрать из списка',
                            ),
                            items: const [
                              DropdownMenuItem(value: true, child: Text('Да')),
                              DropdownMenuItem(
                                value: false,
                                child: Text('Нет'),
                              ),
                            ],
                            onChanged: _saving
                                ? null
                                : (v) => setState(() => _isDryPeriod = v),
                          ),
                        ],
                      ],

                      const SizedBox(height: 16),

                      const Text(
                        'Событие',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: AppColors.primary3,
                        ),
                      ),
                      const SizedBox(height: 8),
                      HerdTextField(
                        controller: _eventCtrl,
                        hint: 'Добавить событие',
                        suffixIcon: IconButton(
                          icon: const Icon(
                            Icons.add,
                            size: 20,
                            color: AppColors.primary1,
                          ),
                          onPressed: _saving ? null : _openAddEvent,
                        ),
                      ),

                      const SizedBox(height: 24),

                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: _saving
                                  ? null
                                  : () => context.go('/herd'),
                              style: OutlinedButton.styleFrom(
                                minimumSize: const Size.fromHeight(50),
                                backgroundColor: const Color.fromRGBO(
                                  213,
                                  215,
                                  218,
                                  0.6,
                                ),
                                side: const BorderSide(
                                  color: Color(0xFFF3F4F6),
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5),
                                ),
                              ),
                              child: const Text(
                                'Пропустить',
                                style: TextStyle(
                                  color: AppColors.additional3,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: FermerPlusBigButton(
                              height: 50,
                              borderRadius: 5,
                              fontSize: 14,
                              text: _saving ? 'Сохранение...' : 'Сохранить',
                              onPressed: _saving ? () {} : _save,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
