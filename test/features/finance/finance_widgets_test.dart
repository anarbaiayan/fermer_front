import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/core/localization/l10n_extension.dart';
import 'package:frontend/features/finance/application/finance_providers.dart';
import 'package:frontend/features/finance/domain/entities/finance_entities.dart';
import 'package:frontend/features/finance/domain/entities/finance_enums.dart';
import 'package:frontend/features/finance/domain/entities/money.dart';
import 'package:frontend/features/finance/presentation/pages/finance_screen.dart';
import 'package:frontend/features/finance/presentation/pages/finance_stub_screen.dart';
import 'package:frontend/features/finance/presentation/widgets/expense_category_tiles.dart';
import 'package:frontend/features/finance/presentation/widgets/finance_chips.dart';
import 'package:frontend/features/finance/presentation/widgets/finance_common.dart';
import 'package:frontend/features/finance/presentation/widgets/finance_segmented_control.dart';
import 'package:frontend/features/more/presentation/pages/more_screen.dart';
import 'package:frontend/features/notifications/application/notifications_providers.dart';
import 'package:frontend/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final _ru = lookupAppLocalizations(const Locale('ru'));
final _kk = lookupAppLocalizations(const Locale('kk'));

final _overrides = [
  financeClockProvider.overrideWithValue(() => DateTime(2026, 9, 19, 12)),
  unreadNotificationsCountProvider.overrideWith((ref) async => 0),
];

Widget _app({required Widget home, Locale locale = const Locale('ru')}) =>
    ProviderScope(
      overrides: _overrides,
      child: MaterialApp(
        locale: locale,
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: Scaffold(body: home),
      ),
    );

GoRouter _router(String initialLocation) {
  Widget stub(String Function(AppLocalizations) title) => Builder(
    builder: (context) => FinanceStubScreen(title: title(context.l10n)),
  );
  return GoRouter(
    initialLocation: initialLocation,
    routes: [
      GoRoute(path: '/more', builder: (context, state) => const MoreScreen()),
      GoRoute(
        path: '/finance/settings',
        builder: (context, state) => stub((l) => l.financeSettingsTitle),
      ),
      GoRoute(
        path: '/finance/sales/new',
        builder: (context, state) => stub((l) => l.financeSaleNewTitle),
      ),
      GoRoute(
        path: '/finance/expenses/new',
        builder: (context, state) => stub((l) => l.financeExpenseNewTitle),
      ),
      GoRoute(
        path: '/finance',
        builder: (context, state) => FinanceScreen(
          initialTab: FinanceTab.fromQuery(state.uri.queryParameters['tab']),
        ),
      ),
    ],
  );
}

