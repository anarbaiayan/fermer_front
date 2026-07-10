import 'package:flutter/material.dart';
import 'package:frontend/core/icons/app_icons.dart';
import 'package:frontend/core/localization/l10n_extension.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/widgets/app_page.dart';
import 'package:frontend/core/widgets/app_scaffold.dart';
import 'package:frontend/core/widgets/app_success_dialog.dart';
import 'package:frontend/core/widgets/masked_date_picker.dart';
import 'package:frontend/features/cattle_events/application/bulk_event_providers.dart';
import 'package:frontend/features/cattle_events/application/cattle_events_providers.dart';
import 'package:frontend/features/cattle_events/application/simple_cattle_providers.dart';
import 'package:frontend/features/cattle_events/data/models/create_bulk_event_dto.dart';
import 'package:frontend/features/cattle_events/domain/entities/cattle_event_type.dart';
import 'package:frontend/features/cattle_events/presentation/widgets/dynamic_event_fields.dart';
import 'package:frontend/features/cattle_events/presentation/widgets/select_cattle_sheet.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:frontend/l10n/app_localizations.dart';

enum BulkCattleCategory {
  cow('COW'),
  bull('BULL'),
  heifer('HEIFER'),
  calf('CALF'),
  fattening('FATTENING');

  final String api;
  const BulkCattleCategory(this.api);
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

  Future<void> _pickEventDate() async {
    final l10n = context.l10n;
    final now = DateTime.now();
    final picked = await showMaskedDatePicker(
      context: context,
      initialDate: _eventDate ?? now,
      firstDate: DateTime(now.year - 20),
      lastDate: DateTime(now.year + 5),
      helpText: l10n.addEventPickDate,
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
    final l10n = context.l10n;
    if (_selectedIds.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.selectCattleTitle)));
      return;
    }

    if (_eventType == null || _eventType!.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.addEventSelectType)));
      return;
    }

    if (_eventType != 'HEAT_PERIOD' && _eventDate == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.addEventSelectDate)));
      return;
    }

    if (_eventType == 'HEAT_PERIOD' && _heatStart == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.addEventSelectHeatStart)));
      return;
    }

    if (_eventType == 'OTHER' && _customTypeCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.addEventEnterName)));
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
        title: l10n.bulkEventSuccessTitle,
        message: l10n.bulkEventSuccessMessage,
        buttonText: l10n.dialogUnderstood,
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
      ).showSnackBar(SnackBar(content: Text(l10n.errorPrefix('$e'))));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  String _keyFromIds(List<int> ids) {
    final sorted = [...ids]..sort();
    return sorted.join(',');
  }

  String _categoryTitle(BulkCattleCategory category, AppLocalizations l10n) {
    switch (category) {
      case BulkCattleCategory.cow:
        return l10n.rationCategoryCow;
      case BulkCattleCategory.bull:
        return l10n.rationCategoryBull;
      case BulkCattleCategory.heifer:
        return l10n.rationCategoryHeifer;
      case BulkCattleCategory.calf:
        return l10n.rationCategoryCalf;
      case BulkCattleCategory.fattening:
        return l10n.prodStateFattening;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
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
      farmName: l10n.farmName,
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
                          Expanded(
                            child: Text(
                              l10n.addBulkEventTitle,
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

                      Text(
                        l10n.animalCategory,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: AppColors.primary3,
                        ),
                      ),
                      const SizedBox(height: 6),

                      DropdownButtonFormField<BulkCattleCategory>(
                        initialValue: _category,
                        decoration: _dec(hint: l10n.selectCategoryHint),
                        items: BulkCattleCategory.values
                            .map(
                              (c) => DropdownMenuItem(
                                value: c,
                                child: Text(_categoryTitle(c, l10n)),
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

                      Text(
                        l10n.selectCattleTitle,
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
                        error: (e, _) => Text(l10n.errorLoadingData('$e')),
                        data: (list) {
                          final hint = _selectedIds.isEmpty
                              ? l10n.selectCattleTitle
                              : l10n.selectCattleSelected(_selectedIds.length);

                          return SizedBox(
                            height: 48,
                            width: double.infinity,
                            child: OutlinedButton(
                              onPressed: _saving || list.isEmpty
                                  ? null
                                  : _openSelectCattleSheet,
                              style: OutlinedButton.styleFrom(
                                side: BorderSide.none,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(40),
                                ),
                                backgroundColor: const Color.fromARGB(
                                  255,
                                  239,
                                  239,
                                  239,
                                ),
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

                      Text(
                        l10n.addEventType,
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
                        error: (e, _) => Text(l10n.errorTypes('$e')),
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
                                            ? l10n.selectCattleTitle
                                            : l10n.eventsNone)
                                      : l10n.addEventDropdownHint,
                                ),
                                items: filteredTypes
                                    .map(
                                      (t) => DropdownMenuItem(
                                        value: t,
                                        child: Text(
                                          CattleEventTypeX.labelFromApi(
                                            t,
                                            l10n,
                                            unknownAsRaw: true,
                                          ),
                                        ),
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
                                  label: _dateLabelForType(_eventType, l10n),
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
                                        helpText: l10n.eventsDateEnd,
                                      ),
                                heatStartCtrl: _heatStartCtrl,
                                onPickHeatStart: _saving
                                    ? null
                                    : () => _pickDateTo(
                                        onPicked: (d) => _heatStart = d,
                                        ctrl: _heatStartCtrl,
                                        helpText: l10n.fieldHeatStartDate,
                                      ),
                                heatEndCtrl: _heatEndCtrl,
                                onPickHeatEnd: _saving
                                    ? null
                                    : () => _pickDateTo(
                                        onPicked: (d) => _heatEnd = d,
                                        ctrl: _heatEndCtrl,
                                        helpText: l10n.fieldHeatEndDate,
                                      ),
                                treatmentDaysValue: _treatmentDays,
                                onMinusTreatmentDays: _saving
                                    ? () {}
                                    : () {
                                        setState(() {
                                          if (_treatmentDays > 1) {
                                            _treatmentDays--;
                                          }
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

                      Text(
                        l10n.addEventComment,
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
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                ),
                                child: Text(
                                  l10n.dialogCancel,
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
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                ),
                                child: Text(_saving ? l10n.saving : l10n.save),
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

String _dateLabelForType(String? t, AppLocalizations l10n) {
  switch (t) {
    case 'VACCINATION':
      return l10n.eventDateVaccination;
    case 'ANTIPARASITIC_TREATMENT':
      return l10n.eventDateTreatment;
    case 'ILLNESS_TREATMENT':
      return l10n.eventDateIllness;
    case 'WEIGHING':
      return l10n.eventDateWeighing;
    case 'INSEMINATION':
      return l10n.eventDateInsemination;
    case 'MATING':
      return l10n.eventDateCheck;
    case 'CALVING':
      return l10n.eventDateCalving;
    case 'PREGNANCY_CONFIRMATION':
      return l10n.eventDatePregnancy;
    case 'HEAT_PERIOD':
      return l10n.eventDateStart;
    case 'SYNCHRONIZATION':
      return l10n.eventDateSync;
    case 'DRY_PERIOD':
      return l10n.eventDateStart;
    case 'WEANING':
      return l10n.eventDateWeaning;
    case 'HOOF_TRIMMING':
      return l10n.eventDateHoofTrimming;
    case 'OTHER':
      return l10n.eventDateGeneric;
    default:
      return l10n.eventDateGeneric;
  }
}
