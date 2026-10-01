import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/app_update/application/app_update_providers.dart';
import 'package:frontend/features/app_update/data/app_version_api.dart';
import 'package:frontend/features/app_update/data/app_version_cache.dart';
import 'package:frontend/features/app_update/domain/app_version_policy.dart';
import 'package:frontend/features/app_update/presentation/app_update_gate.dart';
import 'package:frontend/l10n/app_localizations.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final _l10n = lookupAppLocalizations(const Locale('ru'));

const _installed = InstalledApp(build: 10, version: '1.4.0');
const _storeUrl =
    'https://play.google.com/store/apps/details?id=kz.fermerplus.app';

/// Ответ бэкенда по очереди; `null` — сеть недоступна.
class _FakeApi extends AppVersionApi {
  _FakeApi(this.answers) : super(Dio());

  final List<AppVersionPolicy?> answers;
  int calls = 0;

  @override
  Future<AppVersionPolicy> fetch(StorePlatform platform) async {
    final answer = answers[calls < answers.length ? calls : answers.length - 1];
    calls++;
    if (answer == null) throw DioException(requestOptions: RequestOptions());
    return answer;
  }
}

ProviderContainer _container(
  _FakeApi api, {
  StorePlatform? platform = StorePlatform.android,
  Future<InstalledApp> Function()? loadInstalledApp,
}) {
  final container = ProviderContainer(
    overrides: [
      appUpdatePlatformProvider.overrideWithValue(platform),
      appVersionApiProvider.overrideWithValue(api),
      appVersionCacheProvider.overrideWithValue(AppVersionCache()),
      installedAppLoaderProvider.overrideWithValue(
        loadInstalledApp ?? () async => _installed,
      ),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

/// Создаёт контроллер (он сам запускает проверку) и ждёт её конца.
Future<AppUpdateStatus> _checked(ProviderContainer container) async {
  container.read(appUpdateProvider);
  await container.read(appUpdateProvider.notifier).check();
  return container.read(appUpdateProvider);
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  group('policy', () {
    test('a build below the minimum must update', () {
      const policy = AppVersionPolicy(minBuild: 11);
      expect(policy.blocks(10), isTrue);
      expect(policy.blocks(11), isFalse);
      expect(const AppVersionPolicy(minBuild: 0).blocks(1), isFalse);
    });

    test('backend response', () {
      final policy = appVersionPolicyFromJson({
        'platform': 'IOS',
        'minBuild': 12,
        'storeUrl': ' ',
      });
      expect(policy.minBuild, 12);
      expect(policy.storeUrl, isNull);
      expect(appVersionPolicyFromJson({}).minBuild, 0);
    });
  });

  group('check', () {
    test('blocks an old build with the store link from the backend', () async {
      final api = _FakeApi([
        const AppVersionPolicy(minBuild: 11, storeUrl: 'https://example/app'),
      ]);
      final status = await _checked(_container(api));

      expect(status.updateRequired, isTrue);
      expect(status.storeUrl, 'https://example/app');
      expect(status.installedVersion, '1.4.0');
    });

    test('the current build is not blocked', () async {
      final status = await _checked(
        _container(_FakeApi([const AppVersionPolicy(minBuild: 10)])),
      );
      expect(status.updateRequired, isFalse);
    });

    test(
      'without a store link from the backend opens the known page',
      () async {
        final status = await _checked(
          _container(
            _FakeApi([const AppVersionPolicy(minBuild: 99)]),
            platform: StorePlatform.ios,
          ),
        );
        expect(status.updateRequired, isTrue);
        expect(status.storeUrl, StorePlatform.ios.defaultStoreUrl);
      },
    );

    test('offline: the last known rule still blocks', () async {
      await _checked(
        _container(_FakeApi([const AppVersionPolicy(minBuild: 11)])),
      );

      final offline = _FakeApi([null]);
      final status = await _checked(_container(offline));
      expect(offline.calls, 1);
      expect(status.updateRequired, isTrue);
    });

    test('offline with no known rule the app stays open', () async {
      final status = await _checked(_container(_FakeApi([null])));
      expect(status.updateRequired, isFalse);
    });

    test('a lowered minimum unblocks on the next check', () async {
      final api = _FakeApi([
        const AppVersionPolicy(minBuild: 11),
        const AppVersionPolicy(minBuild: 10),
      ]);
      final container = _container(api);
      expect((await _checked(container)).updateRequired, isTrue);

      await container.read(appUpdateProvider.notifier).check();
      expect(container.read(appUpdateProvider).updateRequired, isFalse);
    });

    test('not a phone or no version info: never blocks', () async {
      final api = _FakeApi([const AppVersionPolicy(minBuild: 99)]);
      expect(
        (await _checked(_container(api, platform: null))).updateRequired,
        isFalse,
      );
      expect(api.calls, 0);

      final status = await _checked(
        _container(
          _FakeApi([const AppVersionPolicy(minBuild: 99)]),
          loadInstalledApp: () async => throw const FormatException(),
        ),
      );
      expect(status.updateRequired, isFalse);
    });
  });

  group('gate', () {
    Future<List<Uri>> pump(
      WidgetTester tester, {
      required int minBuild,
      bool storeOpens = true,
    }) async {
      final opened = <Uri>[];
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            appUpdatePlatformProvider.overrideWithValue(StorePlatform.android),
            appVersionApiProvider.overrideWithValue(
              _FakeApi([
                AppVersionPolicy(minBuild: minBuild, storeUrl: _storeUrl),
              ]),
            ),
            appVersionCacheProvider.overrideWithValue(AppVersionCache()),
            installedAppLoaderProvider.overrideWithValue(
              () async => _installed,
            ),
            appUpdateLauncherProvider.overrideWithValue((uri) async {
              opened.add(uri);
              return storeOpens;
            }),
          ],
          child: const MaterialApp(
            locale: Locale('ru'),
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            home: AppUpdateGate(child: Text('app')),
          ),
        ),
      );
      await tester.pumpAndSettle();
      return opened;
    }

    testWidgets('an old build sees only the update screen', (tester) async {
      final opened = await pump(tester, minBuild: 11);

      expect(find.text('app'), findsNothing);
      expect(find.text(_l10n.updateRequiredTitle), findsOneWidget);
      expect(
        find.text(_l10n.updateRequiredInstalledVersion('1.4.0')),
        findsOneWidget,
      );

      await tester.tap(find.text(_l10n.updateRequiredAction));
      await tester.pumpAndSettle();
      expect(opened, [Uri.parse(_storeUrl)]);
      expect(find.text(_l10n.updateRequiredStoreError), findsNothing);
    });

    testWidgets('a store that does not open shows what to do', (tester) async {
      await pump(tester, minBuild: 11, storeOpens: false);

      await tester.tap(find.text(_l10n.updateRequiredAction));
      await tester.pumpAndSettle();
      expect(find.text(_l10n.updateRequiredStoreError), findsOneWidget);
    });

    testWidgets('the current build sees the app', (tester) async {
      await pump(tester, minBuild: 10);

      expect(find.text('app'), findsOneWidget);
      expect(find.text(_l10n.updateRequiredTitle), findsNothing);
    });
  });
}
