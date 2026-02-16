import 'package:flutter/material.dart';
import 'package:frontend/core/icons/app_icons.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/widgets/app_page.dart';
import 'package:frontend/core/widgets/app_scaffold.dart';
import 'package:frontend/core/widgets/app_success_dialog.dart';
import 'package:frontend/core/widgets/masked_date_picker.dart';
import 'package:frontend/features/cattle_events/application/bulk_event_providers.dart';
import 'package:frontend/features/cattle_events/application/cattle_events_providers.dart';
import 'package:frontend/features/cattle_events/application/simple_cattle_providers.dart';
import 'package:frontend/features/cattle_events/data/models/create_bulk_event_dto.dart';
import 'package:frontend/features/cattle_events/presentation/widgets/dynamic_event_fields.dart';
import 'package:frontend/features/cattle_events/presentation/widgets/select_cattle_sheet.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

enum BulkCattleCategory {
  cow('COW', 'Коровы'),
  bull('BULL', 'Быки'),
  heifer('HEIFER', 'Тёлки'),
  calf('CALF', 'Телята'),
  fattening('FATTENING', 'Откорм');

  final String api;
  final String title;
  const BulkCattleCategory(this.api, this.title);
}

class AddBulkCattleEventScreen extends ConsumerStatefulWidget {
  const AddBulkCattleEventScreen({super.key});

  @override
  ConsumerState<AddBulkCattleEventScreen> createState() =>
      _AddBulkCattleEventScreenState();
}

