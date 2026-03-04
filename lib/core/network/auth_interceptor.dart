import 'dart:async';
import 'package:dio/dio.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'network_providers.dart';
import 'package:frontend/features/auth/session_events.dart';

class AuthInterceptor extends Interceptor {
  AuthInterceptor(this.ref, this.dio);

  final Ref ref;
  final Dio dio;

  bool _refreshing = false;
  final _queue = <Completer<Response>>[];

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (options.extra['skipAuth'] == true) {
      return handler.next(options);
    }

    final repo = ref.read(tokenRepositoryProvider);
    final access = await repo.accessToken;
    final type = await repo.tokenType ?? 'Bearer';

    if (access != null && access.isNotEmpty) {
      options.headers['Authorization'] = '$type $access';
    }

    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final req = err.requestOptions;
    if (req.extra['skipAuth'] == true || req.path.startsWith('/auth/')) {
      return handler.next(err);
    }

    final status = err.response?.statusCode;
    final alreadyRetried = err.requestOptions.extra['__retried'] == true;

    if (status != 401 || alreadyRetried) {
      return handler.next(err);
    }

    final repo = ref.read(tokenRepositoryProvider);

    final completer = Completer<Response>();
    _queue.add(completer);

    if (!_refreshing) {
      _refreshing = true;
      final success = await repo.refresh();
      _refreshing = false;

      if (!success) {
        await repo.clear();
        ref.read(sessionExpiredProvider.notifier).state = true;

        // всем ожидающим - ошибка
        for (final c in _queue) {
          if (!c.isCompleted) {
            c.completeError(err);
          }
        }
        _queue.clear();

        return handler.next(err);
      }

      // refresh успешен -> ретраим очередь
      final pending = List<Completer<Response>>.from(_queue);
      _queue.clear();

      for (final c in pending) {
        _retry(err.requestOptions).then(c.complete).catchError(c.completeError);
      }
    }

    try {
      final response = await completer.future;
      handler.resolve(response);
    } catch (_) {
      handler.next(err);
    }
  }

  Future<Response> _retry(RequestOptions req) async {
    final options = Options(
      method: req.method,
      headers: req.headers,
      responseType: req.responseType,
      contentType: req.contentType,
      followRedirects: req.followRedirects,
      validateStatus: req.validateStatus,
      receiveDataWhenStatusError: req.receiveDataWhenStatusError,
      extra: {
        ...req.extra,
        '__retried': true, // защита от бесконечного цикла
      },
    );

    return dio.request(
      req.path,
      data: req.data,
      queryParameters: req.queryParameters,
      options: options,
    );
  }
}
