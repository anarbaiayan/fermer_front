import 'package:dio/dio.dart';
import 'package:frontend/core/network/api_exceptions.dart';
import 'package:frontend/l10n/app_localizations.dart';
import '../domain/entities/lactation_validation.dart';

String lactationErrorMessage(Object error, AppLocalizations l10n) {
  if (error is LactationValidationError) {
    return switch (error) {
      LactationValidationError.milk => l10n.lactationMilkPositive,
      LactationValidationError.cowCount => l10n.lactationEnterCowCount,
      LactationValidationError.calvesMilk ||
      LactationValidationError.unsuitableMilk => l10n.lactationMilkNonNegative,
      LactationValidationError.milkBalance => l10n.lactationMilkBalanceError,
      LactationValidationError.periodTooLong => l10n.lactationPeriodLimit,
      LactationValidationError.incompleteData => l10n.lactationIncompleteData,
    };
  }
  if (error is DioException) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return l10n.lactationTimeoutError;
      case DioExceptionType.connectionError:
        return l10n.lactationNetworkError;
      default:
        break;
    }
    if (error.response?.statusCode == 401) return l10n.lactationSessionExpired;
    if (error.response?.statusCode == 403) return l10n.lactationAccessDenied;
    final data = error.response?.data;
    // Keep backend validation messages, but never display HTML or Dio internals.
    if (data is Map<String, dynamic> && data['message'] is String) {
      final message = extractApiMessage(error).trim();
      if (message.isNotEmpty && !message.contains('<')) return message;
    }
  }
  if (error is ApiException) return error.message;
  if (error is FormatException || error is TypeError) {
    return l10n.lactationIncompleteData;
  }
  return l10n.lactationRequestError;
}
