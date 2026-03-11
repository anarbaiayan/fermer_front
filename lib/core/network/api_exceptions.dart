import 'package:dio/dio.dart';
import 'package:intl/intl.dart' as intl;

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, [this.statusCode]);

  @override
  String toString() => 'ApiException: $message (code: $statusCode)';
}

/// Вытаскивает человекочитаемое сообщение из ответа бэка.
/// Поддерживает форматы:
/// - {"message": "..."}
/// - plain string
/// - иначе fallback
String extractApiMessage(Object error, {String? fallback}) {
  final fb = fallback ?? _defaultApiFallback();

  if (error is ApiException) return error.message;

  if (error is DioException) {
    final data = error.response?.data;

    // JSON map: { message: ... }
    if (data is Map<String, dynamic>) {
      final msg = data['message']?.toString();
      if (msg != null && msg.trim().isNotEmpty) return msg.trim();

      final err = data['error']?.toString();
      if (err != null && err.trim().isNotEmpty) return err.trim();
    }

    // plain string
    if (data is String && data.trim().isNotEmpty) return data.trim();

    // dio message
    final m = error.message;
    if (m != null && m.trim().isNotEmpty) return m.trim();
  }

  return fb;
}

String _defaultApiFallback() {
  final locale = intl.Intl.getCurrentLocale().toLowerCase();
  if (locale.startsWith('kk')) {
    return 'Сұраныс қатесі';
  }
  return 'Ошибка запроса';
}
