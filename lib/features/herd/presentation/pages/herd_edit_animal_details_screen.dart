import 'package:flutter/material.dart';
import 'package:frontend/core/icons/app_icons.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/widgets/app_button.dart';
import 'package:frontend/core/widgets/app_page.dart';
import 'package:frontend/core/widgets/app_success_dialog.dart';
import 'package:frontend/core/widgets/fermer_plus_app_bar.dart';
import 'package:frontend/features/cattle_events/presentation/pages/add_cattle_event_sheet.dart';
import 'package:frontend/features/herd/application/herd_providers.dart';
import 'package:frontend/features/herd/data/datasources/herd_api.dart';
import 'package:frontend/features/herd/data/models/cattle_details_dto.dart';
import 'package:frontend/features/herd/domain/entities/animal_category.dart';
import 'package:frontend/features/herd/domain/entities/animal_category_resolver.dart';
import 'package:frontend/features/herd/domain/entities/cattle_edit_data.dart';
import 'package:frontend/features/herd/domain/entities/health_status.dart';
import 'package:frontend/core/widgets/page_header.dart';
import 'package:frontend/features/herd/presentation/widgets/herd_section_title.dart';
import 'package:frontend/features/herd/presentation/widgets/herd_text_field.dart';
import 'package:frontend/features/herd/presentation/widgets/herd_input_decoration.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

class HerdEditAnimalDetailsScreen extends ConsumerStatefulWidget {
  final CattleEditData draft;

  const HerdEditAnimalDetailsScreen({super.key, required this.draft});

  @override
  ConsumerState<HerdEditAnimalDetailsScreen> createState() =>
      _HerdEditAnimalDetailsScreenState();
}

