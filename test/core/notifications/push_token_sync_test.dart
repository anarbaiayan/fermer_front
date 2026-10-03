import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/core/notifications/push_token_sync.dart';

void main() {
  late PushTokenSync sync;
  late bool ready;
  late bool authenticated;
  late bool failRegistration;
  late int tokenReads;
  late int registrations;
  late List<String> stored;

  setUp(() {
    ready = true;
    authenticated = true;
    failRegistration = false;
    tokenReads = 0;
    registrations = 0;
    stored = [];
    sync = PushTokenSync(
      isReady: () async => ready,
      getToken: () async {
        tokenReads++;
        return 'token';
      },
      storeToken: (token) async => stored.add(token),
      hasSession: () async => authenticated,
      registerToken: (_) async {
        registrations++;
        if (failRegistration) throw StateError('offline');
      },
    );
  });

  tearDown(() => sync.dispose());

  testWidgets(
    'does not call FCM until APNs is ready, even after five seconds',
    (tester) async {
      ready = false;
      await sync.start();
      await tester.pump(const Duration(seconds: 2));
      await tester.pump(const Duration(seconds: 4));
      expect(tokenReads, 0);
      expect(registrations, 0);
      ready = true;
      await tester.pump(const Duration(seconds: 8));
      expect(registrations, 1);
      sync.dispose();
    },
  );

  testWidgets('retries registration after a network failure', (tester) async {
    failRegistration = true;
    await sync.start();
    expect(registrations, 1);
    failRegistration = false;
    await tester.pump(const Duration(seconds: 2));
    expect(registrations, 2);
    await tester.pump(const Duration(minutes: 2));
    expect(registrations, 2);
  });

  testWidgets('pauses retries and synchronizes immediately on resume', (
    tester,
  ) async {
    failRegistration = true;
    await sync.start();
    sync.pause();
    await tester.pump(const Duration(minutes: 2));
    expect(registrations, 1);
    failRegistration = false;
    await sync.resume();
    expect(registrations, 2);
  });

  testWidgets('logout cancels retries and ignores token refresh', (
    tester,
  ) async {
    failRegistration = true;
    await sync.start();
    sync.stop();
    await sync.synchronize(token: 'new-token');
    await sync.resume();
    await tester.pump(const Duration(minutes: 2));
    expect(registrations, 1);
  });

  test('anonymous token is stored but never registered', () async {
    authenticated = false;
    await sync.start();
    expect(stored, ['token']);
    expect(registrations, 0);
    authenticated = true;
    await sync.start();
    expect(registrations, 1);
  });

  test('logout during token acquisition prevents registration', () async {
    final token = Completer<String?>();
    sync.dispose();
    sync = PushTokenSync(
      isReady: () async => true,
      getToken: () => token.future,
      storeToken: (value) async => stored.add(value),
      hasSession: () async => true,
      registerToken: (_) async => registrations++,
    );
    final pending = sync.start();
    await Future<void>.delayed(Duration.zero);
    sync.stop();
    token.complete('old-account-token');
    await pending;
    expect(stored, isEmpty);
    expect(registrations, 0);
  });

  test('token rotation is queued behind an in-flight registration', () async {
    final first = Completer<void>();
    final registered = <String>[];
    sync.dispose();
    sync = PushTokenSync(
      isReady: () async => true,
      getToken: () async => 'old',
      storeToken: (_) async {},
      hasSession: () async => true,
      registerToken: (token) async {
        registered.add(token);
        if (registered.length == 1) await first.future;
      },
    );
    final pending = sync.start();
    await Future<void>.delayed(Duration.zero);
    unawaited(sync.synchronize(token: 'new'));
    expect(registered, ['old']);
    first.complete();
    await pending;
    await Future<void>.delayed(Duration.zero);
    expect(registered, ['old', 'new']);
  });

  testWidgets('permanent registration errors are not retried on a timer', (
    tester,
  ) async {
    sync.dispose();
    sync = PushTokenSync(
      isReady: () async => true,
      getToken: () async => 'token',
      storeToken: (_) async {},
      hasSession: () async => true,
      registerToken: (_) async {
        registrations++;
        throw StateError('invalid request');
      },
      shouldRetry: (_) => false,
    );
    await sync.start();
    await tester.pump(const Duration(minutes: 2));
    expect(registrations, 1);
  });
}
