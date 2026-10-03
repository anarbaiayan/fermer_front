import 'package:shared_preferences/shared_preferences.dart';

import '../domain/app_version_policy.dart';

/// Последнее правило с бэкенда. Устаревшая сборка блокируется сразу при
/// запуске, даже без сети, — иначе экран обновления обходился бы режимом
/// полёта.
class AppVersionCache {
  static String _minBuildKey(StorePlatform platform) =>
      'app_update.${platform.name}.min_build';

  static String _storeUrlKey(StorePlatform platform) =>
      'app_update.${platform.name}.store_url';

  Future<AppVersionPolicy?> read(StorePlatform platform) async {
    final prefs = await SharedPreferences.getInstance();
    final minBuild = prefs.getInt(_minBuildKey(platform));
    if (minBuild == null) return null;
    return AppVersionPolicy(
      minBuild: minBuild,
      storeUrl: prefs.getString(_storeUrlKey(platform)),
    );
  }

  Future<void> save(StorePlatform platform, AppVersionPolicy policy) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_minBuildKey(platform), policy.minBuild);
    final url = policy.storeUrl;
    if (url == null) {
      await prefs.remove(_storeUrlKey(platform));
    } else {
      await prefs.setString(_storeUrlKey(platform), url);
    }
  }
}
