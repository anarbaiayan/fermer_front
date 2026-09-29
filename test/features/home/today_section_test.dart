import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/core/network/api_exceptions.dart';
import 'package:frontend/core/router/app_router.dart';
import 'package:frontend/features/cattle_events/application/planned_events_providers.dart';
import 'package:frontend/features/cattle_events/domain/entities/planned_event.dart';
import 'package:frontend/features/finance/application/finance_providers.dart';
import 'package:frontend/features/finance/data/mock/mock_finance_repository.dart';
import 'package:frontend/features/finance/domain/entities/finance_enums.dart';
import 'package:frontend/features/finance/domain/entities/finance_inputs.dart';
import 'package:frontend/features/finance/domain/entities/money.dart';
import 'package:frontend/features/herd/application/herd_providers.dart';
import 'package:frontend/features/herd/data/models/cattle_statistics_dto.dart';
import 'package:frontend/features/home/presentation/widgets/briefSection/search_field.dart';
import 'package:frontend/features/home/presentation/widgets/todaySection/today_section.dart';
import 'package:frontend/features/lactation/application/lactation_providers.dart';
import 'package:frontend/features/lactation/data/models/lactation_daily_summary_dto.dart';
import 'package:frontend/features/notifications/application/notifications_providers.dart';
import 'package:frontend/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final _l10n = lookupAppLocalizations(const Locale('ru'));
final _nbsp = String.fromCharCode(0x00A0);
final _minus = String.fromCharCode(0x2212);

String _money(String digits) => '${digits.replaceAll(' ', _nbsp)}$_nbsp₸';

MockFinanceRepository _repo({bool demo = true}) => MockFinanceRepository(
  clock: () => DateTime(2026, 9, 19, 12),
  latency: Duration.zero,
  withDemoData: demo,
);

LactationDailySummaryDto _milk(double morning, double evening) =>
    LactationDailySummaryDto(
      date: '2026-09-19',
      totalLiters: morning + evening,
      totalKg: (morning + evening) * 1.03,
      cowCount: morning + evening > 0 ? 24 : 0,
      details: [
        if (morning + evening > 0)
          LactationDailySummaryDetailDto(
            cattleId: 1,
            cattleTagNumber: '1045',
            cattleName: 'Бурёнка',
            morningLiters: morning,
            eveningLiters: evening,
            totalLiters: morning + evening,
            totalKg: (morning + evening) * 1.03,
          ),
      ],
    );

PlannedEvent _event(int id, String title, int daysUntil) => PlannedEvent(
  id: id,
  cattleId: id,
  cattleName: 'Бурёнка',
  cattleTagNumber: '10$id',
  daysUntil: daysUntil,
  eventType: 'VACCINATION',
  plannedDate: DateTime(2026, 9, 19 + daysUntil),
  priority: 1,
  title: title,
);

/// Экран с одним блоком «Сегодня»; переходы — на заглушки с адресом.
Future<GoRouter> _pump(
  WidgetTester tester, {
  required MockFinanceRepository repo,
  Future<LactationDailySummaryDto> Function()? milk,
  List<PlannedEvent> events = const [],
}) async {
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);

  Widget stub(GoRouterState state) =>
      Scaffold(body: Center(child: Text('stub ${state.uri}')));
  final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => Scaffold(
          body: ListView(
            padding: const EdgeInsets.all(24),
            children: const [TodaySection()],
          ),
        ),
      ),
      for (final path in [
        '/finance',
        '/finance/sales/new',
        '/finance/expenses/new',
        '/finance/debts',
        '/finance/settings',
        '/lactation',
        '/lactation/bulk/add',
        '/events',
      ])
        GoRoute(path: path, builder: (context, state) => stub(state)),
    ],
  );
  addTearDown(router.dispose);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        financeRepositoryProvider.overrideWithValue(repo),
        financeClockProvider.overrideWithValue(() => DateTime(2026, 9, 19, 12)),
        lactationDailySummaryProvider.overrideWith(
          (ref) => (milk ?? () async => _milk(248, 238))(),
        ),
        plannedEventsProvider.overrideWith((ref, status) async => events),
      ],
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

final _page = find
    .byWidgetPredicate(
      (widget) =>
          widget is Scrollable && widget.axisDirection == AxisDirection.down,
    )
    .first;

