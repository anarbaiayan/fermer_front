import 'package:flutter/material.dart';
import 'package:frontend/core/localization/l10n_extension.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/features/cattle_events/presentation/widgets/days_stepper_field.dart';

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
  final TextEditingController? calfTagCtrl;
  final TextEditingController? calfNameCtrl;
  final String? calfGender;
  final void Function(String? v)? onCalfGenderChanged;
  final TextEditingController? calfBirthWeightCtrl;

  final String? calvingDifficulty;
  final void Function(String? v) onCalvingDifficultyChanged;

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
    this.calfTagCtrl,
    this.calfNameCtrl,
    this.calfGender,
    this.onCalfGenderChanged,
    this.calfBirthWeightCtrl,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final t = eventType;
    if (t == null) return const SizedBox.shrink();

    if (t == 'VACCINATION') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FieldTitle(l10n.fieldVaccine),
          TextField(
            controller: vaccineNameCtrl,
            decoration: dec(hint: l10n.fieldVaccineHint),
          ),
          const SizedBox(height: 24),
        ],
      );
    }

    if (t == 'WEIGHING') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FieldTitle(l10n.fieldWeightKg),
          TextField(
            controller: weightCtrl,
            keyboardType: TextInputType.number,
            decoration: dec(hint: l10n.fieldWeightHint),
          ),
          const SizedBox(height: 24),
        ],
      );
    }

    if (t == 'ILLNESS_TREATMENT') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FieldTitle(l10n.fieldDiagnosis),
          TextField(
            controller: diagnosisCtrl,
            decoration: dec(hint: l10n.fieldDiagnosisHint),
          ),
          const SizedBox(height: 12),

          FieldTitle(l10n.fieldDrug),
          TextField(
            controller: drugNameCtrl,
            decoration: dec(hint: l10n.fieldDrugHint),
          ),
          const SizedBox(height: 12),

          FieldTitle(l10n.fieldDosage),
          TextField(
            controller: dosageCtrl,
            decoration: dec(hint: l10n.fieldDosageHint),
          ),
          const SizedBox(height: 12),

          DaysStepperField(
            label: l10n.fieldTreatmentDuration,
            value: treatmentDaysValue,
            onMinus: onMinusTreatmentDays,
            onPlus: onPlusTreatmentDays,
          ),

          const SizedBox(height: 24),

          // оставляем как было (не labeledRight), потому что у тебя в макете так
          FieldTitle(l10n.fieldEndDate),
          TextField(
            controller: endDateCtrl,
            readOnly: true,
            onTap: onPickEndDate,
            decoration: dec(
              hint: l10n.fieldSelectDate,
              prefixIcon: calendarIcon,
            ),
          ),
          const SizedBox(height: 24),
        ],
      );
    }

    if (t == 'ANTIPARASITIC_TREATMENT') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FieldTitle(l10n.fieldDrug),
          TextField(
            controller: drugNameCtrl,
            decoration: dec(hint: l10n.fieldDrugHint),
          ),
          const SizedBox(height: 12),

          FieldTitle(l10n.fieldDosage),
          TextField(
            controller: dosageCtrl,
            decoration: dec(hint: l10n.fieldDosageHint),
          ),
          const SizedBox(height: 24),
        ],
      );
    }

    if (t == 'INSEMINATION') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FieldTitle(l10n.fieldMaleTag),
          TextField(
            controller: bullTagCtrl,
            decoration: dec(hint: l10n.fieldEnterTagNumber),
          ),
          const SizedBox(height: 24),
        ],
      );
    }

    if (t == 'MATING') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FieldTitle(l10n.fieldFemaleTag),
          TextField(
            controller: bullTagCtrl,
            decoration: dec(hint: l10n.fieldEnterTagNumber),
          ),
          const SizedBox(height: 24),

          FieldTitle(l10n.fieldSuccess),
          Row(
            children: [
              Expanded(
                child: _ChoiceRadioTile(
                  title: l10n.fieldSuccessful,
                  value: true,
                  groupValue: matingSuccess,
                  onChanged: (v) => onMatingSuccessChanged(v),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _ChoiceRadioTile(
                  title: l10n.fieldUnsuccessful,
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
          FieldTitle(l10n.fieldDifficulty),
          Row(
            children: [
              Expanded(
                child: _ChoiceRadioTile<String>(
                  title: l10n.fieldEasy,
                  value: 'EASY',
                  groupValue: calvingDifficulty,
                  onChanged: onCalvingDifficultyChanged,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _ChoiceRadioTile<String>(
                  title: l10n.fieldMedium,
                  value: 'MEDIUM',
                  groupValue: calvingDifficulty,
                  onChanged: onCalvingDifficultyChanged,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _ChoiceRadioTile<String>(
                  title: l10n.fieldHard,
                  value: 'HARD',
                  groupValue: calvingDifficulty,
                  onChanged: onCalvingDifficultyChanged,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          FieldTitle(l10n.fieldCalfTag),
          TextField(
            controller: calfTagCtrl,
            decoration: dec(hint: l10n.fieldCalfTagHint),
          ),
          const SizedBox(height: 12),

          FieldTitle(l10n.fieldCalfName),
          TextField(
            controller: calfNameCtrl,
            decoration: dec(hint: l10n.fieldCalfNameHint),
          ),
          const SizedBox(height: 12),

          FieldTitle(l10n.fieldCalfGender),
          DropdownButtonFormField<String>(
            value: calfGender,
            decoration: dec(hint: l10n.fieldCalfGenderHint),
            items: [
              DropdownMenuItem(value: 'MALE', child: Text(l10n.fieldMale)),
              DropdownMenuItem(value: 'FEMALE', child: Text(l10n.fieldFemale)),
            ],
            onChanged: onCalfGenderChanged,
          ),
          const SizedBox(height: 12),

          FieldTitle(l10n.fieldBirthWeight),
          TextField(
            controller: calfBirthWeightCtrl,
            keyboardType: TextInputType.number,
            decoration: dec(hint: l10n.fieldBirthWeightHint),
          ),

          const SizedBox(height: 24),
        ],
      );
    }

    if (t == 'PREGNANCY_CONFIRMATION' || t == 'PREGNANCY_NOT_CONFIRMED') {
      return const SizedBox(height: 24);
    }

    // ✅ HEAT_PERIOD - только начало/конец и в стиле "слева текст - справа инпут"
    if (t == 'HEAT_PERIOD') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          labeledRightField(
            label: l10n.fieldHeatStart,
            field: TextField(
              controller: heatStartCtrl,
              readOnly: true,
              onTap: onPickHeatStart,
              decoration: dec(hint: '31.12.2025', prefixIcon: calendarIcon),
            ),
          ),
          const SizedBox(height: 12),
          labeledRightField(
            label: l10n.fieldHeatEnd,
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
          FieldTitle(l10n.fieldDrug),
          TextField(
            controller: drugNameCtrl,
            decoration: dec(hint: l10n.fieldDrugNameHint),
          ),
          const SizedBox(height: 12),

          FieldTitle(l10n.fieldDosage),
          TextField(
            controller: dosageCtrl,
            decoration: dec(hint: l10n.fieldDosageHint2),
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
            label: l10n.fieldEndDateOptional,
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
          FieldTitle(l10n.fieldEventName),
          TextField(
            controller: customTypeCtrl,
            decoration: dec(hint: l10n.addEventEnterName),
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
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 20,
              height: 20,
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
                      child: Icon(Icons.check, size: 12, color: Colors.white),
                    )
                  : null,
            ),
            const SizedBox(width: 6),

            // ✅ текст всегда ужимается и не дает overflow
            Expanded(
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  title,
                  maxLines: 1,
                  softWrap: false,
                  overflow: TextOverflow.visible,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: selected
                        ? AppColors.primary3
                        : AppColors.additional3,
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
