import 'package:flutter/material.dart';
import 'package:frontend/features/cattle_events/presentation/widgets/dynamic_event_fields.dart';
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

  final _customTypeCtrl = TextEditingController();

  bool _saving = false;

  String? _eventType;

  DateTime? _eventDate;
  final _eventDateCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  // динамические контроллеры
  final _vaccineNameCtrl = TextEditingController();
  final _diagnosisCtrl = TextEditingController();
  final _treatmentDaysCtrl = TextEditingController();
  final _drugNameCtrl = TextEditingController();
  final _dosageCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();
  final _bullNameCtrl = TextEditingController();
  final _bullTagCtrl = TextEditingController();

  bool? _pregnancyResult;
  String? _calvingDifficulty;

  DateTime? _endDate;
  final _endDateCtrl = TextEditingController();

  DateTime? _heatStart;
  final _heatStartCtrl = TextEditingController();

  DateTime? _heatEnd;
  final _heatEndCtrl = TextEditingController();

  @override
  void dispose() {
    _eventDateCtrl.dispose();
    _notesCtrl.dispose();

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

    _customTypeCtrl.dispose();
    super.dispose();
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
    _vaccineNameCtrl.clear();
    _diagnosisCtrl.clear();
    _treatmentDaysCtrl.clear();
    _drugNameCtrl.clear();
    _dosageCtrl.clear();
    _weightCtrl.clear();
    _bullNameCtrl.clear();
    _bullTagCtrl.clear();

    _pregnancyResult = null;
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

    String? nn(String v) => v.trim().isEmpty ? null : v.trim();
    int? ii(String v) => int.tryParse(v.trim());
    double? dd(String v) => double.tryParse(v.trim().replaceAll(',', '.'));

    final data = <String, dynamic>{};

    if (t == null) return data;

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
      data['calvingDifficulty'] = _calvingDifficulty; // EASY|MEDIUM|HARD
      data['bullName'] = nn(_bullNameCtrl.text);
      data['bullTagNumber'] = nn(_bullTagCtrl.text);
    }

    if (t == 'PREGNANCY_CONFIRMATION') {
      if (_pregnancyResult != null) data['pregnancyResult'] = _pregnancyResult;
    }

    if (t == 'HEAT_PERIOD') {
      if (_heatStart != null) data['heatStartDate'] = _ymd.format(_heatStart!);
      if (_heatEnd != null) data['heatEndDate'] = _ymd.format(_heatEnd!);
    }

    if (t == 'SYNCHRONIZATION') {
      // Минимально: препарат/дозировка (если бэк потом расширит - добавим)
      data['drugName'] = nn(_drugNameCtrl.text);
      data['dosage'] = nn(_dosageCtrl.text);
    }

    if (t == 'OTHER') {
      // "свой тип", но eventType остается OTHER
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
    if (_eventDate == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Выберите дату события')));
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
        eventDate: _ymd.format(_eventDate!),
        eventType: _eventType!,
        notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
        eventData: eventData.isEmpty ? null : eventData,
      );

      final create = ref.read(createCattleEventProvider);
      await create(widget.cattleId, dto);

      if (!mounted) return;
      Navigator.of(context).pop();
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

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Добавить событие',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 12),

            typesAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: CircularProgressIndicator(),
              ),
              error: (e, _) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text('Ошибка типов: $e'),
              ),
              data: (types) {
                final parsed = types
                    .map((raw) => CattleEventTypeX.fromApi(raw))
                    .whereType<CattleEventType>()
                    .toList();

                // если бэк вдруг отдаст неизвестное - оставим raw fallback
                final fallbackRaw = types
                    .where((raw) => CattleEventTypeX.fromApi(raw) == null)
                    .toList();

                final dropdownValue =
                    (_eventType != null && types.contains(_eventType))
                    ? _eventType
                    : (types.isNotEmpty ? types.first : null);

                if (_eventType == null && dropdownValue != null) {
                  _eventType = dropdownValue; // важно
                }

                return Column(
                  children: [
                    // Тип
                    DropdownButtonFormField<String>(
                      initialValue: dropdownValue,
                      items: [
                        ...parsed.map(
                          (t) => DropdownMenuItem(
                            value: t.apiValue,
                            child: Text(t.display),
                          ),
                        ),
                        ...fallbackRaw.map(
                          (raw) =>
                              DropdownMenuItem(value: raw, child: Text(raw)),
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
                      decoration: const InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(),
                        labelText: 'Тип события',
                      ),
                    ),

                    const SizedBox(height: 12),

                    // Дата (общая)
                    TextField(
                      controller: _eventDateCtrl,
                      readOnly: true,
                      onTap: _saving ? null : _pickEventDate,
                      decoration: const InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(),
                        labelText: 'Дата события',
                      ),
                    ),

                    const SizedBox(height: 12),

                    // динамика
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
                      pregnancyResult: _pregnancyResult,
                      customTypeCtrl: _customTypeCtrl,
                      onPregnancyResultChanged: (v) =>
                          setState(() => _pregnancyResult = v),
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
                    ),

                    const SizedBox(height: 12),

                    // notes (общие)
                    TextField(
                      controller: _notesCtrl,
                      minLines: 2,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(),
                        labelText: 'Заметки',
                        hintText: 'Например: все прошло хорошо',
                      ),
                    ),

                    const SizedBox(height: 14),

                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _saving
                                ? null
                                : () => Navigator.of(context).pop(),
                            child: const Text('Отмена'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _saving ? null : _submit,
                            child: Text(
                              _saving ? 'Сохранение...' : 'Сохранить',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
