import 'package:flutter/material.dart';
import 'package:frontend/features/auth/application/auth_providers.dart';
import 'package:frontend/features/auth/session_events.dart';
import 'package:frontend/l10n/app_localizations.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:frontend/core/router/app_router.dart';
import 'package:frontend/core/theme/app_theme.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class FermerPlusApp extends ConsumerWidget {
  const FermerPlusApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 👇 слушаем истечение сессии
    ref.listen<bool>(sessionExpiredProvider, (prev, next) {
      if (next == true) {
        // logout
        ref.read(authControllerProvider.notifier).logout();

        // сбрасываем флаг, чтобы не зациклилось
        ref.read(sessionExpiredProvider.notifier).state = false;

        // go_router сам отправит на /login, если ты это обрабатываешь
        appRouter.go('/login');
      }
    });

    return MaterialApp.router(
      locale: const Locale('ru', 'RU'),
      supportedLocales: const [
        Locale('ru', 'RU'),
        Locale('kk', 'KZ'),
      ],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      title: 'Fermer+',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      routerConfig: appRouter,
    );
  }
}
