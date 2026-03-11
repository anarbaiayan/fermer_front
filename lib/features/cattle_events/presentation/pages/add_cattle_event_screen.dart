import 'package:flutter/material.dart';
import 'package:frontend/core/icons/app_icons.dart';
import 'package:frontend/core/localization/l10n_extension.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/widgets/app_scaffold.dart';
import 'package:frontend/core/widgets/masked_date_picker.dart';
import 'package:frontend/core/widgets/page_header.dart';
import 'package:frontend/features/herd/application/herd_providers.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:frontend/l10n/app_localizations.dart';

import '../../application/cattle_events_providers.dart';
import '../../data/models/create_cattle_event_dto.dart';
import '../../domain/entities/cattle_event_type.dart';
import '../widgets/dynamic_event_fields.dart';

class AddCattleEventScreen extends ConsumerStatefulWidget {
  final int cattleId;
  const AddCattleEventScreen({super.key, required this.cattleId});

  @override
  ConsumerState<AddCattleEventScreen> createState() =>
      _AddCattleEventScreenState();
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

    case 'PREGNANCY_NOT_CONFIRMED':
      return l10n.eventDateCheck;

    case 'HORN_PROCESSING':
      return l10n.eventDateHornProcessing;

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

class _AddCattleEventScreenState extends ConsumerState<AddCattleEventScreen> {
  final _ymd = DateFormat('yyyy-MM-dd');
  final _dmy = DateFormat('dd.MM.yyyy');
  int _treatmentDays = 7;

  bool _saving = false;
  bool? _matingSuccess;

  String? _eventType;

  DateTime? _eventDate;
  final _eventDateCtrl = TextEditingController();

  final _notesCtrl = TextEditingController();
  final _customTypeCtrl = TextEditingController();

  // динамические контроллеры
  final _vaccineNameCtrl = TextEditingController();
  final _diagnosisCtrl = TextEditingController();
  final _treatmentDaysCtrl = TextEditingController();
  final _drugNameCtrl = TextEditingController();
  final _dosageCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();
  final _bullNameCtrl = TextEditingController();
  final _bullTagCtrl = TextEditingController();
  final _calfTagCtrl = TextEditingController();
  final _calfNameCtrl = TextEditingController();
  final _calfBirthWeightCtrl = TextEditingController();
  String? _calfGender;

  String? _calvingDifficulty;

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
    _calfTagCtrl.dispose();
    _calfNameCtrl.dispose();
    _calfBirthWeightCtrl.dispose();

    _endDateCtrl.dispose();
    _heatStartCtrl.dispose();
    _heatEndCtrl.dispose();
    super.dispose();
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
    _calfTagCtrl.clear();
    _calfNameCtrl.clear();
    _calfBirthWeightCtrl.clear();
    _calfGender = null;

    _calvingDifficulty = null;

    _endDate = null;
    _endDateCtrl.clear();

    _heatStart = null;
    _heatStartCtrl.clear();

    _heatEnd = null;
    _heatEndCtrl.clear();

    _customTypeCtrl.clear();
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
      data['calfTag'] = nn(_calfTagCtrl.text);
      data['calfName'] = nn(_calfNameCtrl.text);
      data['calfGender'] = _calfGender;
      data['calfBirthWeight'] = dd(_calfBirthWeightCtrl.text);
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

