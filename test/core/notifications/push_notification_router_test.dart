import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/core/notifications/push_notification_payload.dart';
import 'package:frontend/core/notifications/push_notification_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late List<String> locations;
  late PushNotificationRouter router;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    locations = [];
    router = PushNotificationRouter(navigate: locations.add);
  });

  test('opens cattle card for planned event with cattle id', () {
    router.navigateAuthenticated(
      const PushNotificationPayload(
        notificationId: '1',
        type: 'PLANNED_EVENT',
        cattleId: 42,
        title: null,
        body: null,
      ),
    );

    expect(locations, ['/herd/42']);
  });

  test('opens notifications for an unknown push type', () {
    router.navigateAuthenticated(
      const PushNotificationPayload(
        notificationId: '1',
        type: 'UNKNOWN',
        cattleId: 42,
        title: null,
        body: null,
      ),
    );

    expect(locations, ['/notifications']);
  });

  test('does not navigate to cattle without cattle id', () {
    router.navigateAuthenticated(
      const PushNotificationPayload(
        notificationId: '1',
        type: 'PLANNED_EVENT',
        cattleId: null,
        title: null,
        body: null,
      ),
    );

    expect(locations, ['/notifications']);
  });

  test('keeps logged-out push pending and consumes it after login', () async {
    const payload = PushNotificationPayload(
      notificationId: '1',
      type: 'PLANNED_EVENT',
      cattleId: 42,
      title: 'Reminder',
      body: 'Vaccination due',
    );
    await router.savePending(payload);

    expect(
      await router.handlePendingNavigation(isAuthenticated: false),
      isFalse,
    );
    expect(locations, isEmpty);
    expect(await router.handlePendingNavigation(isAuthenticated: true), isTrue);
    expect(locations, ['/herd/42']);
    expect(
      await router.handlePendingNavigation(isAuthenticated: true),
      isFalse,
    );
  });
}