class _AddBulkCattleEventScreenState
    extends ConsumerState<AddBulkCattleEventScreen> {
  final _ymd = DateFormat('yyyy-MM-dd');
  final _dmy = DateFormat('dd.MM.yyyy');

  BulkCattleCategory _category = BulkCattleCategory.cow;

  final Set<int> _selectedIds = {};

  bool _saving = false;
  String? _eventType;

  DateTime? _eventDate;
  final _eventDateCtrl = TextEditingController();

  final _notesCtrl = TextEditingController();
  final _customTypeCtrl = TextEditingController();

  // dynamic controllers
  int _treatmentDays = 7;
  bool? _matingSuccess;
  String? _calvingDifficulty;

  final _vaccineNameCtrl = TextEditingController();
  final _diagnosisCtrl = TextEditingController();
  final _treatmentDaysCtrl = TextEditingController();
  final _drugNameCtrl = TextEditingController();
  final _dosageCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();
  final _bullNameCtrl = TextEditingController();
  final _bullTagCtrl = TextEditingController();

  DateTime? _endDate;
  final _endDateCtrl = TextEditingController();

  DateTime? _heatStart;
  final _heatStartCtrl = TextEditingController();

  DateTime? _heatEnd;
  final _heatEndCtrl = TextEditingController();

  void _syncTreatmentDaysCtrl() {
    _treatmentDaysCtrl.text = _treatmentDays.toString();
  }

  @override
  void initState() {
    super.initState();
    _syncTreatmentDaysCtrl();
  }

  @override
  void dispose() {
    _eventDateCtrl.dispose();
    _notesCtrl.dispose();
    _customTypeCtrl.dispose();

    _vaccineNameCtrl.dispose();
    _diagnosisCtrl.dispose();
    _treatmentDaysCtrl.dispose();
    _drugNameCtrl.dispose();
    _dosageCtrl.dispose();
    _weightCtrl.dispose();
    _bullNameCtrl.dispose();
    _bullTagCtrl.dispose();

    _endDateCtrl.dispose();
    _heatStartCtrl.dispose();
    _heatEndCtrl.dispose();
    super.dispose();
  }

  void _resetOnCategoryChange() {
    _selectedIds.clear();
    _eventType = null;
    _eventDate = null;
    _eventDateCtrl.clear();
    _notesCtrl.clear();
    _resetDynamicFieldsOnTypeChange();
  }

  void _resetDynamicFieldsOnTypeChange() {
    _treatmentDays = 7;
    _syncTreatmentDaysCtrl();
    _matingSuccess = null;

    _vaccineNameCtrl.clear();
    _diagnosisCtrl.clear();
    _treatmentDaysCtrl.clear();
    _drugNameCtrl.clear();
    _dosageCtrl.clear();
    _weightCtrl.clear();
    _bullNameCtrl.clear();
    _bullTagCtrl.clear();

    _calvingDifficulty = null;

    _endDate = null;
    _endDateCtrl.clear();

    _heatStart = null;
    _heatStartCtrl.clear();

    _heatEnd = null;
    _heatEndCtrl.clear();

    _customTypeCtrl.clear();
  }

  void _safePop() {
    if (!mounted) return;

    final navigator = Navigator.of(context);

    // если открыт dialog/bottomsheet - закроем его
    if (navigator.canPop()) {
      navigator.pop();
      return;
    }

    // если go_router не может pop - уйдем на нужный экран
    // выбери правильный fallback для твоего проекта
    context.go('/events'); // или '/home'
  }

  InputDecoration _dec({required String hint, Widget? prefixIcon}) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: prefixIcon,
      prefixIconConstraints: const BoxConstraints(minWidth: 42, minHeight: 42),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(color: AppColors.additional2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(color: AppColors.additional2),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(color: AppColors.success),
      ),
    );
  }

  Future<void> _pickEventDate() async {
    final now = DateTime.now();
    final picked = await showMaskedDatePicker(
      context: context,
      initialDate: _eventDate ?? now,
      firstDate: DateTime(now.year - 20),
      lastDate: DateTime(now.year + 5),
      helpText: 'Выберите дату события',
    );
    if (picked == null) return;
    if (!mounted) return;
    setState(() {
      _eventDate = picked;
      _eventDateCtrl.text = _dmy.format(picked);
    });
  }

  Future<void> _pickDateTo({
    required void Function(DateTime d) onPicked,
    required TextEditingController ctrl,
    required String helpText,
  }) async {
    final now = DateTime.now();
    final picked = await showMaskedDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(now.year - 20),
      lastDate: DateTime(now.year + 5),
      helpText: helpText,
    );
    if (picked == null) return;
    if (!mounted) return;
    onPicked(picked);
    ctrl.text = _dmy.format(picked);
    setState(() {});
  }

  Map<String, dynamic> _buildEventData() {
    final t = _eventType;
    if (t == null) return {};

    String? nn(String v) => v.trim().isEmpty ? null : v.trim();
    int? ii(String v) => int.tryParse(v.trim());
    double? dd(String v) => double.tryParse(v.trim().replaceAll(',', '.'));

    final data = <String, dynamic>{};

    if (t == 'VACCINATION') {
      data['vaccineName'] = nn(_vaccineNameCtrl.text);
    }

    if (t == 'ANTIPARASITIC_TREATMENT') {
      data['drugName'] = nn(_drugNameCtrl.text);
      data['dosage'] = nn(_dosageCtrl.text);
    }

    if (t == 'ILLNESS_TREATMENT') {
      data['diagnosis'] = nn(_diagnosisCtrl.text);
      data['treatmentDays'] = ii(_treatmentDaysCtrl.text);
      data['drugName'] = nn(_drugNameCtrl.text);
      data['dosage'] = nn(_dosageCtrl.text);
      if (_endDate != null) data['endDate'] = _ymd.format(_endDate!);
    }

    if (t == 'WEIGHING') {
      data['weight'] = dd(_weightCtrl.text);
    }

    if (t == 'INSEMINATION' || t == 'MATING') {
      data['bullName'] = nn(_bullNameCtrl.text);
      data['bullTag'] = nn(_bullTagCtrl.text);
    }

    if (t == 'CALVING') {
      data['calvingEase'] = _calvingDifficulty;
      data['bullTag'] = nn(_bullTagCtrl.text);
    }

    if (t == 'HEAT_PERIOD') {
      if (_heatStart != null) data['heatStartDate'] = _ymd.format(_heatStart!);
      if (_heatEnd != null) data['heatEndDate'] = _ymd.format(_heatEnd!);
    }

    if (t == 'SYNCHRONIZATION') {
      data['drugName'] = nn(_drugNameCtrl.text);
      data['dosage'] = nn(_dosageCtrl.text);
    }

    if (t == 'DRY_PERIOD') {
      if (_endDate != null) data['endDate'] = _ymd.format(_endDate!);
    }

    if (t == 'OTHER') {
      data['customType'] = nn(_customTypeCtrl.text);
    }

    data.removeWhere((k, v) => v == null);
    return data;
  }

  Future<void> _openSelectCattleSheet() async {
    final listAsync = await ref.read(
      simpleCattleByCategoryProvider(_category.api).future,
    );

    if (!mounted) return;

    final picked = await showModalBottomSheet<List<int>>(
      context: context,
      showDragHandle: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) =>
          SelectCattleSheet(items: listAsync, initialSelected: _selectedIds),
    );

    if (picked == null) return;

    setState(() {
      _selectedIds
        ..clear()
        ..addAll(picked);

      // если после выбора скота текущий eventType не входит в новый список типов, сбрасываем
      _eventType = null;
      _resetDynamicFieldsOnTypeChange();
    });
  }

  Future<void> _submit() async {
    if (_selectedIds.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Выберите скот')));
      return;
    }

    if (_eventType == null || _eventType!.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Выберите тип события')));
      return;
    }

    if (_eventType != 'HEAT_PERIOD' && _eventDate == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Выберите дату события')));
      return;
    }

    if (_eventType == 'HEAT_PERIOD' && _heatStart == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Выберите дату начала охоты')),
      );
      return;
    }

    if (_eventType == 'OTHER' && _customTypeCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Введите название события')));
      return;
    }

    setState(() => _saving = true);

    try {
      final data = _buildEventData();
      final dto = CreateBulkEventDto(
        cattleIds: _selectedIds.toList(),
        eventDate: _ymd.format(
          _eventType == 'HEAT_PERIOD' ? _heatStart! : _eventDate!,
        ),
        eventType: _eventType!,
        notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
        eventData: data.isEmpty ? null : data,
      );

      final create = ref.read(createBulkCattleEventsProvider);
      await create(dto);

      // если нужно обновить списки/провайдеры - добавь invalidate
      // ref.invalidate(plannedEventsProvider('PENDING'));

      if (!mounted) return;

      await showAppSuccessDialog(
        context,
        title: 'Массовое событие\nуспешно создано!',
        message: 'Все данные сохранены.\nВы можете изменить их позже.',
        buttonText: 'Понятно',
        // если хочешь стрелку в кнопке:
        // buttonIcon: const Icon(Icons.arrow_forward_ios_rounded),
        // buttonIconAfterText: true,
      );

      if (!mounted) return;
      _safePop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Ошибка: $e')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  String _keyFromIds(List<int> ids) {
    final sorted = [...ids]..sort();
    return sorted.join(',');
  }

  @override
  Widget build(BuildContext context) {
    final cattleAsync = ref.watch(
      simpleCattleByCategoryProvider(_category.api),
    );
    final selectedKey = _keyFromIds(_selectedIds.toList());

    final typesAsync = _selectedIds.isEmpty
        ? const AsyncValue.data(<String>[])
        : ref.watch(bulkAvailableEventTypesProvider(selectedKey));

    return AppScaffold(
      bottomNavIndex: null,
      enableDrawer: false,
      showAppBar: true,
      showBell: false,
      userName: 'Ахмет Кусаинов',
      farmName: 'Название фермы',
      body: LayoutBuilder(
        builder: (context, constraints) {
          final bottomInset = MediaQuery.of(context).viewInsets.bottom;
          return AppPage(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(bottom: bottomInset),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),

                      Row(
                        children: [
                          IconButton(
                            padding: EdgeInsets.zero,
                            icon: AppIcons.svg('arrow', size: 32),
                            onPressed: _saving ? null : _safePop,
                          ),
                          const SizedBox(width: 6),
                          const Expanded(
                            child: Text(
                              'Добавить массовое событие',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary3,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      const Text(
                        'Категория',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: AppColors.primary3,
                        ),
                      ),
                      const SizedBox(height: 6),

                      DropdownButtonFormField<BulkCattleCategory>(
                        value: _category,
                        decoration: _dec(hint: 'Выберите категорию'),
                        items: BulkCattleCategory.values
                            .map(
                              (c) => DropdownMenuItem(
                                value: c,
                                child: Text(c.title),
                              ),
                            )
                            .toList(),
                        onChanged: _saving
                            ? null
                            : (v) {
                                if (v == null) return;
                                setState(() {
                                  _category = v;
                                  _resetOnCategoryChange();
                                });
                              },
                      ),

                      const SizedBox(height: 16),

                      const Text(
                        'Скот',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: AppColors.primary3,
                        ),
                      ),
                      const SizedBox(height: 6),

                      cattleAsync.when(
                        loading: () => const SizedBox(
                          height: 44,
                          child: Center(child: CircularProgressIndicator()),
                        ),
                        error: (e, _) => Text('Ошибка загрузки скота: $e'),
                        data: (list) {
                          final hint = _selectedIds.isEmpty
                              ? 'Выбрать скот'
                              : 'Выбрано: ${_selectedIds.length}';

                          return SizedBox(
                            height: 48,
                            width: double.infinity,
                            child: OutlinedButton(
                              onPressed: _saving || list.isEmpty
                                  ? null
                                  : _openSelectCattleSheet,
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(
                                  color: AppColors.additional2,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                backgroundColor: Colors.white,
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      hint,
                                      style: const TextStyle(
                                        color: AppColors.primary3,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  const Icon(
                                    Icons.keyboard_arrow_down,
                                    color: AppColors.additional3,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 16),

                      const Text(
                        'Событие',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: AppColors.primary3,
                        ),
                      ),
                      const SizedBox(height: 6),

                      typesAsync.when(
                        loading: () => const SizedBox(
                          height: 44,
                          child: Center(child: CircularProgressIndicator()),
                        ),
                        error: (e, _) => Text('Ошибка типов: $e'),
                        data: (types) {
                          final allowedBulk = <String>{
                            'VACCINATION',
                            'ANTIPARASITIC_TREATMENT',
                            'HOOF_TRIMMING',
                            'SYNCHRONIZATION',
                            'DRY_PERIOD',
                            'OTHER',
                            'ILLNESS_TREATMENT',
                            'INSEMINATION',
                            'HEAT_PERIOD',
                          };

                          final filteredTypes = types
                              .where(allowedBulk.contains)
                              .toList();
                          final disabled =
                              _selectedIds.isEmpty || filteredTypes.isEmpty;

                          final dropdownValue =
                              (_eventType != null &&
                                  filteredTypes.contains(_eventType))
                              ? _eventType
                              : null;

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              DropdownButtonFormField<String>(
                                value: dropdownValue,
                                decoration: _dec(
                                  hint: disabled
                                      ? (_selectedIds.isEmpty
                                            ? 'Сначала выберите скот'
                                            : 'Нет доступных событий')
                                      : 'Выбрать из списка',
                                ),
                                items: filteredTypes
                                    .map(
                                      (t) => DropdownMenuItem(
                                        value: t,
                                        child: Text(_eventTypeTitle(t)),
                                      ),
                                    )
                                    .toList(),

                                onChanged: disabled || _saving
                                    ? null
                                    : (v) {
                                        setState(() {
                                          _eventType = v;
                                          _resetDynamicFieldsOnTypeChange();
                                        });
                                      },
                              ),

                              const SizedBox(height: 18),

                              if (_eventType != null &&
                                  _eventType != 'HEAT_PERIOD') ...[
                                _LabeledRightField(
                                  label: _dateLabelForType(_eventType),
                                  field: TextField(
                                    controller: _eventDateCtrl,
                                    readOnly: true,
                                    onTap: _saving ? null : _pickEventDate,
                                    decoration: _dec(
                                      hint: '31.12.2025',
                                      prefixIcon: Padding(
                                        padding: const EdgeInsets.only(
                                          left: 12,
                                          right: 8,
                                        ),
                                        child: AppIcons.svg(
                                          'calendar',
                                          size: 18,
                                          color: AppColors.primary3,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 18),
                              ],

                              DynamicEventFields(
                                eventType: _eventType,
                                vaccineNameCtrl: _vaccineNameCtrl,
                                diagnosisCtrl: _diagnosisCtrl,
                                treatmentDaysCtrl: _treatmentDaysCtrl,
                                drugNameCtrl: _drugNameCtrl,
                                dosageCtrl: _dosageCtrl,
                                weightCtrl: _weightCtrl,
                                bullNameCtrl: _bullNameCtrl,
                                bullTagCtrl: _bullTagCtrl,
                                customTypeCtrl: _customTypeCtrl,
                                calvingDifficulty: _calvingDifficulty,
                                onCalvingDifficultyChanged: (v) =>
                                    setState(() => _calvingDifficulty = v),
                                endDateCtrl: _endDateCtrl,
                                onPickEndDate: _saving
                                    ? null
                                    : () => _pickDateTo(
                                        onPicked: (d) => _endDate = d,
                                        ctrl: _endDateCtrl,
                                        helpText: 'Дата окончания',
                                      ),
                                heatStartCtrl: _heatStartCtrl,
                                onPickHeatStart: _saving
                                    ? null
                                    : () => _pickDateTo(
                                        onPicked: (d) => _heatStart = d,
                                        ctrl: _heatStartCtrl,
                                        helpText: 'Начало охоты',
                                      ),
                                heatEndCtrl: _heatEndCtrl,
                                onPickHeatEnd: _saving
                                    ? null
                                    : () => _pickDateTo(
                                        onPicked: (d) => _heatEnd = d,
                                        ctrl: _heatEndCtrl,
                                        helpText: 'Конец охоты',
                                      ),
                                treatmentDaysValue: _treatmentDays,
                                onMinusTreatmentDays: _saving
                                    ? () {}
                                    : () {
                                        setState(() {
                                          if (_treatmentDays > 1)
                                            _treatmentDays--;
                                          _syncTreatmentDaysCtrl();
                                        });
                                      },
                                onPlusTreatmentDays: _saving
                                    ? () {}
                                    : () {
                                        setState(() {
                                          _treatmentDays++;
                                          _syncTreatmentDaysCtrl();
                                        });
                                      },
                                matingSuccess: _matingSuccess,
                                onMatingSuccessChanged: (v) =>
                                    setState(() => _matingSuccess = v),
                                labeledRightField:
                                    ({
                                      required String label,
                                      required Widget field,
                                    }) => _LabeledRightField(
                                      label: label,
                                      field: field,
                                    ),
                                dec: ({required hint, prefixIcon}) =>
                                    _dec(hint: hint, prefixIcon: prefixIcon),
                                calendarIcon: Padding(
                                  padding: const EdgeInsets.only(
                                    left: 12,
                                    right: 8,
                                  ),
                                  child: AppIcons.svg(
                                    'calendar',
                                    size: 18,
                                    color: AppColors.primary3,
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),

                      const Text(
                        'Комментарий (опционально)',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: AppColors.primary3,
                        ),
                      ),
                      const SizedBox(height: 6),
                      TextField(
                        controller: _notesCtrl,
                        decoration: _dec(hint: ''),
                      ),

                      const SizedBox(height: 18),

                      Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              height: 48,
                              child: OutlinedButton(
                                onPressed: _saving ? null : _safePop,

                                style: OutlinedButton.styleFrom(
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
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                ),
                                child: const Text(
                                  'Отменить',
                                  style: TextStyle(
                                    color: AppColors.error,
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
                              child: ElevatedButton(
                                onPressed: _saving ? null : _submit,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary1,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                ),
                                child: Text(
                                  _saving ? 'Сохранение...' : 'Сохранить',
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _LabeledRightField extends StatelessWidget {
  final String label;
  final Widget field;

  const _LabeledRightField({required this.label, required this.field});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
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
}

String _dateLabelForType(String? t) {
  switch (t) {
    case 'VACCINATION':
      return 'Дата вакцинации';
    case 'ANTIPARASITIC_TREATMENT':
      return 'Дата обработки';
    case 'ILLNESS_TREATMENT':
      return 'Дата заболевания';
    case 'WEIGHING':
      return 'Дата взвешивания';
    case 'INSEMINATION':
      return 'Дата\nосеменения';
    case 'MATING':
      return 'Дата покрытия';
    case 'CALVING':
      return 'Дата отела';
    case 'PREGNANCY_CONFIRMATION':
      return 'Дата\nстельности';
    case 'HEAT_PERIOD':
      return 'Дата начала';
    case 'SYNCHRONIZATION':
      return 'Дата синхронизации';
    case 'DRY_PERIOD':
      return 'Дата начала';
    case 'WEANING':
      return 'Дата отъема';
    case 'HOOF_TRIMMING':
      return 'Дата расчистки';
    case 'OTHER':
      return 'Дата события';
    default:
      return 'Дата события';
  }
}

String _eventTypeTitle(String t) {
  switch (t) {
    case 'CALVING':
      return 'Отёл';
    case 'INSEMINATION':
      return 'Осеменение';
    case 'MATING':
      return 'Покрытие';
    case 'SYNCHRONIZATION':
      return 'Синхронизация';
    case 'PREGNANCY_CONFIRMATION':
      return 'Подтверждение стельности';
    case 'PREGNANCY_NOT_CONFIRMED':
      return 'Стельность не подтверждена';
    case 'DRY_PERIOD':
      return 'Сухостой';
    case 'HEAT_PERIOD':
      return 'Охота';
    case 'VACCINATION':
      return 'Вакцинация';
    case 'ILLNESS_TREATMENT':
      return 'Лечение';
    case 'WEIGHING':
      return 'Взвешивание';
    case 'HOOF_TRIMMING':
      return 'Расчистка копыт';
    case 'ANTIPARASITIC_TREATMENT':
      return 'Обработка от паразитов';
    case 'WEANING':
      return 'Отъём';
    case 'OTHER':
      return 'Другое';
    default:
      // fallback чтобы не было "CALVING" если вдруг новый тип прилетит
      return t.replaceAll('_', ' ');
  }
}
