import 'package:dio/dio.dart';

class DioClient {
  final Dio _dio;

  Dio get dio => _dio;

  DioClient({
    required String baseUrl,
    Interceptor? authInterceptor,
  }) : _dio = Dio(
          BaseOptions(
            baseUrl: baseUrl,
            connectTimeout: const Duration(seconds: 10),
            receiveTimeout: const Duration(seconds: 10),
            contentType: 'application/json',
          ),
        ) {
    // Логирование (удобно при отладке)
    _dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
    ));

    // authInterceptor пригодится для токенов
    if (authInterceptor != null) {
      _dio.interceptors.add(authInterceptor);
    }
  }

  // ------- helpers -------
  Future<Response> get(String path, {Map<String, dynamic>? query}) {
    return _dio.get(path, queryParameters: query);
  }

  Future<Response> post(String path, {dynamic data}) {
    return _dio.post(path, data: data);
  }

  Future<Response> put(String path, {dynamic data}) {
    return _dio.put(path, data: data);
  }

  Future<Response> delete(String path, {dynamic data}) {
    return _dio.delete(path, data: data);
  }
}