Future<GoRouter> _pumpRouter(WidgetTester tester, String location) async {
  final router = _router(location);
  addTearDown(router.dispose);
  await tester.pumpWidget(
    ProviderScope(
      overrides: _overrides,
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

void main() {
  group('FinanceScreen', () {
    testWidgets('shows the header, tabs and the current month', (tester) async {
      await _pumpRouter(tester, '/finance');

      expect(find.text(_ru.financeTitle), findsOneWidget);
      for (final tab in [
        _ru.financeTabSummary,
        _ru.financeTabIncome,
        _ru.financeTabExpense,
        _ru.financeTabReport,
      ]) {
        expect(find.text(tab), findsOneWidget);
      }
      expect(find.text('Сентябрь 2026'), findsOneWidget);
      expect(find.byType(FinanceAddButton), findsNothing);
    });

    testWidgets('months go back but not into the future', (tester) async {
      await _pumpRouter(tester, '/finance');

      await tester.tap(find.byTooltip(_ru.financeNextMonth));
      await tester.pump();
      expect(find.text('Сентябрь 2026'), findsOneWidget);

      await tester.tap(find.byTooltip(_ru.financePrevMonth));
      await tester.pump();
      expect(find.text('Август 2026'), findsOneWidget);

      await tester.tap(find.byTooltip(_ru.financeNextMonth));
      await tester.pump();
      expect(find.text('Сентябрь 2026'), findsOneWidget);
    });

    testWidgets('the month is shared between tabs', (tester) async {
      await _pumpRouter(tester, '/finance');
      await tester.tap(find.byTooltip(_ru.financePrevMonth));
      await tester.pump();

      await tester.tap(find.text(_ru.financeTabIncome));
      await tester.pump();
      expect(find.text('Август 2026'), findsOneWidget);

      await tester.tap(find.text(_ru.financeTabReport));
      await tester.pump();
      expect(find.text('Август 2026'), findsNothing);
    });

    testWidgets('income tab adds a sale, expense tab adds an expense', (
      tester,
    ) async {
      final router = await _pumpRouter(tester, '/finance?tab=income');

      expect(find.text(_ru.financeAddSale), findsOneWidget);
      await tester.tap(find.byType(FinanceAddButton));
      await tester.pumpAndSettle();
      expect(find.text(_ru.financeSaleNewTitle), findsOneWidget);

      router.pop();
      await tester.pumpAndSettle();
      expect(find.text(_ru.financeAddSale), findsOneWidget);

      await tester.tap(find.text(_ru.financeTabExpense));
      await tester.pump();
      await tester.tap(find.byType(FinanceAddButton));
      await tester.pumpAndSettle();
      expect(find.text(_ru.financeExpenseNewTitle), findsOneWidget);
    });

    testWidgets('the gear opens accounts and buyers', (tester) async {
      await _pumpRouter(tester, '/finance');
      await tester.tap(find.byTooltip(_ru.financeSettingsTitle));
      await tester.pumpAndSettle();

      final stub = tester.widget<FinanceStubScreen>(
        find.byType(FinanceStubScreen),
      );
      expect(stub.title, _ru.financeSettingsTitle);
    });

    testWidgets('More opens Finance', (tester) async {
      await _pumpRouter(tester, '/more');
      final item = find.text(_ru.financeTitle);
      expect(item, findsOneWidget);
      expect(find.text(_ru.financeNewBadge), findsOneWidget);

      await tester.tap(item);
      await tester.pumpAndSettle();
      expect(find.byType(FinanceScreen), findsOneWidget);
    });
  });

  group('shared widgets', () {
    testWidgets('category tiles fit a narrow phone in Kazakh', (tester) async {
      ExpenseCategory? picked;
      await tester.pumpWidget(
        _app(
          locale: const Locale('kk'),
          home: Center(
            child: SizedBox(
              width: 312,
              child: StatefulBuilder(
                builder: (context, setState) => ExpenseCategoryTiles(
                  selected: picked,
                  onChanged: (value) => setState(() => picked = value),
                ),
              ),
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
      expect(find.text(_kk.financeCategoryVeterinary), findsOneWidget);

      await tester.tap(find.text(_kk.financeCategoryEquipment));
      await tester.pump();
      expect(picked, ExpenseCategory.equipment);
      expect(find.byIcon(Icons.check_rounded), findsOneWidget);
    });

    testWidgets('sale status pills', (tester) async {
      final today = DateTime.utc(2026, 9, 19);
      Sale sale({bool paid = false, DateTime? due}) => Sale(
        id: 1,
        saleDate: DateTime.utc(2026, 9, 1),
        productName: 'Молоко',
        quantity: const Quantity.whole(1),
        unit: SaleUnit.liter,
        pricePerUnit: Money.tenge(1),
        amount: Money.tenge(1),
        paid: paid,
        dueDate: due,
      );

      await tester.pumpWidget(
        _app(
          home: Column(
            children: [
              SaleStatusPill(sale: sale(paid: true), today: today),
              SaleStatusPill(
                sale: sale(due: DateTime.utc(2026, 9, 24)),
                today: today,
              ),
              SaleStatusPill(
                sale: sale(due: DateTime.utc(2026, 9, 13)),
                today: today,
              ),
              SaleStatusPill(sale: sale(), today: today),
            ],
          ),
        ),
      );

      expect(find.text('Оплачено'), findsOneWidget);
      expect(find.text('В долг до 24.09'), findsOneWidget);
      expect(find.text('Просрочено 6 дн.'), findsOneWidget);
      expect(find.text('В долг'), findsOneWidget);
    });

    testWidgets('segmented control and chips report taps', (tester) async {
      var paid = true;
      var chipTaps = 0;
      await tester.pumpWidget(
        _app(
          home: StatefulBuilder(
            builder: (context, setState) => Column(
              children: [
                FinanceSegmentedControl<bool>(
                  segments: const {true: 'Оплачено', false: 'В долг'},
                  selected: paid,
                  onChanged: (value) => setState(() => paid = value),
                ),
                FinanceChipRow(
                  children: [
                    FinanceChip(
                      label: 'Касса',
                      icon: 'cash',
                      selected: true,
                      onTap: () => chipTaps++,
                    ),
                    FinanceChip.add(label: 'Новый', onTap: () => chipTaps++),
                  ],
                ),
              ],
            ),
          ),
        ),
      );

      await tester.tap(find.text('В долг'));
      await tester.pump();
      expect(paid, isFalse);

      await tester.tap(find.text('Касса'));
      await tester.tap(find.text('Новый'));
      expect(chipTaps, 2);
    });
  });
}
