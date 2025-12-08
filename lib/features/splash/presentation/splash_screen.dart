// features/splash/presentation/splash_screen.dart
import 'package:flutter/material.dart';
import 'package:frontend/features/auth/application/auth_providers.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../../core/theme/app_colors.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() async {
      // пробуем обновить токены (если были сохранены)
      await ref.read(authControllerProvider.notifier).refreshToken();

      await Future.delayed(const Duration(seconds: 1));

      if (!mounted) return;

      final authState = ref.read(authControllerProvider);

      if (authState.tokens != null) {
        // авторизован - на главную
        context.go('/home');
      } else {
        // не авторизован - на логин
        context.go('/login');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background1,
      body: const Center(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'FERMER',
              style: TextStyle(
                fontSize: 64,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1E4732),
                letterSpacing: 2,
              ),
            ),
            SizedBox(width: 6),
            Text(
              '+',
              style: TextStyle(
                fontSize: 64,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1E4732),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
