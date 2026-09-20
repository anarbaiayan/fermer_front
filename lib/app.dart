import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:frontend/core/localization/locale_controller.dart';
import 'package:frontend/core/notifications/push_notification_providers.dart';
import 'package:frontend/core/router/app_router.dart';
import 'package:frontend/core/theme/app_theme.dart';
import 'package:frontend/features/auth/application/auth_providers.dart';
import 'package:frontend/features/auth/session_events.dart';
import 'package:frontend/features/notifications/application/notifications_providers.dart';
import 'package:frontend/l10n/app_localizations.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// Стиль системных баров по умолчанию (edge-to-edge): прозрачные бары с
/// тёмными иконками для светлых экранов без app bar. Экраны с зелёным app bar
/// переопределяют это через `appBarTheme.systemOverlayStyle`.
const _defaultSystemOverlay = SystemUiOverlayStyle(
  statusBarColor: Colors.transparent,
  statusBarIconBrightness: Brightness.dark,
  statusBarBrightness: Brightness.light,
  systemNavigationBarColor: Colors.transparent,
  systemNavigationBarDividerColor: Colors.transparent,
  systemNavigationBarIconBrightness: Brightness.dark,
  systemNavigationBarContrastEnforced: false,
);

class FermerPlusApp extends ConsumerStatefulWidget {
  const FermerPlusApp({super.key});

  @override
  ConsumerState<FermerPlusApp> createState() => _FermerPlusAppState();
}

class _FermerPlusAppState extends ConsumerState<FermerPlusApp> {
  late final AppLifecycleListener _lifecycleListener;

  @override
  void initState() {
    super.initState();
    _lifecycleListener = AppLifecycleListener(
      onResume: () {
        ref.invalidate(unreadNotificationsCountProvider);
      },
    );
  }

  @override
  void dispose() {
    _lifecycleListener.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(appLocaleProvider);

    // Push setup is independent of the active screen and runs once per app run.
    unawaited(ref.read(pushNotificationServiceProvider).initialize());

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
      locale: locale,
      supportedLocales: AppLocalizations.supportedLocales,
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
      builder: (context, child) {
        // Тёмные иконки баров по умолчанию на всех светлых экранах без app bar
        // (login/register/splash и т.п.). Зелёный app bar сам ставит светлые.
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: _defaultSystemOverlay,
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
