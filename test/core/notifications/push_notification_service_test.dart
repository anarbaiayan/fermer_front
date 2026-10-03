import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/core/network/token_repository.dart';
import 'package:frontend/core/notifications/push_notification_router.dart';
import 'package:frontend/core/notifications/push_notification_service.dart';
import 'package:frontend/features/notifications/data/datasources/notifications_api.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _Settings extends Fake implements NotificationSettings {}

class _Messaging extends Fake implements FirebaseMessaging {
  String? apnsToken = 'apns';
  int tokenReads = 0;
  int deletions = 0;
  Completer<void>? deletion;
  Map<Symbol, dynamic>? foregroundOptions;

  @override
  Future<String?> getAPNSToken() async => apnsToken;

  @override
  Future<String?> getToken({
    String? vapidKey,
    String? serviceWorkerScriptPath,
  }) async {
    tokenReads++;
    return 'fcm-token';
  }

  @override
  Future<void> deleteToken() async {
    deletions++;
    await deletion?.future;
  }

  @override
  Future<RemoteMessage?> getInitialMessage() async => null;

  @override
  dynamic noSuchMethod(Invocation invocation) {
    if (invocation.memberName == #requestPermission) {
      return Future<NotificationSettings>.value(_Settings());
    }
    if (invocation.memberName ==
        #setForegroundNotificationPresentationOptions) {
      foregroundOptions = invocation.namedArguments;
      return Future<void>.value();
    }
    return super.noSuchMethod(invocation);
  }
}

