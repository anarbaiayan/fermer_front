import 'package:flutter/material.dart';
import 'app_colors.dart';

ThemeData buildTheme() {
  final base = ThemeData.light();

  return base.copyWith(
    scaffoldBackgroundColor: AppColors.background,
    appBarTheme: const AppBarTheme(
      elevation: 0,
      backgroundColor: AppColors.primary1,
      foregroundColor: Colors.white,
      centerTitle: true,
    ),
    colorScheme: base.colorScheme.copyWith(
      primary: AppColors.primary1,
      secondary: AppColors.accent,
      error: AppColors.error,
      surface: AppColors.surface1,
    ),
    cardTheme: const CardThemeData(
      elevation: 0,          // тень дадим вручную в AppCard
      margin: EdgeInsets.zero,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      type: BottomNavigationBarType.fixed,
      selectedItemColor: AppColors.primary1,
      unselectedItemColor: Colors.grey,
      showUnselectedLabels: true,
    ),
  );
}
