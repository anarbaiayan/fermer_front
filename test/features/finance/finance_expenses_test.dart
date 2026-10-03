import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/core/router/app_router.dart';
import 'package:frontend/features/finance/application/finance_providers.dart';
import 'package:frontend/features/finance/data/mock/mock_finance_repository.dart';
import 'package:frontend/features/finance/domain/entities/finance_enums.dart';
import 'package:frontend/features/finance/domain/entities/finance_inputs.dart';
import 'package:frontend/features/finance/domain/entities/money.dart';
import 'package:frontend/features/finance/presentation/pages/finance_expense_form_screen.dart';
import 'package:frontend/features/finance/presentation/tabs/finance_expense_tab.dart';
import 'package:frontend/features/finance/presentation/widgets/finance_common.dart';
import 'package:frontend/features/notifications/application/notifications_providers.dart';
import 'package:frontend/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final _l10n = lookupAppLocalizations(const Locale('ru'));
final _nbsp = String.fromCharCode(0x00A0);
final _minus = String.fromCharCode(0x2212);

String _money(String digits) => '${digits.replaceAll(' ', _nbsp)}$_nbsp₸';
String _spent(String digits) => _money(digits);

MockFinanceRepository _repo({bool demo = true}) => MockFinanceRepository(
  clock: () => DateTime(2026, 9, 19, 12),
  latency: Duration.zero,
  withDemoData: demo,
);

