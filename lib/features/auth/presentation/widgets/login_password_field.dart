import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class LoginPasswordField extends StatelessWidget {
  final TextEditingController controller;
  final bool isVisible;
  final VoidCallback onToggleVisibility;
  final bool hasError;
  final String? errorText;

  const LoginPasswordField({
    super.key,
    required this.controller,
    required this.isVisible,
    required this.onToggleVisibility,
    required this.hasError,
    required this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Пароль',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppColors.primary3,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          obscureText: !isVisible,
          decoration: InputDecoration(
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 14,
            ),
            suffixIcon: IconButton(
              onPressed: onToggleVisibility,
              icon: Icon(
                isVisible
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                size: 20,
                color: AppColors.additional3,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: hasError ? AppColors.error : AppColors.additional1,
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: hasError ? AppColors.error : AppColors.primary1,
                width: 1.5,
              ),
            ),
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: 4),
          Text(
            errorText ??
                'Неверный пароль. Попробуйте ввести снова.',
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.error,
            ),
          ),
        ],
      ],
    );
  }
}
