import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
      // Прозрачный статус-бар со светлыми иконками поверх зелёного app bar
      // (edge-to-edge, без непрозрачного цвета бара).
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarDividerColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.dark,
        systemNavigationBarContrastEnforced: false,
      ),
    ),
    colorScheme: base.colorScheme.copyWith(
      primary: AppColors.primary1,
      secondary: AppColors.accent,
      error: AppColors.error,
      surface: AppColors.surface1,
    ),
    cardTheme: const CardThemeData(
      elevation: 0, // тень дадим вручную в AppCard
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