  Future<void> _submit() async {
    final l10n = context.l10n;
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

    if (_eventType == 'OTHER' && _customTypeCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.addEventEnterName)));
      return;
    }
    if (_eventType == 'HEAT_PERIOD' && _heatStart == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.addEventSelectHeatStart)));
      return;
    }

    if (_eventType == 'CALVING') {
      if (_calfTagCtrl.text.trim().isEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.addEventEnterCalfTag)));
        return;
      }
      if (_calfGender == null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.addEventSelectCalfGender)));
        return;
      }
      if (double.tryParse(
            _calfBirthWeightCtrl.text.trim().replaceAll(',', '.'),
          ) ==
          null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(l10n.addEventEnterCalfWeight)));
        return;
      }
    }

    setState(() => _saving = true);

    try {
      final eventData = _buildEventData();

      final dto = CreateCattleEventDto(
        eventDate: _ymd.format(
          _eventType == 'HEAT_PERIOD' ? _heatStart! : _eventDate!,
        ),
        eventType: _eventType!,
        notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
        eventData: eventData.isEmpty ? null : eventData,
      );

      final create = ref.read(createCattleEventProvider);
      await create(widget.cattleId, dto);

      // чтобы сразу обновилось превью
      ref.invalidate(cattleEventsPreviewProvider(widget.cattleId));
      ref.invalidate(cattleDetailsProvider(widget.cattleId));
      ref.invalidate(cattleByIdProvider(widget.cattleId));
      ref.invalidate(cattleStatisticsProvider);
      ref.invalidate(cattleListProvider);

      if (!mounted) return;
      Navigator.of(context).pop(true);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.eventsAdded)));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.errorAddingEvent('$e'))));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final typesAsync = ref.watch(
      cattleAvailableEventTypesProvider(widget.cattleId),
    );

    return AppScaffold(
      bottomNavIndex: null,
      enableDrawer: false,
      backgroundColor: AppColors.primary1,
      farmName: l10n.farmName,
      body: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
        child: Container(
          color: AppColors.background,
          child: SafeArea(
            top: false,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final keyboardInset = MediaQuery.of(context).viewInsets.bottom;

                return SingleChildScrollView(
                  // ключевое - скролл учитывает клавиатуру
                  padding: EdgeInsets.only(bottom: keyboardInset),
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: IntrinsicHeight(
                      child: Column(
                        children: [
                          const SizedBox(height: 26),
                          Padding(
                            padding: const EdgeInsets.only(left: 16),
                            child: HerdPageHeader(
                              title: l10n.addEventTitle,
                              onBack: () => context.pop(),
                            ),
                          ),
                          const SizedBox(height: 12),

                          // контент
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
                              child: typesAsync.when(
                                loading: () => const Center(
                                  child: CircularProgressIndicator(),
                                ),
                                error: (e, _) => Text(l10n.errorTypes('$e')),
                                data: (types) {
                                  // твой текущий Column с полями - без изменений
                                  // просто верни его отсюда
                                  final parsed = types
                                      .map(
                                        (raw) => CattleEventTypeX.fromApi(raw),
                                      )
                                      .whereType<CattleEventType>()
                                      .where((t) => !t.isSystem)
                                      .toList();

                                  final fallbackRaw = types
                                      .where(
                                        (raw) =>
                                            raw.startsWith('SYSTEM_') == false,
                                      )
                                      .where(
                                        (raw) =>
                                            CattleEventTypeX.fromApi(raw) ==
                                            null,
                                      )
                                      .toList();

                                  final allowedRaw = types
                                      .where((s) => !s.startsWith('SYSTEM_'))
                                      .toList();

                                  final dropdownValue =
                                      (_eventType != null &&
                                          allowedRaw.contains(_eventType))
                                      ? _eventType
                                      : (allowedRaw.isNotEmpty
                                            ? allowedRaw.first
                                            : null);

                                  if (_eventType == null &&
                                      dropdownValue != null) {
                                    _eventType = dropdownValue;
                                  }

                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        l10n.addEventType,
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                          color: AppColors.primary3,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      DropdownButtonFormField<String>(
                                        initialValue: dropdownValue,
                                        decoration: _dec(
                                          hint: l10n.addEventDropdownHint,
                                        ),
                                        items: [
                                          ...parsed.map(
                                            (t) => DropdownMenuItem(
                                              value: t.apiValue,
                                              child: Text(
                                                t.localizedLabel(l10n),
                                              ),
                                            ),
                                          ),
                                          ...fallbackRaw.map(
                                            (raw) => DropdownMenuItem(
                                              value: raw,
                                              child: Text(raw),
                                            ),
                                          ),
                                        ],
                                        onChanged: _saving
                                            ? null
                                            : (v) {
                                                setState(() {
                                                  _eventType = v;
                                                  _resetDynamicFieldsOnTypeChange();
                                                });
                                              },
                                      ),
                                      const SizedBox(height: 22),

                                      if (_eventType != 'HEAT_PERIOD') ...[
                                        _LabeledRightField(
                                          label: _dateLabelForType(
                                            _eventType,
                                            l10n,
                                          ),
                                          field: TextField(
                                            controller: _eventDateCtrl,
                                            readOnly: true,
                                            onTap: _saving
                                                ? null
                                                : _pickEventDate,
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
                                        const SizedBox(height: 24),
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
                                        calfTagCtrl: _calfTagCtrl,
                                        calfNameCtrl: _calfNameCtrl,
                                        calfGender: _calfGender,
                                        onCalfGenderChanged: (v) =>
                                            setState(() => _calfGender = v),
                                        calfBirthWeightCtrl:
                                            _calfBirthWeightCtrl,
                                        onCalvingDifficultyChanged: (v) =>
                                            setState(
                                              () => _calvingDifficulty = v,
                                            ),
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
                                                helpText:
                                                    l10n.fieldHeatStartDate,
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
                                            _dec(
                                              hint: hint,
                                              prefixIcon: prefixIcon,
                                            ),
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
                                    ],
                                  );
                                },
                              ),
                            ),
                          ),

                          // кнопки теперь часть скролла, и клавиатура их не ломает
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                            child: Row(
                              children: [
                                Expanded(
                                  child: SizedBox(
                                    height: 48,
                                    child: OutlinedButton(
                                      onPressed: _saving
                                          ? null
                                          : () => Navigator.of(context).pop(),
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
                                          borderRadius: BorderRadius.circular(
                                            24,
                                          ),
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
                                          borderRadius: BorderRadius.circular(
                                            24,
                                          ),
                                        ),
                                      ),
                                      child: Text(
                                        _saving ? l10n.saving : l10n.save,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 16,
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
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
