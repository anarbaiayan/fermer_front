import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_logo.dart';

class LoginHeader extends StatelessWidget {
  const LoginHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppLogo(height: 40),

        const SizedBox(height: 32),

        const Text(
          'ВХОД',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: AppColors.primary1,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Введите информацию для входа в личный кабинет',
          style: TextStyle(fontSize: 14, color: AppColors.authSmallText),
        ),
      ],
    );
  }
}
