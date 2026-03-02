import 'package:flutter/material.dart';
import 'package:frontend/core/icons/app_icons.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_logo.dart';

class RegisterHeader extends StatelessWidget {
  const RegisterHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),

        // ----- Logo -----
        const AppLogo(height: 40),

        const SizedBox(height: 16),

        // ----- стрелка + Регистрация -----
        Row(
          children: [
            const SizedBox(width: 6),
            IconButton(
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              icon: AppIcons.svg('arrow', size: 32),
              onPressed: () => context.pop(),
            ),
            const SizedBox(width: 4),
            const Text(
              'Регистрация',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: AppColors.primary3,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
