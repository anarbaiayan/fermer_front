import 'dart:async';
import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:frontend/core/router/app_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'push_notification_payload.dart';

typedef PushNavigation = void Function(String location);
typedef NavigationScheduler = void Function(VoidCallback callback);

class PushNotificationRouter {
  PushNotificationRouter({
    PushNavigation? go,
    PushNavigation? push,
    NavigationScheduler? afterNavigation,
  }) : _go = go ?? appRouter.go,
       _push = push ?? ((location) => unawaited(appRouter.push(location))),
       _afterNavigation = afterNavigation ?? _nextFrame;

  static const _pendingPayloadKey = 'pending_push_notification_payload';

  /// Экраны из пуша открываются поверх главной: у них должен быть куда
  /// вести "Закрыть" и системный "Назад".
  static const homeLocation = '/home';

  final PushNavigation _go;
  final PushNavigation _push;
  final NavigationScheduler _afterNavigation;

  /// go_router строит push поверх текущей конфигурации делегата. Сейчас go
  /// применяется синхронно, потому что у appRouter нет асинхронных redirect,
  /// но с таким redirect push сразу после go лёг бы на старый стек. Кадр
  /// задержки страхует от этого.
  static void _nextFrame(VoidCallback callback) {
    WidgetsBinding.instance
      ..addPostFrameCallback((_) => callback())
      ..scheduleFrame();
  }

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
    final target = payload.type == 'PLANNED_EVENT' && payload.cattleId != null
        ? '/herd/${payload.cattleId}'
        : '/notifications';

    // Раньше здесь был go(target): он заменял весь стек одним экраном, и
    // на карточке, открытой из пуша, "Закрыть" и "Назад" никуда не вели.
    _go(homeLocation);
    _afterNavigation(() => _push(target));
  }
}
