abstract final class AuthErrorCode {
  static const userExists = 'auth.user_exists';
  static const invalidCredentials = 'auth.invalid_credentials';
  static const userNotFound = 'auth.user_not_found';
  static const loginFailed = 'auth.login_failed';
  static const registerInvalidData = 'auth.register_invalid_data';
  static const registerFailed = 'auth.register_failed';
  static const loginNetwork = 'auth.login_network';
  static const registerNetwork = 'auth.register_network';

  static bool isKnown(String value) =>
      value == userExists ||
      value == invalidCredentials ||
      value == userNotFound ||
      value == loginFailed ||
      value == registerInvalidData ||
      value == registerFailed ||
      value == loginNetwork ||
      value == registerNetwork;
}
