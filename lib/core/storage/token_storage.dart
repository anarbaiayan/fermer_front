import 'package:frontend/features/auth/domain/entities/tokens.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TokenStorage {
  static const _keyAccessToken = 'accessToken';
  static const _keyRefreshToken = 'refreshToken';
  static const _keyTokenType = 'tokenType';
  static const _keyExpiresIn = 'expiresIn';

  Future<void> saveTokens(Tokens tokens) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyAccessToken, tokens.accessToken);
    await prefs.setString(_keyRefreshToken, tokens.refreshToken);
    await prefs.setString(_keyTokenType, tokens.tokenType);
    await prefs.setInt(_keyExpiresIn, tokens.expiresIn);
  }

  Future<Tokens?> loadTokens() async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString(_keyAccessToken);
    final refreshToken = prefs.getString(_keyRefreshToken);
    final tokenType = prefs.getString(_keyTokenType);
    final expiresIn = prefs.getInt(_keyExpiresIn);

    if (accessToken == null ||
        refreshToken == null ||
        tokenType == null ||
        expiresIn == null) {
      return null;
    }

    return Tokens(
      accessToken: accessToken,
      refreshToken: refreshToken,
      tokenType: tokenType,
      expiresIn: expiresIn,
    );
  }

  Future<void> clearTokens() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyAccessToken);
    await prefs.remove(_keyRefreshToken);
    await prefs.remove(_keyTokenType);
    await prefs.remove(_keyExpiresIn);
  }
}
