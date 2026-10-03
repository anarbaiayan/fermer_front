import 'package:flutter/foundation.dart';

/// Платформа магазина приложений (`DevicePlatform` на бэкенде).
enum StorePlatform {
  android(
    'ANDROID',
    'https://play.google.com/store/apps/details?id=kz.fermerplus.app',
  ),
  ios('IOS', 'https://apps.apple.com/kz/app/fermer/id6759485885');

  const StorePlatform(this.apiValue, this.defaultStoreUrl);

  final String apiValue;

  /// Страница приложения, если бэкенд не прислал свою.
  final String defaultStoreUrl;

  /// Платформа устройства; `null` — не телефон (web, desktop): версию не
  /// проверяем.
  static StorePlatform? get current {
    if (kIsWeb) return null;
    return switch (defaultTargetPlatform) {
      TargetPlatform.android => StorePlatform.android,
      TargetPlatform.iOS => StorePlatform.ios,
      _ => null,
    };
  }
}

/// `GET /api/public/app-version`: сборки ниже [minBuild] обязаны обновиться.
@immutable
class AppVersionPolicy {
  const AppVersionPolicy({required this.minBuild, this.storeUrl});

  /// Номер сборки — число после «+» в `version` из `pubspec.yaml`
  /// (versionCode на Android, CFBundleVersion на iOS). 0 — никого не
  /// блокируем.
  final int minBuild;
  final String? storeUrl;

  bool blocks(int installedBuild) => installedBuild < minBuild;
}

/// Установленное приложение: номер сборки для сравнения и версия для экрана.
@immutable
class InstalledApp {
  const InstalledApp({required this.build, required this.version});

  final int build;
  final String version;
}

/// Итог проверки для экрана «Нужно обновить».
@immutable
class AppUpdateStatus {
  const AppUpdateStatus._({
    required this.updateRequired,
    this.storeUrl,
    this.installedVersion,
  });

  const AppUpdateStatus.upToDate() : this._(updateRequired: false);

  const AppUpdateStatus.required({
    required String storeUrl,
    required String installedVersion,
  }) : this._(
         updateRequired: true,
         storeUrl: storeUrl,
         installedVersion: installedVersion,
       );

  final bool updateRequired;
  final String? storeUrl;
  final String? installedVersion;
}
