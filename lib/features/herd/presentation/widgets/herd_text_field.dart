import 'package:flutter/material.dart';
import 'package:frontend/features/herd/presentation/widgets/herd_input_decoration.dart';

class HerdTextField extends StatelessWidget {
  final TextEditingController controller;
  final String? hint;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;
  final bool readOnly;
  final VoidCallback? onTap;

  const HerdTextField({
    super.key,
    required this.controller,
    this.hint,
    this.prefixIcon,
    this.suffixIcon,
    this.keyboardType,
    this.readOnly = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      readOnly: readOnly,
      onTap: onTap,
      decoration: herdInputDecoration(
        hint: hint,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
      ),
    );
  }
}
