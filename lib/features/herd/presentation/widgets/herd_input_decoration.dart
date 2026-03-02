import 'package:flutter/material.dart';

InputDecoration herdInputDecoration({
  String? hint,
  Widget? prefixIcon,
  Widget? suffixIcon,
}) {
  return InputDecoration(
    hintText: hint,
    hintStyle: TextStyle(
      fontSize: 14,
      color: const Color.fromARGB(255, 95, 95, 95),
    ),
    filled: true,
    fillColor: const Color.fromARGB(255, 239, 239, 239),
    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    prefixIcon: prefixIcon,
    suffixIcon: suffixIcon,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(40),
      borderSide: BorderSide.none,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(40),
      borderSide: BorderSide.none,
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(40),
      borderSide: BorderSide.none,
    ),
  );
}
