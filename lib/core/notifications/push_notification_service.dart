import 'dart:async';
import 'dart:convert';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:frontend/core/network/api_exceptions.dart';
import 'package:frontend/core/network/token_repository.dart';
import 'package:frontend/features/notifications/data/datasources/notifications_api.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../firebase_options.dart';
import 'push_notification_payload.dart';
import 'push_notification_router.dart';
import 'push_token_sync.dart';

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
    this.onNotificationReceived,
    FirebaseMessaging? messaging,
    FlutterLocalNotificationsPlugin? localNotifications,
    Stream<String>? tokenRefresh,
    Stream<RemoteMessage>? foregroundMessages,
    Stream<RemoteMessage>? openedMessages,
  }) : _notificationsApi = notificationsApi,
       _tokenRepository = tokenRepository,
       _router = router,
       _messagingOverride = messaging,
       _localNotifications =
           localNotifications ?? FlutterLocalNotificationsPlugin(),
       _tokenRefresh = tokenRefresh,
       _foregroundMessages = foregroundMessages,
       _openedMessages = openedMessages;

  final VoidCallback? onNotificationReceived;
  static const _tokenKey = 'fcm_device_token';
  static bool _firebaseInitialized = false;

  static bool get isSupportedPlatform =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  final NotificationsApi _notificationsApi;
  final TokenRepository _tokenRepository;
  final PushNotificationRouter _router;
  final FirebaseMessaging? _messagingOverride;
  late final FirebaseMessaging _messaging =
      _messagingOverride ?? FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications;
  final Stream<String>? _tokenRefresh;
  final Stream<RemoteMessage>? _foregroundMessages;
  final Stream<RemoteMessage>? _openedMessages;
  late final PushTokenSync _tokenSync = PushTokenSync(
    isReady: () async =>
        defaultTargetPlatform != TargetPlatform.iOS ||
        await _messaging.getAPNSToken() != null,
    getToken: () => _messaging.getToken(),
    storeToken: _storeToken,
    hasSession: () async => await _tokenRepository.accessToken != null,
    registerToken: (token) => _notificationsApi.registerPushToken(
      token: token,
      platform: defaultTargetPlatform == TargetPlatform.iOS ? 'IOS' : 'ANDROID',
    ),
    shouldRetry: (error) {
      if (error is! ApiException || error.statusCode == null) return true;
      final code = error.statusCode!;
      return code == 408 || code == 429 || code >= 500;
    },
    onError: (error) => _logError('Push token synchronization failed', error),
  );

  Future<void>? _initialization;
  Future<void>? _logoutCleanup;
  Timer? _initializationRetry;
  bool _ready = false;
  bool _localReady = false;
  bool _loggedOut = false;
  bool _background = false;
  bool _disposed = false;
  int _authGeneration = 0;
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
    if (!isSupportedPlatform || !_firebaseInitialized || _disposed || _ready) {
      return Future.value();
    }
    return _initialization ??= _initializeSafely();
  }

  Future<void> _initializeSafely() async {
    try {
      await _initializeLocalNotifications();
      await _configureForegroundPresentation();
      if (_disposed) return;
      // Listen before token acquisition: APNs registration may take a while.
      _tokenRefreshSubscription ??= (_tokenRefresh ?? _messaging.onTokenRefresh)
          .listen(
            (token) => unawaited(_tokenSync.synchronize(token: token)),
            onError: (Object error) {
              _logError('FCM token refresh failed', error);
              unawaited(_tokenSync.synchronize());
            },
          );
      _foregroundSubscription ??=
          (_foregroundMessages ?? FirebaseMessaging.onMessage).listen(
            (message) =>
                unawaited(_protect(() => _onForegroundMessage(message))),
            onError: (Object error) => _logError('FCM message failed', error),
          );
      _notificationTapSubscription ??=
          (_openedMessages ?? FirebaseMessaging.onMessageOpenedApp).listen(
            (message) => unawaited(_protect(() => _onNotificationTap(message))),
            onError: (Object error) =>
                _logError('FCM notification tap failed', error),
          );
      await _requestPermission();
      if (_disposed) return;
      _ready = true;
      _initializationRetry?.cancel();
      if (!_loggedOut) unawaited(_tokenSync.start());
      await _protect(() async {
        final initialMessage = await _messaging.getInitialMessage();
        if (!_disposed && initialMessage != null && !_loggedOut) {
          await _router.savePending(_payloadFromMessage(initialMessage));
        }
      });
    } catch (error) {
      _logError('Push initialization failed', error);
      if (!_disposed && !_background && !_loggedOut) {
        _initializationRetry?.cancel();
        _initializationRetry = Timer(const Duration(seconds: 30), () {
          unawaited(initialize());
        });
      }
    } finally {
      if (!_ready) _initialization = null;
    }
  }

  Future<void> _initializeLocalNotifications() async {
    if (_localReady) return;
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
        await _protect(() async {
          await _onNotificationTap(
            RemoteMessage(data: jsonDecode(payload) as Map<String, dynamic>),
          );
        });
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
      } catch (_) {
        // Ignore malformed data from an obsolete local notification.
      }
    }

    final androidPlugin = _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await androidPlugin?.createNotificationChannel(_androidChannel);
    _localReady = true;
  }

  Future<void> _requestPermission() async {
    await _messaging.requestPermission(alert: true, badge: true, sound: true);
  }

  Future<void> _configureForegroundPresentation() async {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      await _messaging.setForegroundNotificationPresentationOptions(
        // Foreground banners are displayed once via local notifications.
        alert: false,
        badge: false,
        sound: false,
      );
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

  Future<void> registerCurrentToken() async {
    if (!isSupportedPlatform || !_firebaseInitialized || _disposed) return;
    final generation = _authGeneration;
    await _logoutCleanup;
    if (_disposed || generation != _authGeneration) return;
    _loggedOut = false;
    await initialize();
    if (_ready && !_loggedOut && !_disposed) await _tokenSync.start();
  }

  Future<void> unregisterCurrentToken({bool unregisterFromBackend = true}) {
    onLogout();
    if (!isSupportedPlatform) return Future.value();
    return _logoutCleanup ??= _protect(() async {
      final token = await _getStoredToken();
      final preferences = await SharedPreferences.getInstance();
      await preferences.remove(_tokenKey);
      await Future.wait([
        _protect(_router.clearPending),
        if (_localReady) _protect(_localNotifications.cancelAll),
        if (_firebaseInitialized) _protect(_messaging.deleteToken),
        if (unregisterFromBackend && token != null)
          _protect(() => _notificationsApi.unregisterPushToken(token)),
      ]);
    }).whenComplete(() => _logoutCleanup = null);
  }

  Future<bool> handlePendingNavigation({required bool isAuthenticated}) async {
    _navigationReady = isAuthenticated;
    return _router.handlePendingNavigation(isAuthenticated: isAuthenticated);
  }

  void onLogout() {
    _authGeneration++;
    _loggedOut = true;
    _navigationReady = false;
    _initializationRetry?.cancel();
    _tokenSync.stop();
  }

  void onPause() {
    _background = true;
    _initializationRetry?.cancel();
    _tokenSync.pause();
  }

  Future<void> onResume() async {
    _background = false;
    if (_disposed ||
        _loggedOut ||
        !isSupportedPlatform ||
        !_firebaseInitialized) {
      return;
    }
    await initialize();
    if (_ready && !_loggedOut && !_disposed) await _tokenSync.resume();
  }

  Future<void> _onForegroundMessage(RemoteMessage message) async {
    if (_disposed || _loggedOut || await _tokenRepository.accessToken == null) {
      return;
    }
    final payload = _payloadFromMessage(message);
    onNotificationReceived?.call();
    if (payload.title == null && payload.body == null) return;
    await _showNotification(
      payload,
      badge: int.tryParse('${message.data['badge']}'),
    );
  }

  Future<void> _showNotification(
    PushNotificationPayload payload, {
    int? badge,
  }) async {
    await _localNotifications.show(
      id:
          payload.notificationId?.hashCode ??
          DateTime.now().millisecondsSinceEpoch,
      title: payload.title ?? 'Fermer+',
      body: payload.body ?? '',
      notificationDetails: NotificationDetails(
        android: const AndroidNotificationDetails(
          'fermer_notifications',
          'Fermer+ Notifications',
          channelDescription: 'Напоминания и события фермы',
          importance: Importance.high,
          priority: Priority.high,
          icon: 'ic_stat_notification',
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
          badgeNumber: badge,
        ),
      ),
      payload: jsonEncode(payload.toJson()),
    );
  }

  Future<void> _onNotificationTap(RemoteMessage message) async {
    if (_disposed || _loggedOut) return;
    onNotificationReceived?.call();
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
    _disposed = true;
    _initializationRetry?.cancel();
    _tokenSync.dispose();
    _tokenRefreshSubscription?.cancel();
    _foregroundSubscription?.cancel();
    _notificationTapSubscription?.cancel();
  }

  static void _logError(String message, Object error) {
    if (kDebugMode) debugPrint('$message (${error.runtimeType})');
  }

  static Future<void> _protect(Future<void> Function() action) async {
    try {
      await action();
    } catch (error) {
      _logError('Push operation failed', error);
    }
  }
}
