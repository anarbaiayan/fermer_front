import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class LoginHeader extends StatelessWidget {
  const LoginHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Center(
          child: Text(
            'FERMER +',
            style: TextStyle(
              fontFamily: 'Montserrat',
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: AppColors.primary1,
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Вход',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: AppColors.primary3,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Введите информацию для входа в личный кабинет',
          style: TextStyle(
            fontSize: 14,
            color: AppColors.authSmallText,
          ),
        ),
      ],
    );
  }
}
