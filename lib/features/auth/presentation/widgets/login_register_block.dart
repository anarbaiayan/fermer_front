import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';

class LoginRegisterBlock extends StatelessWidget {
  const LoginRegisterBlock({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Center(
          child: Text(
            'Ещё нет аккаунта?',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.primary3,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Center(
          child: Text(
            'Зарегистрируйтесь для использования платформы Fermer+',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 11, color: AppColors.authSmallText),
          ),
        ),
        const SizedBox(height: 22),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.primary1, width: 1.5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () {
              context.push('/register-step1');
            },

            child: const Text(
              'Зарегистрироваться',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.primary1,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
