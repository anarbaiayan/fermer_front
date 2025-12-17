import 'package:flutter/material.dart';
import 'package:frontend/core/icons/app_icons.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/features/cattle_events/presentation/widgets/dynamic_event_fields.dart';
import 'package:frontend/features/herd/domain/entities/pregnancy_status.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import '../../application/cattle_events_providers.dart';
import '../../data/models/create_cattle_event_dto.dart';
import '../../domain/entities/cattle_event_type.dart';

class AddCattleEventSheet extends ConsumerStatefulWidget {
  final int cattleId;
  const AddCattleEventSheet({super.key, required this.cattleId});

  @override
  ConsumerState<AddCattleEventSheet> createState() =>
      _AddCattleEventSheetState();
}

class _AddCattleEventSheetState extends ConsumerState<AddCattleEventSheet> {
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

  // dynamic controllers
  final _vaccineNameCtrl = TextEditingController();
  final _diagnosisCtrl = TextEditingController();
  final _treatmentDaysCtrl = TextEditingController();
  final _drugNameCtrl = TextEditingController();
  final _dosageCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();
  final _bullNameCtrl = TextEditingController();
  final _bullTagCtrl = TextEditingController();

  PregnancyStatus? _pregnancyStatus;
  String? _calvingDifficulty;

  DateTime? _endDate;
  final _endDateCtrl = TextEditingController();

  DateTime? _heatStart;
  final _heatStartCtrl = TextEditingController();

  DateTime? _heatEnd;
  final _heatEndCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _syncTreatmentDaysCtrl();
  }

  void _syncTreatmentDaysCtrl() {
    _treatmentDaysCtrl.text = _treatmentDays.toString();
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
    final picked = await showDatePicker(
      context: context,
      initialDate: _eventDate ?? now,
      firstDate: DateTime(now.year - 20),
      lastDate: DateTime(now.year + 5),
      helpText: 'Выберите дату события',
    );
    if (picked == null) return;
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
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(now.year - 20),
      lastDate: DateTime(now.year + 5),
      helpText: helpText,
    );
    if (picked == null) return;
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

    _pregnancyStatus = null;
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
      data['bullTagNumber'] = nn(_bullTagCtrl.text);
    }

    if (t == 'CALVING') {
      data['calvingDifficulty'] = _calvingDifficulty;
      data['bullName'] = nn(_bullNameCtrl.text);
      data['bullTagNumber'] = nn(_bullTagCtrl.text);
    }

    if (t == 'PREGNANCY_CONFIRMATION') {
      if (_pregnancyStatus != null) {
        data['pregnancyStatus'] = _pregnancyStatus!.apiValue;

        // backward compatibility for backend (если пока только bool)
        if (_pregnancyStatus == PregnancyStatus.pregnant) {
          data['pregnancyResult'] = true;
        } else if (_pregnancyStatus == PregnancyStatus.notPregnant) {
          data['pregnancyResult'] = false;
        }
      }
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

      // как в screen - чтобы обновилось превью/лист сразу
      ref.invalidate(cattleEventsPreviewProvider(widget.cattleId));

      if (!mounted) return;
      context.pop();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Событие добавлено')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка при добавлении события: $e')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final typesAsync = ref.watch(
      cattleAvailableEventTypesProvider(widget.cattleId),
    );
    final keyboardInset = MediaQuery.of(context).viewInsets.bottom;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: keyboardInset > 0 ? keyboardInset + 16 : 16,
        ),
        child: typesAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Ошибка типов: $e')),
          data: (types) {
            final parsed = types
                .map((raw) => CattleEventTypeX.fromApi(raw))
                .whereType<CattleEventType>()
                .toList();

            final fallbackRaw = types
                .where((raw) => CattleEventTypeX.fromApi(raw) == null)
                .toList();

            final dropdownValue =
                (_eventType != null && types.contains(_eventType))
                ? _eventType
                : (types.isNotEmpty ? types.first : null);

            if (_eventType == null && dropdownValue != null) {
              _eventType = dropdownValue;
            }

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Добавить событие',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary3,
                    ),
                  ),
                  const SizedBox(height: 12),

                  const Text(
                    'Событие',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppColors.primary3,
                    ),
                  ),
                  const SizedBox(height: 6),

                  DropdownButtonFormField<String>(
                    initialValue: dropdownValue,
                    decoration: _dec(hint: 'Выбрать из списка'),
                    items: [
                      ...parsed.map(
                        (t) => DropdownMenuItem(
                          value: t.apiValue,
                          child: Text(t.display),
                        ),
                      ),
                      ...fallbackRaw.map(
                        (raw) => DropdownMenuItem(value: raw, child: Text(raw)),
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
                      label: _dateLabelForType(_eventType),
                      field: TextField(
                        controller: _eventDateCtrl,
                        readOnly: true,
                        onTap: _saving ? null : _pickEventDate,
                        decoration: _dec(
                          hint: '31.12.2025',
                          prefixIcon: Padding(
                            padding: const EdgeInsets.only(left: 12, right: 8),
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
                    pregnancyStatus: _pregnancyStatus,
                    customTypeCtrl: _customTypeCtrl,
                    onPregnancyStatusChanged: (v) =>
                        setState(() => _pregnancyStatus = v),
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
                              if (_treatmentDays > 1) _treatmentDays--;
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
                        ({required String label, required Widget field}) =>
                            _LabeledRightField(label: label, field: field),
                    dec: ({required hint, prefixIcon}) =>
                        _dec(hint: hint, prefixIcon: prefixIcon),
                    calendarIcon: Padding(
                      padding: const EdgeInsets.only(left: 12, right: 8),
                      child: AppIcons.svg(
                        'calendar',
                        size: 18,
                        color: AppColors.primary3,
                      ),
                    ),
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

                  const SizedBox(height: 14),

                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 48,
                          child: OutlinedButton(
                            onPressed: _saving ? null : () => context.pop(),
                            style: OutlinedButton.styleFrom(
                              backgroundColor: const Color.fromRGBO(
                                213,
                                215,
                                218,
                                0.6,
                              ),
                              side: const BorderSide(color: Color(0xFFF3F4F6)),
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
                ],
              ),
            );
          },
        ),
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
