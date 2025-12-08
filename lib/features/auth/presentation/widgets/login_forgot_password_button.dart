import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class LoginForgotPasswordButton extends StatelessWidget {
  const LoginForgotPasswordButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: () {
          // TODO: экран "Забыли пароль?"
        },
        style: TextButton.styleFrom(
          padding: EdgeInsets.zero,
          minimumSize: const Size(0, 0),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: const Text(
          'Забыли пароль?',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.primary1,
          ),
        ),
      ),
    );
  }
}
