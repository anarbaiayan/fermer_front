import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/core/network/api_exceptions.dart';
import 'package:frontend/core/router/app_router.dart';
import 'package:frontend/features/finance/application/finance_providers.dart';
import 'package:frontend/features/finance/data/mock/mock_finance_repository.dart';
import 'package:frontend/features/finance/domain/entities/finance_entities.dart';
import 'package:frontend/features/finance/presentation/pages/finance_sale_form_screen.dart';
import 'package:frontend/features/finance/presentation/tabs/finance_expense_tab.dart';
import 'package:frontend/features/finance/presentation/tabs/finance_income_tab.dart';
import 'package:frontend/features/finance/presentation/tabs/finance_summary_tab.dart';
import 'package:frontend/features/finance/presentation/widgets/finance_chips.dart';
import 'package:frontend/features/notifications/application/notifications_providers.dart';
import 'package:frontend/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final _l10n = lookupAppLocalizations(const Locale('ru'));
final _nbsp = String.fromCharCode(0x00A0);
final _minus = String.fromCharCode(0x2212);

String _money(String digits) => '${digits.replaceAll(' ', _nbsp)}$_nbsp₸';

MockFinanceRepository _repo() => MockFinanceRepository(
  clock: () => DateTime(2026, 9, 19, 12),
  latency: Duration.zero,
);

/// Бэкенд пока не отдаёт `/debts`.
class _NoDebtsRepository extends MockFinanceRepository {
  _NoDebtsRepository()
    : super(clock: () => DateTime(2026, 9, 19, 12), latency: Duration.zero);

  @override
  Future<List<CounterpartyDebt>> getDebts() async =>
      throw ApiException('Not Found', 404);
}

Future<void> _pump(
  WidgetTester tester,
  MockFinanceRepository repo, {
  String location = '/finance',
}) async {
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);

  final router = GoRouter(
    initialLocation: location,
    routes: appRouter.configuration.routes,
  );
  addTearDown(router.dispose);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        financeRepositoryProvider.overrideWithValue(repo),
        financeClockProvider.overrideWithValue(() => DateTime(2026, 9, 19, 12)),
        unreadNotificationsCountProvider.overrideWith((ref) async => 0),
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
}

final _page = find
    .byWidgetPredicate(
      (widget) =>
          widget is Scrollable && widget.axisDirection == AxisDirection.down,
    )
    .first;

Future<void> _reveal(WidgetTester tester, Finder finder) async {
  if (finder.evaluate().isNotEmpty) return;
  await tester.scrollUntilVisible(finder, 200, scrollable: _page);
}