Future<GoRouter> _pump(
  WidgetTester tester,
  String location,
  MockFinanceRepository repo,
) async {
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

Finder _field(int index) => find.byType(TextField).at(index);

/// Строка «Потрачено …» на вкладке.
Finder _spentLine(String digits) => find.byWidgetPredicate(
  (widget) =>
      widget is RichText &&
      widget.text.toPlainText() ==
          '${_l10n.financeSpentLabel} ${_spent(digits)}',
);

Finder _chip(String label) => find.descendant(
  of: find.byType(FinanceExpenseTab),
  matching: find.text(label),
);

void main() {
  group('expense tab', () {
    testWidgets('month total, count and rows grouped by day', (tester) async {
      await _pump(tester, '/finance?tab=expense', _repo());

      expect(_spentLine('593 500'), findsOneWidget);
      expect(find.text(_l10n.financeRecordsCount(8)), findsOneWidget);
      expect(find.text('Сегодня, 19 сентября'), findsOneWidget);
      expect(find.text('Вчера, 18 сентября'), findsOneWidget);
      expect(find.text('16 сентября, ср'), findsOneWidget);

      expect(find.text('Комбикорм, 2 мешка'), findsOneWidget);
      expect(find.text('Корма · Касса'), findsWidgets);
      expect(find.text('$_minus${_money('45 000')}'), findsOneWidget);

      // Комментарий виден прямо в списке (FP-509).
      final comment = find.text('Агро-Трейд, с доставкой');
      await tester.scrollUntilVisible(comment, 300, scrollable: _page);
      expect(comment, findsOneWidget);
    });

    testWidgets('filters by category', (tester) async {
      await _pump(tester, '/finance?tab=expense', _repo());

      await _tap(tester, _chip(_l10n.financeCategoryFeed));
      expect(_spentLine('390 000'), findsOneWidget);
      expect(find.text(_l10n.financeRecordsCount(3)), findsOneWidget);

      await _tap(tester, _chip(_l10n.financeCategoryRent));
      expect(find.text(_l10n.financeExpensesEmptyTitle), findsOneWidget);

      await _tap(tester, _chip(_l10n.financeFilterAll));
      expect(_spentLine('593 500'), findsOneWidget);
    });

    testWidgets('filters by account; closing the sheet keeps the filter', (
      tester,
    ) async {
      await _pump(tester, '/finance?tab=expense', _repo());

      await _tap(tester, _chip(_l10n.financeAllAccounts));
      await _tap(tester, find.text('Касса').last);
      expect(_spentLine('162 500'), findsOneWidget);
      expect(find.text(_l10n.financeRecordsCount(4)), findsOneWidget);

      // Шторку закрыли жестом — фильтр остался.
      await _tap(tester, _chip('Касса'));
      await tester.tapAt(const Offset(20, 40));
      await tester.pumpAndSettle();
      expect(_spentLine('162 500'), findsOneWidget);
    });

    testWidgets('the previous month', (tester) async {
      await _pump(tester, '/finance?tab=expense', _repo());
      await _tap(tester, find.byTooltip(_l10n.financePrevMonth));
      expect(find.text('Август 2026'), findsOneWidget);
      expect(_spentLine('350 000'), findsOneWidget);
    });

    testWidgets('filters survive a trip to another tab', (tester) async {
      await _pump(tester, '/finance?tab=expense', _repo());
      await _tap(tester, _chip(_l10n.financeCategoryFeed));
      await _tap(tester, find.text(_l10n.financeTabReport));
      await _tap(tester, find.text(_l10n.financeTabExpense));
      expect(_spentLine('390 000'), findsOneWidget);
    });
  });

  group('expense form', () {
    testWidgets('four actions: category, name, amount, save', (tester) async {
      final repo = _repo();
      await _pump(tester, '/finance?tab=expense', repo);
      await _tap(tester, find.byType(FinanceAddButton));
      expect(find.byType(FinanceExpenseFormScreen), findsOneWidget);

      await _tap(tester, find.text(_l10n.financeExpenseSaveNew));
      expect(find.text(_l10n.financeExpenseCategoryError), findsOneWidget);
      expect(find.text(_l10n.financeExpenseNameError), findsOneWidget);
      expect(find.text(_l10n.financeAmountError), findsOneWidget);

      await _tap(tester, find.text(_l10n.financeCategoryFuel));
      await tester.enterText(_field(0), 'Дизель, 60 л');
      await tester.enterText(_field(1), '20000');
      await tester.pump();
      // Касса выбрана по умолчанию, под кнопкой — новый остаток.
      final preview = find.text(
        _l10n.financeBalanceWillBe('Касса', _money('141 900')),
      );
      await tester.scrollUntilVisible(preview, 200, scrollable: _page);
      expect(preview, findsOneWidget);
      await _tap(tester, find.text(_l10n.financeExpenseSaveNew));

      expect(find.byType(FinanceExpenseTab), findsOneWidget);
      expect(find.text(_l10n.financeExpenseSaved), findsOneWidget);
      expect(find.text('Дизель, 60 л'), findsOneWidget);

      final saved = (await repo.getExpenses(
        const ExpenseFilter(category: ExpenseCategory.fuel),
      )).first;
      expect(saved.accountId, 1);
      expect(saved.amount, Money.tenge(20000));
      expect(saved.expenseDate, DateTime.utc(2026, 9, 19));
    });

    testWidgets('the next expense starts from the last used account', (
      tester,
    ) async {
      await _pump(tester, '/finance?tab=expense', _repo());

      await _tap(tester, find.byType(FinanceAddButton));
      await _tap(tester, find.text(_l10n.financeCategoryOther));
      await tester.enterText(_field(0), 'Вода');
      await tester.enterText(_field(1), '3000');
      await _tap(tester, find.text('Kaspi'));
      await _tap(tester, find.text(_l10n.financeExpenseSaveNew));

      // Сообщение о сохранении не закрывает кнопку «+ Расход».
      expect(find.text(_l10n.financeExpenseSaved), findsOneWidget);
      await _tap(tester, find.byType(FinanceAddButton));
      await tester.enterText(_field(1), '1000');
      await tester.pump();
      final preview = find.text(
        _l10n.financeBalanceWillBe('Kaspi', _money('918 000')),
      );
      await tester.scrollUntilVisible(preview, 200, scrollable: _page);
      expect(preview, findsOneWidget);
    });

    testWidgets('editing recalculates the balance from the old amount', (
      tester,
    ) async {
      await _pump(tester, '/finance?tab=expense', _repo());

      await _tap(tester, find.text('Комбикорм, 2 мешка'));
      expect(find.text(_l10n.financeExpenseTitle), findsOneWidget);
      expect(find.text('45${_nbsp}000'), findsOneWidget);

      await tester.enterText(_field(1), '50000');
      await tester.pump();
      final preview = find.text(
        _l10n.financeBalanceWillBe('Касса', _money('156 900')),
      );
      await tester.scrollUntilVisible(preview, 200, scrollable: _page);
      expect(preview, findsOneWidget);
      await _tap(tester, find.text(_l10n.financeSave));

      expect(find.text(_l10n.financeExpenseUpdated), findsOneWidget);
      expect(find.text('$_minus${_money('50 000')}'), findsOneWidget);
      expect(_spentLine('598 500'), findsOneWidget);
    });

    testWidgets('no balance note while nothing that moves it changed', (
      tester,
    ) async {
      await _pump(tester, '/finance?tab=expense', _repo());
      await _tap(tester, find.text('Комбикорм, 2 мешка'));
      await tester.scrollUntilVisible(
        find.text(_l10n.financeExpenseDelete),
        200,
        scrollable: _page,
      );
      expect(find.textContaining('станет'), findsNothing);
    });

    testWidgets('delete asks first', (tester) async {
      final repo = _repo();
      await _pump(tester, '/finance?tab=expense', repo);

      await _tap(tester, find.text('Электричество'));
      await _tap(tester, find.text(_l10n.financeExpenseDelete));
      expect(
        find.text(_l10n.financeExpenseDeleteConfirm('Электричество')),
        findsOneWidget,
      );
      await _tap(tester, find.text(_l10n.financeDeleteAction));

      expect(find.text(_l10n.financeExpenseDeleted), findsOneWidget);
      expect(find.text('Электричество'), findsNothing);
      expect(_spentLine('571 500'), findsOneWidget);
    });

    testWidgets('a saved expense is not hidden by the active filter', (
      tester,
    ) async {
      await _pump(tester, '/finance?tab=expense', _repo());
      await _tap(tester, _chip(_l10n.financeCategoryRent));

      await _tap(tester, find.byType(FinanceAddButton));
      await _tap(tester, find.text(_l10n.financeCategoryOther));
      await tester.enterText(_field(0), 'Вода');
      await tester.enterText(_field(1), '3000');
      await _tap(tester, find.text(_l10n.financeExpenseSaveNew));

      expect(find.text('Вода'), findsOneWidget);
    });

    testWidgets('opens by a direct link without the list', (tester) async {
      await _pump(tester, '/finance/expenses/21', _repo());
      expect(find.text(_l10n.financeExpenseTitle), findsOneWidget);
      expect(find.text('Комбикорм КК-60, 8 мешков'), findsOneWidget);
    });

    testWidgets('an unknown id shows a message', (tester) async {
      await _pump(tester, '/finance/expenses/999', _repo());
      expect(find.text(_l10n.financeExpenseNotFound), findsOneWidget);
    });

    testWidgets('without accounts it leads to creating one', (tester) async {
      await _pump(tester, '/finance/expenses/new', _repo(demo: false));
      expect(find.text(_l10n.financeNoActiveAccounts), findsOneWidget);
      final save = find.ancestor(
        of: find.text(_l10n.financeExpenseSaveNew),
        matching: find.byType(FilledButton),
      );
      await tester.scrollUntilVisible(save, 200, scrollable: _page);
      expect(tester.widget<FilledButton>(save).onPressed, isNull);
    });
  });
}
