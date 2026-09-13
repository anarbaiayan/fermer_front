import 'dart:async';
import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:frontend/core/network/token_repository.dart';
import 'package:frontend/features/notifications/data/datasources/notifications_api.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../firebase_options.dart';
import 'push_notification_payload.dart';
import 'push_notification_router.dart';

const _androidChannel = AndroidNotificationChannel(
  'fermer_notifications',
  'Fermer+ Notifications',
  description: 'Напоминания и события фермы',
  importance: Importance.high,
);

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
}

class PushNotificationService {
  PushNotificationService({
    required NotificationsApi notificationsApi,
    required TokenRepository tokenRepository,
    required PushNotificationRouter router,
  }) : _notificationsApi = notificationsApi,
       _tokenRepository = tokenRepository,
       _router = router;

  static const _tokenKey = 'fcm_device_token';
  static bool _firebaseInitialized = false;

  static bool get isSupportedPlatform =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  final NotificationsApi _notificationsApi;
  final TokenRepository _tokenRepository;
  final PushNotificationRouter _router;
  late final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  Future<void>? _initialization;
  bool _navigationReady = false;
  StreamSubscription<String>? _tokenRefreshSubscription;
  StreamSubscription<RemoteMessage>? _foregroundSubscription;
  StreamSubscription<RemoteMessage>? _notificationTapSubscription;

  static void registerBackgroundHandler() {
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  }

  static void markFirebaseInitialized() {
    _firebaseInitialized = true;
  }

  Future<void> initialize() {
    if (!isSupportedPlatform || !_firebaseInitialized) return Future.value();
    return _initialization ??= _initialize();
  }

  Future<void> _initialize() async {
    await _initializeLocalNotifications();
    await _requestPermission();
    await _configureForegroundPresentation();
    await _refreshAndStoreToken();

    _tokenRefreshSubscription = _messaging.onTokenRefresh.listen((token) async {
      await _storeToken(token);
      await registerCurrentToken(token: token);
    });
    _foregroundSubscription = FirebaseMessaging.onMessage.listen(
      _onForegroundMessage,
    );
    _notificationTapSubscription = FirebaseMessaging.onMessageOpenedApp.listen(
      _onNotificationTap,
    );

    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      await _router.savePending(_payloadFromMessage(initialMessage));
    }
  }

  Future<void> _initializeLocalNotifications() async {
    const initializationSettings = InitializationSettings(
      android: AndroidInitializationSettings('@drawable/ic_stat_notification'),
      iOS: DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      ),
    );

    await _localNotifications.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: (response) async {
        final payload = response.payload;
        if (payload == null) return;
        try {
          await _onNotificationTap(
            RemoteMessage(data: jsonDecode(payload) as Map<String, dynamic>),
          );
        } on FormatException {
          // Ignore malformed data from an obsolete local notification.
        }
      },
    );

    final launchDetails = await _localNotifications
        .getNotificationAppLaunchDetails();
    final launchPayload = launchDetails?.notificationResponse?.payload;
    if (launchDetails?.didNotificationLaunchApp == true &&
        launchPayload != null) {
      try {
        await _router.savePending(
          PushNotificationPayload.fromJson(
            jsonDecode(launchPayload) as Map<String, dynamic>,
          ),
        );
      } on FormatException {
        // Ignore malformed data from an obsolete local notification.
      }
    }

    final androidPlugin = _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await androidPlugin?.createNotificationChannel(_androidChannel);
  }

  Future<void> _requestPermission() async {
    await _messaging.requestPermission(alert: true, badge: true, sound: true);
  }

  Future<void> _configureForegroundPresentation() async {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      await _messaging.setForegroundNotificationPresentationOptions(
        alert: true,
        badge: true,
        sound: true,
      );
    }
  }

  Future<void> _refreshAndStoreToken() async {
    try {
      final token = await _messaging.getToken();
      if (token == null) return;
      await _storeToken(token);
      if (kDebugMode) {
        debugPrint('FCM token: $token');
      }
      await registerCurrentToken(token: token);
    } catch (error) {
      if (kDebugMode) {
        debugPrint('Unable to get FCM token: $error');
      }
    }
  }

  Future<void> _storeToken(String token) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_tokenKey, token);
  }

  Future<String?> _getStoredToken() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getString(_tokenKey);
  }

  Future<void> registerCurrentToken({String? token}) async {
    if (!isSupportedPlatform) return;
    if (await _tokenRepository.accessToken == null) return;

    final currentToken = token ?? await _getStoredToken();
    if (currentToken == null || currentToken.isEmpty) return;

    try {
      await _notificationsApi.registerPushToken(
        token: currentToken,
        platform: defaultTargetPlatform == TargetPlatform.iOS
            ? 'IOS'
            : 'ANDROID',
      );
    } catch (error) {
      if (kDebugMode) {
        debugPrint('Unable to register FCM token: $error');
      }
    }
  }

  Future<void> unregisterCurrentToken() async {
    if (!isSupportedPlatform) return;
    final token = await _getStoredToken();
    if (token == null || token.isEmpty) return;

    try {
      await _notificationsApi.unregisterPushToken(token);
    } catch (error) {
      if (kDebugMode) {
        debugPrint('Unable to unregister FCM token: $error');
      }
    }
  }

  Future<bool> handlePendingNavigation({required bool isAuthenticated}) async {
    _navigationReady = isAuthenticated;
    return _router.handlePendingNavigation(isAuthenticated: isAuthenticated);
  }

  void onLogout() {
    _navigationReady = false;
  }

  Future<void> _onForegroundMessage(RemoteMessage message) async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      await _showAndroidNotification(_payloadFromMessage(message));
    }
  }

  Future<void> _showAndroidNotification(PushNotificationPayload payload) async {
    await _localNotifications.show(
      id:
          payload.notificationId?.hashCode ??
          DateTime.now().millisecondsSinceEpoch,
      title: payload.title ?? 'Fermer+',
      body: payload.body ?? '',
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'fermer_notifications',
          'Fermer+ Notifications',
          channelDescription: 'Напоминания и события фермы',
          importance: Importance.high,
          priority: Priority.high,
          icon: 'ic_stat_notification',
        ),
      ),
      payload: jsonEncode(payload.toJson()),
    );
  }

  Future<void> _onNotificationTap(RemoteMessage message) async {
    final payload = _payloadFromMessage(message);
    if (!_navigationReady || await _tokenRepository.accessToken == null) {
      await _router.savePending(payload);
      return;
    }
    _router.navigateAuthenticated(payload);
  }

  PushNotificationPayload _payloadFromMessage(RemoteMessage message) {
    return PushNotificationPayload.fromMessage(
      data: message.data,
      title: message.notification?.title,
      body: message.notification?.body,
    );
  }

  void dispose() {
    _tokenRefreshSubscription?.cancel();
    _foregroundSubscription?.cancel();
    _notificationTapSubscription?.cancel();
  }
}
