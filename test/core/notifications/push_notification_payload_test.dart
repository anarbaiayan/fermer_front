import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/core/notifications/push_notification_payload.dart';

void main() {
  test('parses notification data from FCM payload', () {
    final payload = PushNotificationPayload.fromMessage(
      data: {
        'notificationId': '123',
        'type': 'PLANNED_EVENT',
        'cattleId': '45',
      },
      title: 'Reminder',
      body: 'Vaccination due',
    );

    expect(payload.notificationId, '123');
    expect(payload.type, 'PLANNED_EVENT');
    expect(payload.cattleId, 45);
    expect(payload.title, 'Reminder');
    expect(payload.body, 'Vaccination due');
  });
}
