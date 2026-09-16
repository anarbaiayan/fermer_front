import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/core/notifications/push_notification_payload.dart';
import 'package:frontend/core/notifications/push_notification_router.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _plannedEvent = PushNotificationPayload(
  notificationId: '1',
  type: 'PLANNED_EVENT',
  cattleId: 42,
  title: 'Reminder',
  body: 'Vaccination due',
);

void main() {
  late List<String> navigation;
  late PushNotificationRouter router;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    navigation = [];
    router = PushNotificationRouter(
      go: (location) => navigation.add('go $location'),
      push: (location) => navigation.add('push $location'),
      // Синхронно: здесь проверяется порядок, а не кадры.
      afterNavigation: (callback) => callback(),
    );
  });

  test('opens cattle card on top of home for planned event', () {
    router.navigateAuthenticated(_plannedEvent);

    expect(navigation, ['go /home', 'push /herd/42']);
  });

  test('opens notifications on top of home for an unknown push type', () {
    router.navigateAuthenticated(
      const PushNotificationPayload(
        notificationId: '1',
        type: 'UNKNOWN',
        cattleId: 42,
        title: null,
        body: null,
      ),
    );

    expect(navigation, ['go /home', 'push /notifications']);
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

    expect(navigation, ['go /home', 'push /notifications']);
  });

  test('keeps logged-out push pending and consumes it after login', () async {
    await router.savePending(_plannedEvent);

    expect(
      await router.handlePendingNavigation(isAuthenticated: false),
      isFalse,
    );
    expect(navigation, isEmpty);
    expect(await router.handlePendingNavigation(isAuthenticated: true), isTrue);
    expect(navigation, ['go /home', 'push /herd/42']);
    expect(
      await router.handlePendingNavigation(isAuthenticated: true),
      isFalse,
    );
  });

  testWidgets('back from a card opened by push returns to home', (
    tester,
  ) async {
    // Настоящий GoRouter: push сразу после go мог бы лечь поверх старого
    // стека, поэтому проверяем именно реальное поведение роутера.
    final goRouter = GoRouter(
      initialLocation: '/splash',
      routes: [
        GoRoute(path: '/splash', builder: (_, _) => const Text('splash')),
        GoRoute(path: '/home', builder: (_, _) => const Text('home')),
        GoRoute(
          path: '/herd/:id',
          builder: (_, state) => Text('cattle ${state.pathParameters['id']}'),
        ),
      ],
    );
    addTearDown(goRouter.dispose);
    await tester.pumpWidget(MaterialApp.router(routerConfig: goRouter));

    PushNotificationRouter(
      go: goRouter.go,
      push: (location) => goRouter.push(location),
    ).navigateAuthenticated(_plannedEvent);
    await tester.pumpAndSettle();

    expect(find.text('cattle 42'), findsOneWidget);
    expect(goRouter.canPop(), isTrue);

    // То, что делает кнопка "Закрыть" на карточке.
    goRouter.pop();
    await tester.pumpAndSettle();

    expect(find.text('home'), findsOneWidget);
    expect(goRouter.state.matchedLocation, '/home');
    expect(goRouter.canPop(), isFalse);
  });
}