class _HerdEditAnimalDetailsScreenState
    extends ConsumerState<HerdEditAnimalDetailsScreen> {
  late final TextEditingController _breedController;

  // группы пока убрали - оставляю контроллер, но UI и отправка закомментированы
  late final TextEditingController _groupController;

  final _eventController = TextEditingController();

  // cow/heifer extra
  final _milkYieldController = TextEditingController();
  final _lastCalvingCtrl = TextEditingController();
  final _lastInseminationCtrl = TextEditingController();

  HealthStatus? _healthStatus;

  DateTime? _lastCalvingDate;
  DateTime? _lastInseminationDate;

  bool _isSaving = false;

  bool? _isPregnant;
  bool? _isDryPeriod;

  final _ymd = DateFormat('yyyy-MM-dd');
  final _dmy = DateFormat('dd.MM.yyyy');

  @override
  void initState() {
    super.initState();

    _breedController = TextEditingController(text: widget.draft.breed ?? '');
    _groupController = TextEditingController(
      text: widget.draft.animalGroup ?? '',
    );

    _healthStatus = widget.draft.healthStatus;

    _milkYieldController.text = widget.draft.lastMilkYield == null
        ? ''
        : widget.draft.lastMilkYield.toString();

    _lastCalvingDate = widget.draft.lastCalvingDate;
    _lastInseminationDate = widget.draft.lastInseminationDate;

    _lastCalvingCtrl.text = _lastCalvingDate == null
        ? ''
        : _dmy.format(_lastCalvingDate!);

    _lastInseminationCtrl.text = _lastInseminationDate == null
        ? ''
        : _dmy.format(_lastInseminationDate!);

    if (widget.draft.pregnancyStatus == null) {
      _isPregnant = null;
    } else {
      _isPregnant = widget.draft.pregnancyStatus == 'PREGNANT';
    }
    _isDryPeriod = widget.draft.isDryPeriod;
  }

  @override
  void dispose() {
    _breedController.dispose();
    _groupController.dispose();
    _eventController.dispose();
    _milkYieldController.dispose();
    _lastCalvingCtrl.dispose();
    _lastInseminationCtrl.dispose();
    super.dispose();
  }

  String? _emptyToNull(String text) {
    final value = text.trim();
    return value.isEmpty ? null : value;
  }

  double? _parseDouble(String text) {
    final s = text.trim().replaceAll(',', '.');
    if (s.isEmpty) return null;
    return double.tryParse(s);
  }

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
    if (mounted) setState(() {});
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

  Future<void> _onSave() async {
    final herdApi = ref.read(herdApiProvider);

    // категория для условных полей
    final resolved = AnimalCategoryResolver.resolve(
      gender: widget.draft.gender,
      dateOfBirth: widget.draft.dateOfBirth,
    );
    final isCowOrHeifer =
        resolved.category == AnimalCategory.cow ||
        resolved.category == AnimalCategory.heifer;

    setState(() => _isSaving = true);

    try {
      final detailsDto = CattleDetailsDto(
        breed: _emptyToNull(_breedController.text),

        // группы пока убрали
        // animalGroup: _emptyToNull(_groupController.text),
        animalGroup: null,

        healthStatus: _healthStatus?.apiValue,

        // для cow/heifer сохраняем то, что ввели
        lastMilkYield: isCowOrHeifer
            ? _parseDouble(_milkYieldController.text)
            : widget.draft.lastMilkYield,

        lastCalvingDate: isCowOrHeifer && _lastCalvingDate != null
            ? _ymd.format(_lastCalvingDate!)
            : null,

        lastInseminationDate: isCowOrHeifer && _lastInseminationDate != null
            ? _ymd.format(_lastInseminationDate!)
            : null,

        pregnancyStatus: isCowOrHeifer && _isPregnant != null
            ? (_isPregnant! ? 'PREGNANT' : 'NOT_PREGNANT')
            : null,

        isDryPeriod: isCowOrHeifer && _isPregnant == true ? _isDryPeriod : null,
      );

      await herdApi.patchDetails(
        cattleId: widget.draft.id,
        details: detailsDto,
      );

      ref.invalidate(cattleListProvider);
      ref.invalidate(cattleByIdProvider(widget.draft.id));

      if (!mounted) return;

      await showAppSuccessDialog(
        context,
        title: 'Карточка животного\nуспешно обновлена!',
        iconAsset: 'assets/icons/success.svg',
        buttonText: 'Понятно',
        iconHeight: 50,
        iconWidth: 50,
      );
      if (!mounted) return;

      context.go('/herd');
    } catch (e, st) {
      debugPrint('UPDATE DETAILS error: $e\n$st');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка при сохранении изменений: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _openAddEventSheet() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SingleChildScrollView(
          child: AddCattleEventSheet(cattleId: widget.draft.id),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final resolved = AnimalCategoryResolver.resolve(
      gender: widget.draft.gender,
      dateOfBirth: widget.draft.dateOfBirth,
    );
    final isCowOrHeifer =
        resolved.category == AnimalCategory.cow ||
        resolved.category == AnimalCategory.heifer;

    return Scaffold(
      backgroundColor: AppColors.primary1,
      appBar: const FermerPlusAppBar(),
      body: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
        child: Column(
          children: [
            Expanded(
              child: Container(
                color: AppColors.background,
                child: AppPage(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.only(top: 16, bottom: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        HerdPageHeader(
                          title: 'Редактирование карточки',
                          onBack: () => context.pop(),
                        ),
                        const SizedBox(height: 12),
                        const HerdSectionTitle(
                          text: 'Дополнительная информация',
                        ),
                        const SizedBox(height: 24),

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
                          controller: _breedController,
                          hint: 'Введите название',
                        ),

                        const SizedBox(height: 24),

                        // Группа пока убрана
                        // ... UI закомментирован ...
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
                                (status) => DropdownMenuItem(
                                  value: status,
                                  child: Text(status.display),
                                ),
                              )
                              .toList(),
                          onChanged: _isSaving
                              ? null
                              : (value) =>
                                    setState(() => _healthStatus = value),
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
                            controller: _milkYieldController,
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
                              onTap: _isSaving
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
                              onTap: _isSaving
                                  ? null
                                  : () => _pickDate(
                                      help: 'Дата последнего осеменения',
                                      ctrl: _lastInseminationCtrl,
                                      onPicked: (d) =>
                                          _lastInseminationDate = d,
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
                            initialValue: _isPregnant,
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
                            onChanged: _isSaving
                                ? null
                                : (v) {
                                    setState(() {
                                      _isPregnant = v;
                                      if (v != true) _isDryPeriod = null;
                                    });
                                  },
                          ),

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
                              initialValue: _isDryPeriod,
                              decoration: herdInputDecoration(
                                hint: 'Выбрать из списка',
                              ),
                              items: const [
                                DropdownMenuItem(
                                  value: true,
                                  child: Text('Да'),
                                ),
                                DropdownMenuItem(
                                  value: false,
                                  child: Text('Нет'),
                                ),
                              ],
                              onChanged: _isSaving
                                  ? null
                                  : (v) => setState(() => _isDryPeriod = v),
                            ),
                          ],
                        ],

                        const SizedBox(height: 12),

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
                          controller: _eventController,
                          hint: 'Добавить событие',
                          suffixIcon: IconButton(
                            icon: const Icon(
                              Icons.add,
                              size: 20,
                              color: AppColors.primary1,
                            ),
                            onPressed: _isSaving ? null : _openAddEventSheet,
                          ),
                        ),

                        const SizedBox(height: 22),

                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: _isSaving
                                    ? null
                                    : () => context.pop(),
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
                                text: _isSaving ? 'Сохранение...' : 'Сохранить',
                                onPressed: _isSaving ? () {} : _onSave,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
