import 'dart:convert';

import 'package:frontend/core/router/app_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'push_notification_payload.dart';

typedef PushNavigation = void Function(String location);

class PushNotificationRouter {
  PushNotificationRouter({PushNavigation? navigate})
    : _navigateTo = navigate ?? appRouter.go;

  static const _pendingPayloadKey = 'pending_push_notification_payload';

  final PushNavigation _navigateTo;

  Future<void> savePending(PushNotificationPayload payload) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(
      _pendingPayloadKey,
      jsonEncode(payload.toJson()),
    );
  }

  Future<bool> handlePendingNavigation({required bool isAuthenticated}) async {
    if (!isAuthenticated) return false;

    final preferences = await SharedPreferences.getInstance();
    final encodedPayload = preferences.getString(_pendingPayloadKey);
    if (encodedPayload == null) return false;

    try {
      final payload = PushNotificationPayload.fromJson(
        jsonDecode(encodedPayload) as Map<String, dynamic>,
      );
      await preferences.remove(_pendingPayloadKey);
      _navigate(payload);
      return true;
    } on FormatException {
      await preferences.remove(_pendingPayloadKey);
      return false;
    }
  }

  void navigateAuthenticated(PushNotificationPayload payload) {
    _navigate(payload);
  }

  void _navigate(PushNotificationPayload payload) {
    if (payload.type == 'PLANNED_EVENT' && payload.cattleId != null) {
      _navigateTo('/herd/${payload.cattleId}');
      return;
    }

    _navigateTo('/notifications');
  }
}
