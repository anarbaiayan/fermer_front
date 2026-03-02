import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_text_field.dart';

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
    return AppTextField(
      label: 'Пароль',
      hintText: '',
      controller: controller,
      obscureText: !isVisible,
      errorText: hasError
          ? (errorText ?? 'Неверный пароль. Попробуйте ввести снова.')
          : null,
      suffixIcon: IconButton(
        onPressed: onToggleVisibility,
        icon: Icon(
          isVisible ? Icons.visibility_off_outlined : Icons.visibility_outlined,
          size: 20,
          color: AppColors.additional3,
        ),
      ),
    );
  }
}
