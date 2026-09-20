import 'package:frontend/core/network/network_providers.dart';
import 'package:frontend/features/notifications/application/notifications_providers.dart';
import 'package:frontend/features/notifications/data/datasources/notifications_api.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'push_notification_router.dart';
import 'push_notification_service.dart';

final pushNotificationRouterProvider = Provider<PushNotificationRouter>((ref) {
  return PushNotificationRouter();
});

final pushNotificationServiceProvider = Provider<PushNotificationService>((
  ref,
) {
  final service = PushNotificationService(
    notificationsApi: ref.read(notificationsApiProvider),
    tokenRepository: ref.read(tokenRepositoryProvider),
    router: ref.read(pushNotificationRouterProvider),
    onNotificationReceived: () {
      ref.invalidate(unreadNotificationsCountProvider);
      ref.invalidate(notificationsFeedProvider(false));
    },
  );
  ref.onDispose(service.dispose);
  return service;
});
