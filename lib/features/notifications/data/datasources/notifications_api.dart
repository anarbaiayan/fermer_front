import 'package:dio/dio.dart';
import 'package:frontend/core/network/api_exceptions.dart';
import 'package:frontend/core/network/network_providers.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../models/notifications_page_dto.dart';

final notificationsApiProvider = Provider<NotificationsApi>((ref) {
  final dio = ref.read(dioClientProvider).dio;
  return NotificationsApi(dio);
});

class NotificationsApi {
  final Dio _dio;
  NotificationsApi(this._dio);

  Never _fail(DioException e, String fallback) {
    throw ApiException(
      extractApiMessage(e, fallback: fallback),
      e.response?.statusCode,
    );
  }

  Future<NotificationsPageDto> getNotifications({
    required int page,
    required int size,
    List<String> sort = const ['notificationDate,desc'],
  }) async {
    try {
      final r = await _dio.get(
        '/notifications',
        queryParameters: {
          'page': page,
          'size': size,
          'sort': sort,
        },
      );
      return NotificationsPageDto.fromJson(r.data as Map<String, dynamic>);
    } on DioException catch (e) {
      _fail(e, 'Ошибка при получении уведомлений');
    }
  }

  Future<NotificationsPageDto> getArchivedNotifications({
    required int page,
    required int size,
    List<String> sort = const ['notificationDate,desc'],
  }) async {
    try {
      final r = await _dio.get(
        '/notifications/archived',
        queryParameters: {
          'page': page,
          'size': size,
          'sort': sort,
        },
      );
      return NotificationsPageDto.fromJson(r.data as Map<String, dynamic>);
    } on DioException catch (e) {
      _fail(e, 'Ошибка при получении архивных уведомлений');
    }
  }

  Future<void> markAsRead(int id) async {
    try {
      await _dio.patch('/notifications/$id/read');
    } on DioException catch (e) {
      _fail(e, 'Ошибка при отметке уведомления как прочитанного');
    }
  }

  Future<void> archive(int id) async {
    try {
      await _dio.patch('/notifications/$id/archive');
    } on DioException catch (e) {
      _fail(e, 'Ошибка при архивировании уведомления');
    }
  }

  Future<int> getUnreadCount() async {
    try {
      final r = await _dio.get('/notifications/unread/count');
      final data = r.data;
      if (data is num) return data.toInt();
      if (data is String) return int.tryParse(data) ?? 0;
      return 0;
    } on DioException catch (e) {
      _fail(e, 'Ошибка при получении количества непрочитанных уведомлений');
    }
  }
}
