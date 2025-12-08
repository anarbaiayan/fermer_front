import 'package:flutter/material.dart';
import 'package:frontend/core/router/app_router.dart';
import 'package:frontend/core/theme/app_theme.dart';

class FermerPlusApp extends StatelessWidget {
  const FermerPlusApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Fermer+',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      routerConfig: appRouter,
    );
  }
}
