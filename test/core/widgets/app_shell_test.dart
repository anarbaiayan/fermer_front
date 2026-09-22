import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/core/router/app_router.dart';
import 'package:frontend/core/widgets/app_scaffold.dart';
import 'package:frontend/core/widgets/app_shell.dart';
import 'package:frontend/core/widgets/fermer_plus_drawer.dart';
import 'package:frontend/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final _l10n = lookupAppLocalizations(const Locale('ru'));

const _tabs = ['/home', '/herd', '/events', '/lactation', '/more'];

/// A bar screen the way real pages build it: AppScaffold with a nav index.
class _Page extends StatelessWidget {
  const _Page(this.path);

  final String path;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      farmName: 'Ферма',
      showAppBar: false,
      bottomNavIndex: AppShell.indexForPath(path),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('page $path'),
            TextButton(
              onPressed: () => AppShellScope.maybeOf(context)!.openDrawer(),
              child: const Text('menu'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Mirrors the page types of the real shell in app_router.dart.
GoRouter _router() => GoRouter(
  initialLocation: '/home',
  routes: [
    GoRoute(
      path: '/details',
      builder: (context, state) => const Scaffold(body: Text('details')),
    ),
    ShellRoute(
      builder: (context, state, child) => AppShell(
        currentIndex: AppShell.indexForPath(state.topRoute?.path),
        child: child,
      ),
      routes: [
        for (final path in _tabs)
          GoRoute(
            path: path,
            pageBuilder: (context, state) =>
                NoTransitionPage(key: state.pageKey, child: _Page(path)),
          ),
        GoRoute(
          path: '/rations',
          builder: (context, state) => const _Page('/rations'),
        ),
      ],
    ),
  ],
);

final _platforms = TargetPlatformVariant(<TargetPlatform>{
  TargetPlatform.android,
  TargetPlatform.iOS,
});

Future<GoRouter> _pumpApp(WidgetTester tester) async {
  final router = _router();
  addTearDown(router.dispose);
  await tester.pumpWidget(
    ProviderScope(
      child: MaterialApp.router(
        routerConfig: router,
        locale: const Locale('ru'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
      ),
    ),
  );
  await tester.pumpAndSettle();
  return router;
}

Finder get _bar => find.byType(BottomNavigationBar);

int _selectedTab(WidgetTester tester) =>
    tester.widget<BottomNavigationBar>(_bar).currentIndex;

void main() {
  testWidgets(
    'switching tabs keeps the same bar and swaps the page instantly',
    (tester) async {
      await _pumpApp(tester);
      final barState = tester.state(_bar);
      final barRect = tester.getRect(_bar);

      await tester.tap(find.text(_l10n.navHerd));
      await tester.pump();

      expect(find.text('page /herd'), findsOneWidget);
      expect(find.text('page /home'), findsNothing);
      expect(_bar, findsOneWidget);
      expect(tester.state(_bar), same(barState));
      expect(tester.getRect(_bar), barRect);
      expect(_selectedTab(tester), 1);

      await tester.tap(find.text(_l10n.navMore));
      await tester.pump();
      expect(find.text('page /more'), findsOneWidget);
      expect(tester.state(_bar), same(barState));
      expect(_selectedTab(tester), 4);
    },
    variant: _platforms,
  );

  testWidgets('a section opened from More slides in above a fixed bar', (
    tester,
  ) async {
    final router = await _pumpApp(tester);
    router.go('/more');
    await tester.pumpAndSettle();
    final barState = tester.state(_bar);
    final barRect = tester.getRect(_bar);

    router.push('/rations');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 120));

    // Mid-transition: the page moves, the bar does not.
    expect(tester.getRect(_bar), barRect);
    expect(tester.state(_bar), same(barState));

    await tester.pumpAndSettle();
    expect(find.text('page /rations'), findsOneWidget);
    expect(_bar, findsOneWidget);
    expect(tester.state(_bar), same(barState));
    expect(_selectedTab(tester), 4);

    router.pop();
    await tester.pumpAndSettle();
    expect(find.text('page /more'), findsOneWidget);
    expect(tester.state(_bar), same(barState));
  }, variant: _platforms);

  testWidgets(
    'iOS swipe back inside the shell keeps the bar in place',
    (tester) async {
      final router = await _pumpApp(tester);
      router.go('/more');
      await tester.pumpAndSettle();
      router.push('/rations');
      await tester.pumpAndSettle();
      final barState = tester.state(_bar);
      final barRect = tester.getRect(_bar);

      final gesture = await tester.startGesture(const Offset(5, 300));
      await gesture.moveBy(const Offset(200, 0));
      await tester.pump();
      expect(tester.getRect(_bar), barRect);

      await gesture.moveBy(const Offset(400, 0));
      await gesture.up();
      await tester.pumpAndSettle();

      expect(find.text('page /more'), findsOneWidget);
      expect(tester.state(_bar), same(barState));
    },
    variant: TargetPlatformVariant.only(TargetPlatform.iOS),
  );

  testWidgets(
    'edge swipe on a tab opens the drawer, as before the shell',
    (tester) async {
      await _pumpApp(tester);
      await tester.dragFrom(const Offset(5, 300), const Offset(400, 0));
      await tester.pumpAndSettle();
      expect(find.byType(FermerPlusDrawer), findsOneWidget);
    },
    variant: _platforms,
  );

  testWidgets(
    'a full-screen route covers the bar and returns to the same bar',
    (tester) async {
      final router = await _pumpApp(tester);
      router.go('/herd');
      await tester.pumpAndSettle();
      final barState = tester.state(_bar);

      router.push('/details');
      await tester.pumpAndSettle();
      expect(find.text('details'), findsOneWidget);
      expect(_bar, findsNothing);

      router.pop();
      await tester.pumpAndSettle();
      expect(tester.state(_bar), same(barState));
      expect(_selectedTab(tester), 1);
    },
    variant: _platforms,
  );

  testWidgets('pages inside the shell do not render their own bar', (
    tester,
  ) async {
    await _pumpApp(tester);
    expect(_bar, findsOneWidget);
    expect(
      find.descendant(of: find.byType(AppScaffold), matching: _bar),
      findsNothing,
    );
  });

  testWidgets('the menu opens the shell drawer over the whole screen', (
    tester,
  ) async {
    await _pumpApp(tester);
    await tester.tap(find.text('menu'));
    await tester.pumpAndSettle();

    final drawer = find.byType(FermerPlusDrawer);
    expect(drawer, findsOneWidget);
    expect(
      find.descendant(of: find.byType(AppScaffold), matching: drawer),
      findsNothing,
    );
  });

  group('app router', () {
    setUpAll(TestWidgetsFlutterBinding.ensureInitialized);

    bool inShell(String location) =>
        appRouter.configuration.findMatch(Uri.parse(location)).matches.first
            is ShellRouteMatch;

    test('bar screens live in the shell, forms and cards outside', () {
      for (final location in [
        '/home',
        '/herd',
        '/events',
        '/lactation',
        '/more',
        '/rations',
        '/rations/stocks',
        '/rations/stocks/JUICY',
        '/pharmacy',
        '/vet-consultants',
      ]) {
        expect(inShell(location), isTrue, reason: location);
      }
      for (final location in [
        '/herd/5',
        '/herd/add',
        '/rations/stocks/add',
        '/rations/cattle/3',
        '/pharmacy/requests',
        '/notifications',
        '/profile',
        '/login',
      ]) {
        expect(inShell(location), isFalse, reason: location);
      }
    });

    test('shell routes highlight the same tab their screens declared', () {
      const expected = {
        '/home': 0,
        '/herd': 1,
        '/events': 2,
        '/lactation': 3,
        '/more': 4,
        '/rations': 4,
        '/rations/stocks': 4,
        '/rations/stocks/:type': 4,
        '/pharmacy': 4,
        '/vet-consultants': 4,
      };
      final shell = appRouter.configuration.routes
          .whereType<ShellRoute>()
          .single;
      final paths = shell.routes.cast<GoRoute>().map((r) => r.path).toSet();

      expect(paths, expected.keys.toSet());
      for (final entry in expected.entries) {
        expect(
          AppShell.indexForPath(entry.key),
          entry.value,
          reason: entry.key,
        );
      }
    });
  });
}
