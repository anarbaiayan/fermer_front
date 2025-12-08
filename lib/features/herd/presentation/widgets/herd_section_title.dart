import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_colors.dart';

class HerdSectionTitle extends StatelessWidget {
  final String text;

  const HerdSectionTitle({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.primary3,
      ),
    );
  }
}
