import 'package:flutter/material.dart';
import 'package:frontend/l10n/app_localizations.dart';
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
    final l10n = AppLocalizations.of(context)!;

    return AppTextField(
      label: l10n.loginPasswordLabel,
      hintText: '',
      controller: controller,
      obscureText: !isVisible,
      errorText: hasError ? (errorText ?? l10n.loginPasswordError) : null,
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
