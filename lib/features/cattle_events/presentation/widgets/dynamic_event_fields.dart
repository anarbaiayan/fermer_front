import 'package:flutter/material.dart';

class DynamicEventFields extends StatelessWidget {
  final String? eventType;

  final TextEditingController vaccineNameCtrl;
  final TextEditingController diagnosisCtrl;
  final TextEditingController treatmentDaysCtrl;
  final TextEditingController drugNameCtrl;
  final TextEditingController dosageCtrl;
  final TextEditingController weightCtrl;
  final TextEditingController bullNameCtrl;
  final TextEditingController bullTagCtrl;
  final TextEditingController customTypeCtrl;

  final bool? pregnancyResult;
  final void Function(bool? v) onPregnancyResultChanged;

  final String? calvingDifficulty;
  final void Function(String? v) onCalvingDifficultyChanged;

  final TextEditingController endDateCtrl;
  final VoidCallback? onPickEndDate;

  final TextEditingController heatStartCtrl;
  final VoidCallback? onPickHeatStart;

  final TextEditingController heatEndCtrl;
  final VoidCallback? onPickHeatEnd;

  const DynamicEventFields({
    super.key,
    required this.eventType,
    required this.vaccineNameCtrl,
    required this.diagnosisCtrl,
    required this.treatmentDaysCtrl,
    required this.drugNameCtrl,
    required this.dosageCtrl,
    required this.weightCtrl,
    required this.bullNameCtrl,
    required this.bullTagCtrl,
    required this.pregnancyResult,
    required this.onPregnancyResultChanged,
    required this.calvingDifficulty,
    required this.onCalvingDifficultyChanged,
    required this.endDateCtrl,
    required this.onPickEndDate,
    required this.heatStartCtrl,
    required this.onPickHeatStart,
    required this.heatEndCtrl,
    required this.onPickHeatEnd,
    required this.customTypeCtrl,
  });

  InputDecoration _dec(String label, {String? hint}) => InputDecoration(
    filled: true,
    fillColor: Colors.white,
    border: const OutlineInputBorder(),
    labelText: label,
    hintText: hint,
  );

  @override
  Widget build(BuildContext context) {
    final t = eventType;

    if (t == null) return const SizedBox.shrink();

    // ВАЖНО: мы не хардкодим категории - только тип события.
    // Доступные типы придут от бэка (available-types).
    if (t == 'VACCINATION') {
      return Column(
        children: [
          TextField(
            controller: vaccineNameCtrl,
            decoration: _dec(
              'Название вакцины',
              hint: 'Например: Против бруцеллёза',
            ),
          ),
        ],
      );
    }

    if (t == 'WEIGHING') {
      return Column(
        children: [
          TextField(
            controller: weightCtrl,
            keyboardType: TextInputType.number,
            decoration: _dec('Вес (кг)', hint: 'Например: 520.5'),
          ),
        ],
      );
    }

    if (t == 'ILLNESS_TREATMENT') {
      return Column(
        children: [
          TextField(
            controller: diagnosisCtrl,
            decoration: _dec('Диагноз', hint: 'Например: Мастит'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: drugNameCtrl,
            decoration: _dec('Препарат', hint: 'Например: Эстрофан'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: dosageCtrl,
            decoration: _dec('Дозировка', hint: 'Например: 2'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: treatmentDaysCtrl,
            keyboardType: TextInputType.number,
            decoration: _dec('Дней лечения', hint: 'Например: 7'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: endDateCtrl,
            readOnly: true,
            onTap: onPickEndDate,
            decoration: _dec('Дата окончания', hint: 'Выберите дату'),
          ),
        ],
      );
    }

    if (t == 'ANTIPARASITIC_TREATMENT') {
      return Column(
        children: [
          TextField(
            controller: drugNameCtrl,
            decoration: _dec('Препарат', hint: 'Например: Ивермектин'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: dosageCtrl,
            decoration: _dec('Дозировка', hint: 'Например: 2'),
          ),
        ],
      );
    }

    if (t == 'INSEMINATION' || t == 'MATING') {
      return Column(
        children: [
          TextField(
            controller: bullNameCtrl,
            decoration: _dec('Имя отца', hint: 'Например: Богатырь'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: bullTagCtrl,
            decoration: _dec('Бирка отца', hint: 'Например: BULL-001'),
          ),
        ],
      );
    }

    if (t == 'CALVING') {
      return Column(
        children: [
          DropdownButtonFormField<String>(
            initialValue: calvingDifficulty,
            items: const [
              'EASY',
              'MEDIUM',
              'HARD',
            ].map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
            onChanged: onCalvingDifficultyChanged,
            decoration: _dec('Сложность отела', hint: 'Выберите'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: bullNameCtrl,
            decoration: _dec('Имя отца', hint: 'Например: Богатырь'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: bullTagCtrl,
            decoration: _dec('Бирка отца', hint: 'Например: BULL-001'),
          ),
        ],
      );
    }

    if (t == 'PREGNANCY_CONFIRMATION') {
      return DropdownButtonFormField<bool>(
        initialValue: pregnancyResult,
        items: const [
          DropdownMenuItem(value: true, child: Text('Беременна')),
          DropdownMenuItem(value: false, child: Text('Не беременна')),
        ],
        onChanged: onPregnancyResultChanged,
        decoration: _dec('Результат проверки'),
      );
    }

    if (t == 'HEAT_PERIOD') {
      return Column(
        children: [
          TextField(
            controller: heatStartCtrl,
            readOnly: true,
            onTap: onPickHeatStart,
            decoration: _dec('Начало охоты', hint: 'Выберите дату'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: heatEndCtrl,
            readOnly: true,
            onTap: onPickHeatEnd,
            decoration: _dec('Конец охоты', hint: 'Выберите дату'),
          ),
        ],
      );
    }

    if (t == 'SYNCHRONIZATION') {
      return Column(
        children: [
          TextField(
            controller: drugNameCtrl,
            decoration: _dec('Препарат', hint: 'Например: Овсинх'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: dosageCtrl,
            decoration: _dec('Дозировка', hint: 'Например: 2'),
          ),
        ],
      );
    }

    if (t == 'OTHER') {
      return Column(
        children: [
          TextField(
            controller: customTypeCtrl,
            decoration: _dec(
              'Название события',
              hint: 'Например: Переезд в другую группу',
            ),
          ),
        ],
      );
    }

    // DRY_PERIOD, WEANING, HOOF_TRIMMING - без доп полей (только дата + заметки)
    return const SizedBox.shrink();
  }
}
