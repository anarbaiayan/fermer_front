import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_colors.dart';

class DaysStepperField extends StatelessWidget {
  final String label;
  final int value;
  final VoidCallback onMinus;
  final VoidCallback onPlus;

  const DaysStepperField({
    super.key,
    required this.label,
    required this.value,
    required this.onMinus,
    required this.onPlus,
  });

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

        // справа - кнопки и поле
        Row(
          children: [
            _StepBtn(icon: '-', onTap: onMinus),
            const SizedBox(width: 10),
            Container(
              width: 110,
              height: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppColors.additional2),
              ),
              child: Text(
                '$value дней',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.primary3,
                ),
              ),
            ),
            const SizedBox(width: 10),
            _StepBtn(icon: '+', onTap: onPlus),
          ],
        ),
      ],
    );
  }
}

class _StepBtn extends StatelessWidget {
  final String icon;
  final VoidCallback onTap;

  const _StepBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(10),
      onTap: onTap,
      child: Container(
        width: 34,
        height: 34,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: const Color(0xFFE5E7EB), // как на фото (серый)
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          icon,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.background,
          ),
        ),
      ),
    );
  }
}