class _LocalNotifications extends Fake
    implements FlutterLocalNotificationsPlugin {
  final shown = <Map<Symbol, dynamic>>[];
  int initializations = 0;
  int cancellations = 0;
  bool failInitialization = false;
  InitializationSettings? settings;

  @override
  Future<NotificationAppLaunchDetails?>
  getNotificationAppLaunchDetails() async => null;

  @override
  Future<void> cancelAll() async => cancellations++;

  @override
  dynamic noSuchMethod(Invocation invocation) {
    if (invocation.memberName == #resolvePlatformSpecificImplementation) {
      return null;
    }
    if (invocation.memberName == #initialize) {
      initializations++;
      settings = invocation.namedArguments[#settings] as InitializationSettings;
      return failInitialization
          ? Future<bool?>.error(StateError('plugin unavailable'))
          : Future<bool?>.value(true);
    }
    if (invocation.memberName == #show) {
      shown.add(invocation.namedArguments);
      return Future<void>.value();
    }
    return super.noSuchMethod(invocation);
  }
}

class _Tokens extends Fake implements TokenRepository {
  String? access = 'session';

  @override
  Future<String?> get accessToken async => access;
}

class _Api extends Fake implements NotificationsApi {
  final registered = <String>[];
  final unregistered = <String>[];
  bool offline = false;

  @override
  Future<void> registerPushToken({
    required String token,
    required String platform,
  }) async {
    if (offline) throw StateError('offline');
    registered.add('$platform:$token');
  }

  @override
  Future<void> unregisterPushToken(String token) async =>
      unregistered.add(token);
}

void main() {
  late _Messaging messaging;
  late _LocalNotifications local;
  late _Tokens tokens;
  late _Api api;
  late StreamController<RemoteMessage> messages;
  late StreamController<String> refreshes;
  late PushNotificationService service;
  late int invalidations;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    PushNotificationService.markFirebaseInitialized();
    messaging = _Messaging();
    local = _LocalNotifications();
    tokens = _Tokens();
    api = _Api();
    messages = StreamController<RemoteMessage>.broadcast();
    refreshes = StreamController<String>.broadcast();
    invalidations = 0;
    service = PushNotificationService(
      notificationsApi: api,
      tokenRepository: tokens,
      router: PushNotificationRouter(go: (_) {}, push: (_) {}),
      messaging: messaging,
      localNotifications: local,
      tokenRefresh: refreshes.stream,
      foregroundMessages: messages.stream,
      openedMessages: const Stream.empty(),
      onNotificationReceived: () => invalidations++,
    );
  });

  tearDown(() async {
    service.dispose();
    await messages.close();
    await refreshes.close();
    debugDefaultTargetPlatformOverride = null;
  });

  /// The override has to be cleared inside the test body: the widget test
  /// framework asserts that foundation debug variables are unset before
  /// tearDown runs.
  Future<void> onPlatform(
    TargetPlatform platform,
    Future<void> Function() body,
  ) async {
    debugDefaultTargetPlatformOverride = platform;
    try {
      await body();
    } finally {
      debugDefaultTargetPlatformOverride = null;
    }
  }

  const notification = RemoteMessage(
    notification: RemoteNotification(title: 'Reminder', body: 'Weighing due'),
    data: {'notificationId': '7', 'badge': '3'},
  );

  testWidgets('iOS foreground has one presentation path and preserves badge', (
    tester,
  ) async {
    await onPlatform(TargetPlatform.iOS, () async {
      await service.initialize();
      messages.add(notification);
      await tester.pump();
      expect(messaging.foregroundOptions, {
        #alert: false,
        #badge: false,
        #sound: false,
      });
      expect(local.settings!.iOS!.requestAlertPermission, isFalse);
      expect(local.shown, hasLength(1));
      expect(
        (local.shown.single[#notificationDetails] as NotificationDetails)
            .iOS!
            .badgeNumber,
        3,
      );
      expect(invalidations, 1);
    });
  });

  testWidgets(
    'late APNs does not block message listeners or call getToken early',
    (tester) async {
      await onPlatform(TargetPlatform.iOS, () async {
        messaging.apnsToken = null;
        await service.initialize();
        messages.add(notification);
        await tester.pump(const Duration(seconds: 6));
        expect(messaging.tokenReads, 0);
        expect(local.shown, hasLength(1));
        messaging.apnsToken = 'ready';
        await service.onResume();
        expect(api.registered, contains('IOS:fcm-token'));
        service.dispose();
      });
    },
  );

  testWidgets('network failure is retried without another login', (
    tester,
  ) async {
    await onPlatform(TargetPlatform.iOS, () async {
      api.offline = true;
      await service.initialize();
      await tester.pump();
      expect(api.registered, isEmpty);
      api.offline = false;
      await tester.pump(const Duration(seconds: 2));
      expect(api.registered, ['IOS:fcm-token']);
      service.dispose();
    });
  });

  testWidgets(
    'logout invalidates token and suppresses refresh and presentation',
    (tester) async {
      await onPlatform(TargetPlatform.iOS, () async {
        await service.initialize();
        await tester.pump();
        await service.unregisterCurrentToken();
        tokens.access = null;
        final count = api.registered.length;
        refreshes.add('rotated-after-logout');
        messages.add(notification);
        await service.onResume();
        await tester.pump(const Duration(seconds: 60));
        expect(api.registered, hasLength(count));
        expect(api.unregistered, ['fcm-token']);
        expect(messaging.deletions, 1);
        expect(local.cancellations, 1);
        expect(local.shown, isEmpty);
        expect(
          (await SharedPreferences.getInstance()).getString('fcm_device_token'),
          isNull,
        );
      });
    },
  );

  testWidgets('new login waits for previous Firebase token deletion', (
    tester,
  ) async {
    await onPlatform(TargetPlatform.iOS, () async {
      await service.initialize();
      await tester.pump();
      messaging.deletion = Completer<void>();
      final cleanup = service.unregisterCurrentToken();
      await tester.pump();
      final count = api.registered.length;
      final registration = service.registerCurrentToken();
      await tester.pump();
      expect(api.registered, hasLength(count));
      messaging.deletion!.complete();
      await cleanup;
      await registration;
      expect(api.registered.length, greaterThan(count));
    });
  });

  testWidgets('initialization can recover after a native plugin error', (
    tester,
  ) async {
    await onPlatform(TargetPlatform.iOS, () async {
      local.failInitialization = true;
      await service.initialize();
      expect(local.initializations, 1);
      local.failInitialization = false;
      await service.onResume();
      messages.add(notification);
      await tester.pump();
      expect(local.initializations, 2);
      expect(local.shown, hasLength(1));
      service.dispose();
    });
  });

  testWidgets('data-only messages update state without an empty banner', (
    tester,
  ) async {
    await onPlatform(TargetPlatform.iOS, () async {
      await service.initialize();
      messages.add(const RemoteMessage(data: {'notificationId': '8'}));
      await tester.pump();
      expect(local.shown, isEmpty);
      expect(invalidations, 1);
    });
  });

  testWidgets('Android registration uses the Android platform', (tester) async {
    await onPlatform(TargetPlatform.android, () async {
      await service.initialize();
      await tester.pump();
      expect(api.registered, ['ANDROID:fcm-token']);
      expect(messaging.foregroundOptions, isNull);
      messages.add(notification);
      await tester.pump();
      expect(local.shown, hasLength(1));
    });
  });
}
