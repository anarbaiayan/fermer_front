import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenRepository {
  TokenRepository(this._dio);

  final Dio _dio;
  final _storage = const FlutterSecureStorage();

  static const _accessKey = 'access_token';
  static const _refreshKey = 'refresh_token';
  static const _typeKey = 'token_type';

  Future<String?> get accessToken => _storage.read(key: _accessKey);
  Future<String?> get refreshToken => _storage.read(key: _refreshKey);
  Future<String?> get tokenType => _storage.read(key: _typeKey);

  Future<void> save({
    required String access,
    required String refresh,
    required String type,
  }) async {
    await _storage.write(key: _accessKey, value: access);
    await _storage.write(key: _refreshKey, value: refresh);
    await _storage.write(key: _typeKey, value: type);
  }

  Future<void> clear() async {
    await _storage.deleteAll();
  }

  /// POST /auth/refresh
  Future<bool> refresh() async {
    final refresh = await refreshToken;
    if (refresh == null) return false;

    try {
      final r = await _dio.post(
        '/auth/refresh',
        data: {'refreshToken': refresh},
        options: Options(
          headers: {'Authorization': null},
          extra: {'skipAuth': true},
        ),
      );

      final data = r.data as Map<String, dynamic>;

      await save(
        access: data['accessToken'],
        refresh: data['refreshToken'],
        type: data['tokenType'] ?? 'Bearer',
      );

      return true;
    } catch (_) {
      return false;
    }
  }
}
