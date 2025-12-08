import 'package:flutter/material.dart';

class AppPage extends StatelessWidget {
  final Widget child;
  final bool usePadding;

  const AppPage({
    super.key,
    required this.child,
    this.usePadding = true,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: usePadding ? 24 : 0, // глобальные отступы
        ),
        child: child,
      ),
    );
  }
}
