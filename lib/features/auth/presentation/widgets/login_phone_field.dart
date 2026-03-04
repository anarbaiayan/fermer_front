import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:frontend/l10n/app_localizations.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

import '../../../../core/widgets/app_text_field.dart';

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
    final l10n = AppLocalizations.of(context)!;

    return AppTextField(
      label: l10n.loginPhoneLabel,
      hintText: l10n.loginPhoneHint,
      controller: controller,
      keyboardType: TextInputType.phone,
      inputFormatters: <TextInputFormatter>[formatter],
      errorText: errorText,
    );
  }
}
