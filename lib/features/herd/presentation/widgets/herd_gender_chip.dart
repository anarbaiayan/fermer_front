import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_colors.dart';

class HerdGenderChip extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;

  const HerdGenderChip({
    super.key,
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final background = isActive ? AppColors.primary1 : AppColors.additional2;
    final textColor = isActive ? Colors.white : AppColors.primary3;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 36,
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: textColor,
          ),
        ),
      ),
    );
  }
}
