import 'package:flutter/material.dart';

class LoginDivider extends StatelessWidget {
  const LoginDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Image.asset(
          'assets/icons/divider.png',
          width: double.infinity,
          fit: BoxFit.contain,
        ),
      ],
    );
  }
}
