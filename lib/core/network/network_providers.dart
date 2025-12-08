import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:frontend/core/network/dio_client.dart';
import 'package:frontend/core/network/auth_interceptor.dart';

final baseUrlProvider = Provider<String>((ref) {
  return 'http://45.136.70.121:8888/api';
});

final dioClientProvider = Provider<DioClient>((ref) {
  final baseUrl = ref.read(baseUrlProvider);
  final interceptor = AuthInterceptor(ref);

  return DioClient(
    baseUrl: baseUrl,
    authInterceptor: interceptor,
  );
});
