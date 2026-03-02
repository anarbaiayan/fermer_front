import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
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
    return AppTextField(
      label: 'Номер телефона',
      hintText: 'Введите номер',
      controller: controller,
      keyboardType: TextInputType.phone,
      inputFormatters: <TextInputFormatter>[formatter],
      errorText: errorText,
    );
  }
}
