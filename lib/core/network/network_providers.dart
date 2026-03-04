import 'package:dio/dio.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'dio_client.dart';
import 'auth_interceptor.dart';
import 'token_repository.dart';

final baseUrlProvider = Provider<String>((ref) {
  return 'https://fer-mer-plus.ru/api';
});

BaseOptions _baseOptions(String baseUrl) => BaseOptions(
  baseUrl: baseUrl,
  connectTimeout: const Duration(seconds: 10),
  receiveTimeout: const Duration(seconds: 10),
  contentType: 'application/json',
);

/// Dio без AuthInterceptor - только для refresh/login (чтобы не было loop)
final rawDioProvider = Provider<Dio>((ref) {
  final baseUrl = ref.read(baseUrlProvider);
  final dio = Dio(_baseOptions(baseUrl));
  dio.interceptors.add(LogInterceptor(requestBody: true, responseBody: true));
  return dio;
});

final tokenRepositoryProvider = Provider<TokenRepository>((ref) {
  final dio = ref.read(rawDioProvider);
  return TokenRepository(dio);
});

final dioClientProvider = Provider<DioClient>((ref) {
  final baseUrl = ref.read(baseUrlProvider);

  // Основной dio (с авторизацией)
  final dio = Dio(_baseOptions(baseUrl));
  dio.interceptors.add(LogInterceptor(requestBody: true, responseBody: true));

  // ВАЖНО: передаем dio внутрь interceptor, чтобы retry НЕ читал dioClientProvider
  dio.interceptors.add(AuthInterceptor(ref, dio));

  return DioClient(dio: dio);
});
