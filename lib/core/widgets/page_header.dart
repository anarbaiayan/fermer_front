import 'package:flutter/material.dart';
import 'package:frontend/core/icons/app_icons.dart';
import 'package:frontend/core/theme/app_colors.dart';

class HerdPageHeader extends StatelessWidget {
  final String title;
  final VoidCallback onBack;

  /// Длинные заголовки (особенно на казахском) можно перенести на вторую
  /// строку вместо обрезки.
  final int maxLines;

  const HerdPageHeader({
    super.key,
    required this.title,
    required this.onBack,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.max,
      children: [
        IconButton(
          padding: EdgeInsets.zero,
          icon: AppIcons.svg('arrow', size: 32),
          onPressed: onBack,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            maxLines: maxLines,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppColors.primary3,
            ),
          ),
        ),
        const SizedBox(width: 48), // симметрия под иконку слева
      ],
    );
  }
}
