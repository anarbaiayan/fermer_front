import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

import '../../../../core/theme/app_colors.dart';

class LoginPhoneField extends StatelessWidget {
  final TextEditingController controller;
  final MaskTextInputFormatter formatter;
  final String? errorText;

  const LoginPhoneField({
    super.key,
    required this.controller,
    required this.formatter,
    this.errorText,
  });

  @override
  Widget build(BuildContext context) {
    final hasError = errorText != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Номер телефона',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppColors.primary3,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: TextInputType.phone,
          inputFormatters: <TextInputFormatter>[formatter],
          decoration: InputDecoration(
            hintText: 'Введите номер',
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 14,
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
            errorText!,
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
