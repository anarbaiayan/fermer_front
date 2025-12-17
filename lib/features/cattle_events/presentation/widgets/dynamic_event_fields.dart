import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/features/cattle_events/presentation/widgets/days_stepper_field.dart';
import 'package:frontend/features/herd/domain/entities/pregnancy_status.dart';

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

  final String? calvingDifficulty;
  final void Function(String? v) onCalvingDifficultyChanged;

  final PregnancyStatus? pregnancyStatus;
  final void Function(PregnancyStatus? v) onPregnancyStatusChanged;

  final TextEditingController endDateCtrl;
  final VoidCallback? onPickEndDate;

  final TextEditingController heatStartCtrl;
  final VoidCallback? onPickHeatStart;

  final TextEditingController heatEndCtrl;
  final VoidCallback? onPickHeatEnd;

  final int treatmentDaysValue;
  final VoidCallback onMinusTreatmentDays;
  final VoidCallback onPlusTreatmentDays;

  final bool? matingSuccess;
  final void Function(bool? v) onMatingSuccessChanged;

  // UI helpers from parent (screen/sheet)
  final Widget Function({required String label, required Widget field})
  labeledRightField;
  final InputDecoration Function({required String hint, Widget? prefixIcon})
  dec;
  final Widget calendarIcon;

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
    required this.calvingDifficulty,
    required this.onCalvingDifficultyChanged,
    required this.endDateCtrl,
    required this.onPickEndDate,
    required this.heatStartCtrl,
    required this.onPickHeatStart,
    required this.heatEndCtrl,
    required this.onPickHeatEnd,
    required this.customTypeCtrl,
    required this.treatmentDaysValue,
    required this.onMinusTreatmentDays,
    required this.onPlusTreatmentDays,
    required this.matingSuccess,
    required this.onMatingSuccessChanged,
    required this.labeledRightField,
    required this.dec,
    required this.calendarIcon,
    required this.pregnancyStatus,
    required this.onPregnancyStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    final t = eventType;
    if (t == null) return const SizedBox.shrink();

    if (t == 'VACCINATION') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const FieldTitle('Вакцина'),
          TextField(
            controller: vaccineNameCtrl,
            decoration: dec(hint: 'Наименование вакцины'),
          ),
          const SizedBox(height: 24),
        ],
      );
    }

    if (t == 'WEIGHING') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const FieldTitle('Вес (кг)'),
          TextField(
            controller: weightCtrl,
            keyboardType: TextInputType.number,
            decoration: dec(hint: 'Результат взвешивания'),
          ),
          const SizedBox(height: 24),
        ],
      );
    }

    if (t == 'ILLNESS_TREATMENT') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const FieldTitle('Диагноз'),
          TextField(
            controller: diagnosisCtrl,
            decoration: dec(hint: 'Название заболевания'),
          ),
          const SizedBox(height: 12),

          const FieldTitle('Препарат'),
          TextField(
            controller: drugNameCtrl,
            decoration: dec(hint: 'Название препарата'),
          ),
          const SizedBox(height: 12),

          const FieldTitle('Дозировка'),
          TextField(
            controller: dosageCtrl,
            decoration: dec(hint: 'Количество'),
          ),
          const SizedBox(height: 12),

          DaysStepperField(
            label: 'Длительность лечения (дни)',
            value: treatmentDaysValue,
            onMinus: onMinusTreatmentDays,
            onPlus: onPlusTreatmentDays,
          ),

          const SizedBox(height: 24),

          // оставляем как было (не labeledRight), потому что у тебя в макете так
          const FieldTitle('Дата окончания'),
          TextField(
            controller: endDateCtrl,
            readOnly: true,
            onTap: onPickEndDate,
            decoration: dec(hint: 'Выберите дату', prefixIcon: calendarIcon),
          ),
          const SizedBox(height: 24),
        ],
      );
    }

    if (t == 'ANTIPARASITIC_TREATMENT') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const FieldTitle('Препарат'),
          TextField(
            controller: drugNameCtrl,
            decoration: dec(hint: 'Название препарата'),
          ),
          const SizedBox(height: 12),

          const FieldTitle('Дозировка'),
          TextField(
            controller: dosageCtrl,
            decoration: dec(hint: 'Количество'),
          ),
          const SizedBox(height: 24),
        ],
      );
    }

    if (t == 'INSEMINATION') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const FieldTitle('Бирка самца'),
          TextField(
            controller: bullTagCtrl,
            decoration: dec(hint: 'Укажите номер бирки'),
          ),
          const SizedBox(height: 24),
        ],
      );
    }

    if (t == 'MATING') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const FieldTitle('Бирка самки'),
          TextField(
            controller: bullTagCtrl,
            decoration: dec(hint: 'Укажите номер бирки'),
          ),
          const SizedBox(height: 24),

          const FieldTitle('Успешность'),
          Row(
            children: [
              Expanded(
                child: _ChoiceRadioTile(
                  title: 'Успешно',
                  value: true,
                  groupValue: matingSuccess,
                  onChanged: (v) => onMatingSuccessChanged(v),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _ChoiceRadioTile(
                  title: 'Безуспешно',
                  value: false,
                  groupValue: matingSuccess,
                  onChanged: (v) => onMatingSuccessChanged(v),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],
      );
    }

    if (t == 'CALVING') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const FieldTitle('Сложность'),
          Row(
            children: [
              Expanded(
                child: _ChoiceRadioTile<String>(
                  title: 'Лёгкий',
                  value: 'EASY',
                  groupValue: calvingDifficulty,
                  onChanged: onCalvingDifficultyChanged,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _ChoiceRadioTile<String>(
                  title: 'Средний',
                  value: 'MEDIUM',
                  groupValue: calvingDifficulty,
                  onChanged: onCalvingDifficultyChanged,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _ChoiceRadioTile<String>(
                  title: 'Тяжелый',
                  value: 'HARD',
                  groupValue: calvingDifficulty,
                  onChanged: onCalvingDifficultyChanged,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],
      );
    }

    if (t == 'PREGNANCY_CONFIRMATION') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const FieldTitle('Результат'),
          DropdownButtonFormField<PregnancyStatus>(
            initialValue: pregnancyStatus,
            items: PregnancyStatus.values
                .map((s) => DropdownMenuItem(value: s, child: Text(s.display)))
                .toList(),
            onChanged: onPregnancyStatusChanged,
            decoration: dec(hint: 'Выберите'),
          ),
          const SizedBox(height: 24),
        ],
      );
    }

    // ✅ HEAT_PERIOD - только начало/конец и в стиле "слева текст - справа инпут"
    if (t == 'HEAT_PERIOD') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          labeledRightField(
            label: 'Дата начала',
            field: TextField(
              controller: heatStartCtrl,
              readOnly: true,
              onTap: onPickHeatStart,
              decoration: dec(hint: '31.12.2025', prefixIcon: calendarIcon),
            ),
          ),
          const SizedBox(height: 12),
          labeledRightField(
            label: 'Дата конца',
            field: TextField(
              controller: heatEndCtrl,
              readOnly: true,
              onTap: onPickHeatEnd,
              decoration: dec(hint: '31.12.2025', prefixIcon: calendarIcon),
            ),
          ),
          const SizedBox(height: 24),
        ],
      );
    }

    if (t == 'SYNCHRONIZATION') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const FieldTitle('Препарат'),
          TextField(
            controller: drugNameCtrl,
            decoration: dec(hint: 'Например: Овсинх'),
          ),
          const SizedBox(height: 12),

          const FieldTitle('Дозировка'),
          TextField(
            controller: dosageCtrl,
            decoration: dec(hint: 'Например: 2'),
          ),
          const SizedBox(height: 24),
        ],
      );
    }

    if (t == 'DRY_PERIOD') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          labeledRightField(
            label: 'Дата окончания\n(необязательно)',
            field: TextField(
              controller: endDateCtrl,
              readOnly: true,
              onTap: onPickEndDate,
              decoration: dec(hint: '31.12.2025', prefixIcon: calendarIcon),
            ),
          ),
          const SizedBox(height: 24),
        ],
      );
    }

    if (t == 'OTHER') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const FieldTitle('Название события'),
          TextField(
            controller: customTypeCtrl,
            decoration: dec(hint: 'Например: Переезд в другую группу'),
          ),
          const SizedBox(height: 24),
        ],
      );
    }

    return const SizedBox.shrink();
  }
}

class FieldTitle extends StatelessWidget {
  final String text;
  const FieldTitle(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: AppColors.primary3,
        ),
      ),
    );
  }
}

class _ChoiceRadioTile<T> extends StatelessWidget {
  final String title;
  final T value;
  final T? groupValue;
  final ValueChanged<T?> onChanged;

  const _ChoiceRadioTile({
    required this.title,
    required this.value,
    required this.groupValue,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final selected = groupValue == value;

    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: () => onChanged(value),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected ? AppColors.primary1 : AppColors.additional2,
                  width: 2,
                ),
                color: selected ? AppColors.primary1 : Colors.transparent,
              ),
              child: selected
                  ? const Center(
                      child: Icon(Icons.check, size: 14, color: Colors.white),
                    )
                  : null,
            ),
            const SizedBox(width: 10),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: selected ? AppColors.primary3 : AppColors.additional3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
