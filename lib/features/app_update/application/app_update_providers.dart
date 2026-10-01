import 'dart:async';

import 'package:frontend/core/network/network_providers.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data/app_version_api.dart';
import '../data/app_version_cache.dart';
import '../domain/app_version_policy.dart';

/// `null` — не телефон: версию не проверяем. В тестах подменяется.
final appUpdatePlatformProvider = Provider<StorePlatform?>(
  (ref) => StorePlatform.current,
);

/// Установленная сборка из `pubspec.yaml` (`version: 1.4.0+10` → 10).
final installedAppLoaderProvider = Provider<Future<InstalledApp> Function()>(
  (ref) => () async {
    final info = await PackageInfo.fromPlatform();
    return InstalledApp(
      build: int.parse(info.buildNumber),
      version: info.version,
    );
  },
);

/// Без авторизации: проверка нужна и на экране входа.
final appVersionApiProvider = Provider<AppVersionApi>(
  (ref) => AppVersionApi(ref.read(rawDioProvider)),
);

final appVersionCacheProvider = Provider<AppVersionCache>(
  (ref) => AppVersionCache(),
);

/// Открывает страницу в Google Play / App Store. `false` — не открылась.
final appUpdateLauncherProvider = Provider<Future<bool> Function(Uri)>(
  (ref) => (uri) async {
    try {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      return false;
    }
  },
);

/// Нужно ли обязательное обновление. Проверка стартует вместе с
/// приложением и повторяется при возврате в него (`check`).
final appUpdateProvider =
    StateNotifierProvider<AppUpdateController, AppUpdateStatus>((ref) {
      final controller = AppUpdateController(
        platform: ref.watch(appUpdatePlatformProvider),
        api: ref.watch(appVersionApiProvider),
        cache: ref.watch(appVersionCacheProvider),
        loadInstalledApp: ref.watch(installedAppLoaderProvider),
      );
      unawaited(controller.check());
      return controller;
    });

class AppUpdateController extends StateNotifier<AppUpdateStatus> {
  AppUpdateController({
    required StorePlatform? platform,
    required AppVersionApi api,
    required AppVersionCache cache,
    required Future<InstalledApp> Function() loadInstalledApp,
  }) : _platform = platform,
       _api = api,
       _cache = cache,
       _loadInstalledApp = loadInstalledApp,
       super(const AppUpdateStatus.upToDate());

  final StorePlatform? _platform;
  final AppVersionApi _api;
  final AppVersionCache _cache;
  final Future<InstalledApp> Function() _loadInstalledApp;

  Future<void>? _running;

  /// Сначала решение по последнему известному правилу, затем по свежему с
  /// бэкенда. Повторный вызов во время проверки ждёт текущую.
  Future<void> check() =>
      _running ??= _check().whenComplete(() => _running = null);

  Future<void> _check() async {
    final platform = _platform;
    if (platform == null) return;

    final InstalledApp installed;
    try {
      installed = await _loadInstalledApp();
    } catch (_) {
      // Версию не прочитать — не блокируем.
      return;
    }

    try {
      final cached = await _cache.read(platform);
      if (cached != null) _apply(platform, cached, installed);
    } catch (_) {
      // Кэш недоступен — решит ответ бэкенда.
    }

    try {
      final fresh = await _api.fetch(platform);
      _apply(platform, fresh, installed);
      await _cache.save(platform, fresh);
    } catch (_) {
      // Нет сети или бэкенд недоступен — остаётся прежнее решение.
    }
  }

  void _apply(
    StorePlatform platform,
    AppVersionPolicy policy,
    InstalledApp installed,
  ) {
    if (!mounted) return;
    state = policy.blocks(installed.build)
        ? AppUpdateStatus.required(
            storeUrl: policy.storeUrl ?? platform.defaultStoreUrl,
            installedVersion: installed.version,
          )
        : const AppUpdateStatus.upToDate();
  }
}
