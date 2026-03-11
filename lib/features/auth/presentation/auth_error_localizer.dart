import 'package:flutter/widgets.dart';
import 'package:frontend/features/auth/domain/entities/auth_error_code.dart';
import 'package:frontend/l10n/app_localizations.dart';

String localizeAuthError(BuildContext context, String rawError) {
  if (!AuthErrorCode.isKnown(rawError)) return rawError;

  final l10n = AppLocalizations.of(context)!;
  switch (rawError) {
    case AuthErrorCode.userExists:
      return l10n.authUserExists;
    case AuthErrorCode.invalidCredentials:
      return l10n.authInvalidCredentials;
    case AuthErrorCode.userNotFound:
      return l10n.authUserNotFound;
    case AuthErrorCode.loginFailed:
      return l10n.authLoginFailed;
    case AuthErrorCode.registerInvalidData:
      return l10n.authRegisterInvalidData;
    case AuthErrorCode.registerFailed:
      return l10n.authRegisterFailed;
    case AuthErrorCode.loginNetwork:
      return l10n.authLoginNetwork;
    case AuthErrorCode.registerNetwork:
      return l10n.authRegisterNetwork;
    default:
      return rawError;
  }
}
