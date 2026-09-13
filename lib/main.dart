import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'app.dart';
import 'core/notifications/push_notification_service.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (PushNotificationService.isSupportedPlatform) {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      PushNotificationService.markFirebaseInitialized();
      PushNotificationService.registerBackgroundHandler();
    } catch (error) {
      if (kDebugMode) {
        debugPrint('Firebase initialization failed: $error');
      }
    }
  }

  // Android 15 (SDK 35) включает режим «от края до края» по умолчанию.
  // Явно включаем edge-to-edge и делаем системные бары прозрачными, чтобы
  // контент отрисовывался корректно и приложение не полагалось на
  // непрозрачные цвета статус-бара/навбара.
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarDividerColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
      systemNavigationBarContrastEnforced: false,
    ),
  );

  runApp(const ProviderScope(child: FermerPlusApp()));
}
