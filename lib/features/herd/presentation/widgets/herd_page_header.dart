import 'package:flutter/material.dart';
import 'package:frontend/core/icons/app_icons.dart';
import 'package:frontend/core/theme/app_colors.dart';

class HerdPageHeader extends StatelessWidget {
  final String title;
  final VoidCallback onBack;

  const HerdPageHeader({
    super.key,
    required this.title,
    required this.onBack,
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
            maxLines: 1,
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
