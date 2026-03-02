import 'package:flutter/material.dart';

/// Reusable Fermer+ logo widget that renders the logo.png asset.
class AppLogo extends StatelessWidget {
  /// Height of the logo image. Defaults to 48.
  final double height;

  const AppLogo({super.key, this.height = 48});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Image.asset(
        'assets/icons/logo_green.png',
        height: height,
        fit: BoxFit.contain,
      ),
    );
  }
}