Future<void> _tap(WidgetTester tester, Finder finder) async {
  await _reveal(tester, finder);
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

Future<void> _expectOne(WidgetTester tester, Finder finder) async {
  await _reveal(tester, finder);
  expect(finder, findsOneWidget);
}

/// Строка категории: подпись, процент и сумма в одной строке.
Finder _categoryRow(String label, String percent, String digits) =>
    find.ancestor(
      of: find.text(label),
      matching: find.byWidgetPredicate(
        (widget) =>
            widget is Row &&
            widget.children.whereType<Text>().any((t) => t.data == percent),
      ),
    );

void main() {
  testWidgets('profit, income and expense of the month', (tester) async {
    await _pump(tester, _repo());

    expect(find.byType(FinanceSummaryTab), findsOneWidget);
    expect(find.text('ПРИБЫЛЬ ЗА СЕНТЯБРЬ'), findsOneWidget);
    expect(find.text('+$_nbsp${_money('72 900')}'), findsOneWidget);
    expect(find.text(_money('666 400')), findsOneWidget);
    expect(
      find.text(_l10n.financeUnpaidAmount(_money('351 000'))),
      findsOneWidget,
    );
    expect(find.text(_money('593 500')), findsWidgets);
  });

  testWidgets('a month in the red shows the minus', (tester) async {
    await _pump(tester, _repo());
    await _tap(tester, find.byTooltip(_l10n.financePrevMonth));

    expect(find.text('ПРИБЫЛЬ ЗА АВГУСТ'), findsOneWidget);
    expect(find.text('$_minus$_nbsp${_money('11 000')}'), findsOneWidget);
  });

  testWidgets('balances of active accounts with their total', (tester) async {
    await _pump(tester, _repo());

    await _expectOne(tester, find.text(_l10n.financeBalancesTitle));
    expect(find.text(_money('1 433 900')), findsOneWidget);
    expect(find.text(_money('161 900')), findsOneWidget);
    expect(find.text(_money('922 000')), findsOneWidget);
    expect(find.text('Старая карта'), findsNothing);

    await _tap(tester, find.text('Kaspi'));
    expect(find.byType(FinanceSummaryTab), findsNothing);
    expect(find.text(_l10n.financeAccountBalanceNow), findsOneWidget);
  });

  testWidgets('debts: who owes and how long it is overdue', (tester) async {
    await _pump(tester, _repo());

    await _expectOne(tester, find.text(_l10n.financeOwedToYou));
    expect(find.text(_money('378 000')), findsOneWidget);
    expect(
      find.text(_l10n.financeOverdueAmount(_money('172 000'))),
      findsOneWidget,
    );
    await _expectOne(tester, find.text('Кафе «Жайлау»'));
    expect(find.text(_l10n.financeDebtOverdueDays(16)), findsOneWidget);
    expect(find.text(_l10n.financeDebtOverdueDays(6)), findsOneWidget);
    expect(find.text(_l10n.financeDebtDueUntil('29.09')), findsOneWidget);
    expect(find.text(_money('285 000')), findsOneWidget);

    await _tap(tester, find.text(_l10n.financeOwedToYou));
    expect(find.text(_l10n.financeDebtsTitle), findsOneWidget);
    expect(find.byType(FinanceSummaryTab), findsNothing);
  });

  testWidgets('without the debts endpoint the card keeps the totals', (
    tester,
  ) async {
    await _pump(tester, _NoDebtsRepository());

    await _expectOne(tester, find.text(_l10n.financeOwedToYou));
    expect(find.text(_money('378 000')), findsOneWidget);
    expect(find.text('Кафе «Жайлау»'), findsNothing);
  });

  testWidgets('categories add up to the total', (tester) async {
    await _pump(tester, _repo());

    await _expectOne(tester, find.text(_l10n.financeTotal));
    expect(
      _categoryRow(_l10n.financeCategoryFeed, '66%', '390 000'),
      findsOneWidget,
    );
    expect(
      _categoryRow(_l10n.financeCategorySalary, '13%', '75 000'),
      findsOneWidget,
    );
    expect(find.text(_money('390 000')), findsOneWidget);
    expect(find.text(_money('593 500')), findsNWidgets(2));
  });

  testWidgets('a category opens expenses filtered by it', (tester) async {
    await _pump(tester, _repo());

    await _tap(tester, find.text(_l10n.financeCategoryOther));
    expect(find.byType(FinanceExpenseTab), findsOneWidget);
    final chip = tester.widget<FinanceChip>(
      find.widgetWithText(FinanceChip, _l10n.financeCategoryOther),
    );
    expect(chip.selected, isTrue);
    expect(find.text('Электричество'), findsOneWidget);
    expect(find.text('Сено, 40 рулонов'), findsNothing);
    // Выбранный чип в конце ряда выехал на экран.
    final rect = tester.getRect(
      find.widgetWithText(FinanceChip, _l10n.financeCategoryOther),
    );
    expect(rect.right, lessThanOrEqualTo(360));
  });

  testWidgets('income and expense totals open their tabs', (tester) async {
    await _pump(tester, _repo());

    await _tap(tester, find.text(_money('666 400')));
    expect(find.byType(FinanceIncomeTab), findsOneWidget);

    await _tap(tester, find.text(_l10n.financeTabSummary));
    await _tap(tester, find.text(_l10n.financeTabExpense).first);
    expect(find.byType(FinanceExpenseTab), findsOneWidget);
  });

  testWidgets('a month without records', (tester) async {
    await _pump(tester, _repo());
    await _tap(tester, find.byTooltip(_l10n.financePrevMonth));
    await _tap(tester, find.byTooltip(_l10n.financePrevMonth));

    expect(find.text('+$_nbsp${_money('0')}'), findsOneWidget);
    await _expectOne(tester, find.text(_l10n.financeNoExpensesFor('июль')));
  });

  testWidgets('a sale can be added right from the summary', (tester) async {
    await _pump(tester, _repo());
    await _tap(tester, find.text('+ ${_l10n.financeAddSale}'));
    expect(find.byType(FinanceSaleFormScreen), findsOneWidget);
  });
}
