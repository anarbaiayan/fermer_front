import 'package:dio/dio.dart';

import '../domain/app_version_policy.dart';

/// `GET /api/public/app-version?platform=` — без авторизации: проверка идёт
/// и до входа в аккаунт.
class AppVersionApi {
  AppVersionApi(this._dio);

  final Dio _dio;

  Future<AppVersionPolicy> fetch(StorePlatform platform) async {
    final r = await _dio.get(
      '/public/app-version',
      queryParameters: {'platform': platform.apiValue},
    );
    return appVersionPolicyFromJson(r.data as Map<String, dynamic>);
  }
}

/// `AppVersionResponse`.
AppVersionPolicy appVersionPolicyFromJson(Map<String, dynamic> json) {
  final url = json['storeUrl']?.toString().trim();
  return AppVersionPolicy(
    minBuild: (json['minBuild'] as num?)?.toInt() ?? 0,
    storeUrl: url == null || url.isEmpty ? null : url,
  );
}