Future<void> _tap(WidgetTester tester, Finder finder) async {
  if (finder.evaluate().isEmpty) {
    await tester.scrollUntilVisible(finder, 200, scrollable: _page);
  }
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

Future<void> _see(WidgetTester tester, Finder finder) async {
  if (finder.evaluate().isEmpty) {
    await tester.scrollUntilVisible(finder, 200, scrollable: _page);
  }
  expect(finder, findsOneWidget);
}

void main() {
  testWidgets('a day with records: milk, sales, expenses', (tester) async {
    await _pump(tester, repo: _repo());

    expect(find.text(_l10n.todayTitle), findsOneWidget);
    expect(find.text('суббота, 19 сентября'), findsOneWidget);

    expect(find.text('486 л'), findsOneWidget);
    expect(
      find.text(_l10n.todayMilkSessions('248 л', '238 л')),
      findsOneWidget,
    );
    expect(find.text(_l10n.todaySold), findsOneWidget);
    expect(find.text('Магазин «Достык» · молоко 120 л'), findsOneWidget);
    expect(find.text(_money('30 000')), findsOneWidget);
    expect(find.text('Комбикорм, 2 мешка'), findsOneWidget);
    expect(find.text('$_minus${_money('45 000')}'), findsOneWidget);
    // Записи есть — кнопки внизу карточки.
    expect(find.text('+ ${_l10n.financeAddSale}'), findsOneWidget);
    expect(find.text('+ ${_l10n.financeAddExpense}'), findsOneWidget);
  });

  testWidgets('money, debts and the most overdue buyer', (tester) async {
    await _pump(tester, repo: _repo());

    await _see(tester, find.text(_l10n.todayTotalOnAccounts));
    expect(find.text(_money('1 433 900')), findsOneWidget);
    expect(find.text('Kaspi'), findsOneWidget);

    await _see(tester, find.text(_l10n.financeOwedToYou));
    expect(find.text(_money('378 000')), findsOneWidget);
    expect(
      find.text(_l10n.financeOverdueAmount(_money('172 000'))),
      findsOneWidget,
    );
    expect(find.text('Кафе «Жайлау»'), findsOneWidget);
    expect(
      find.text('${_l10n.financeDebtOverdueDays(16)} · ${_money('27 000')}'),
      findsOneWidget,
    );

    await _tap(tester, find.text(_l10n.financeOwedToYou));
    expect(find.text('stub /finance/debts'), findsOneWidget);
  });

  testWidgets('tasks for today and overdue, three at most', (tester) async {
    await _pump(
      tester,
      repo: _repo(),
      events: [
        _event(1, 'Вакцинация от ящура', -1),
        _event(2, 'Осеменение', 0),
        _event(3, 'Запуск в сухостой', 0),
        _event(4, 'Взвешивание', 0),
        _event(5, 'Отёл', 3),
      ],
    );

    await _see(tester, find.text('Вакцинация от ящура'));
    expect(find.text('Осеменение'), findsOneWidget);
    expect(find.text('Запуск в сухостой'), findsOneWidget);
    expect(find.text('Взвешивание'), findsNothing);
    expect(find.text('Отёл'), findsNothing);
    expect(find.text('Бурёнка · 101'), findsOneWidget);

    await _tap(tester, find.text('Осеменение'));
    expect(find.text('stub /events'), findsOneWidget);
  });

  testWidgets('an empty day invites to record instead of staying blank', (
    tester,
  ) async {
    final repo = _repo(demo: false);
    await repo.createAccount(
      AccountInput(
        name: 'Касса',
        type: AccountType.cash,
        initialBalance: Money.tenge(50000),
      ),
    );
    await _pump(tester, repo: repo, milk: () async => _milk(0, 0));

    expect(find.text(_l10n.todayMilkEmpty), findsOneWidget);
    expect(find.text(_l10n.todayNoSales), findsOneWidget);
    expect(find.text(_l10n.todayNoExpenses), findsOneWidget);
    expect(find.text(_l10n.financeOwedToYou), findsNothing);
    await _see(tester, find.text(_l10n.todayNoTasks));

    await _tap(tester, find.text(_l10n.todayMilkRecord));
    expect(find.text('stub /lactation/bulk/add'), findsOneWidget);
  });

  testWidgets('record a sale right from the empty row', (tester) async {
    await _pump(
      tester,
      repo: _repo(demo: false),
      milk: () async => _milk(0, 0),
    );
    await _tap(tester, find.text('+ ${_l10n.financeAddSale}'));
    expect(find.text('stub /finance/sales/new'), findsOneWidget);
  });

  testWidgets('without accounts it offers to start Finance', (tester) async {
    await _pump(tester, repo: _repo(demo: false));
    await _tap(tester, find.text(_l10n.financeOnboardingStart));
    expect(find.text('stub /finance'), findsOneWidget);
  });

  testWidgets('a milk error can be retried', (tester) async {
    var calls = 0;
    await _pump(
      tester,
      repo: _repo(),
      milk: () async {
        calls++;
        throw ApiException('Нет связи', 503);
      },
    );
    expect(find.text(_l10n.todayMilkError), findsOneWidget);
    await _tap(tester, find.text(_l10n.todayMilkError));
    expect(calls, 2);
  });

  testWidgets('the home screen shows the block above the search', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    final router = GoRouter(
      initialLocation: '/home',
      routes: appRouter.configuration.routes,
    );
    addTearDown(router.dispose);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          financeRepositoryProvider.overrideWithValue(_repo()),
          financeClockProvider.overrideWithValue(
            () => DateTime(2026, 9, 19, 12),
          ),
          lactationDailySummaryProvider.overrideWith(
            (ref) async => _milk(248, 238),
          ),
          plannedEventsProvider.overrideWith((ref, status) async => []),
          unreadNotificationsCountProvider.overrideWith((ref) async => 0),
          cattleStatisticsProvider.overrideWith(
            (ref) async => const CattleStatisticsDto(
              pregnant: 0,
              open: 0,
              inseminated: 0,
              lactating: 0,
              dryPeriod: 0,
              cows: 0,
              heifers: 0,
              calves: 0,
              bulls: 0,
              sick: 0,
              healthy: 0,
              total: 0,
            ),
          ),
        ],
        child: MaterialApp.router(
          routerConfig: router,
          locale: const Locale('ru'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(TodaySection), findsOneWidget);
    await tester.scrollUntilVisible(
      find.byType(SearchField),
      300,
      scrollable: _page,
    );
    expect(
      tester.getTopLeft(find.byType(TodaySection)).dy,
      lessThan(tester.getTopLeft(find.byType(SearchField)).dy),
    );
  });
}
