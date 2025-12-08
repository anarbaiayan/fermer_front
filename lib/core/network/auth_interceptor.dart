import 'package:dio/dio.dart';
import 'package:frontend/features/auth/application/auth_providers.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class AuthInterceptor extends Interceptor {
  final Ref ref;

  AuthInterceptor(this.ref);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final tokens = ref.read(authControllerProvider).tokens;

    if (tokens != null) {
      options.headers['Authorization'] =
          '${tokens.tokenType} ${tokens.accessToken}';
    }

    return handler.next(options);
  }
}
