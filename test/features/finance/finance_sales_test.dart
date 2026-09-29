import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/core/router/app_router.dart';
import 'package:frontend/features/finance/application/finance_providers.dart';
import 'package:frontend/features/finance/data/mock/mock_finance_repository.dart';
import 'package:frontend/features/finance/domain/entities/finance_entities.dart';
import 'package:frontend/features/finance/domain/entities/finance_enums.dart';
import 'package:frontend/features/finance/domain/entities/finance_inputs.dart';
import 'package:frontend/features/finance/domain/entities/money.dart';
import 'package:frontend/features/finance/presentation/pages/finance_sale_form_screen.dart';
import 'package:frontend/features/finance/presentation/tabs/finance_income_tab.dart';
import 'package:frontend/features/finance/presentation/widgets/finance_chips.dart';
import 'package:frontend/features/finance/presentation/widgets/finance_common.dart';
import 'package:frontend/features/notifications/application/notifications_providers.dart';
import 'package:frontend/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final _l10n = lookupAppLocalizations(const Locale('ru'));
final _nbsp = String.fromCharCode(0x00A0);

String _money(String digits) => '${digits.replaceAll(' ', _nbsp)}$_nbsp₸';

final _today = DateTime.utc(2026, 9, 19);

MockFinanceRepository _repo({bool demo = true}) => MockFinanceRepository(
  clock: () => DateTime(2026, 9, 19, 12),
  latency: Duration.zero,
  withDemoData: demo,
);

Future<void> _pump(
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
}

final _page = find
    .byWidgetPredicate(
      (widget) =>
          widget is Scrollable && widget.axisDirection == AxisDirection.down,
    )
    .first;

/// Прокручивает к [finder]: сначала к началу страницы, потом вниз.
Future<void> _reveal(WidgetTester tester, Finder finder) async {
  if (finder.evaluate().isNotEmpty) return;
  await tester.drag(_page, const Offset(0, 3000));
  await tester.pumpAndSettle();
  if (finder.evaluate().isEmpty) {
    await tester.scrollUntilVisible(finder, 200, scrollable: _page);
  }
}

Future<void> _tap(WidgetTester tester, Finder finder) async {
  await _reveal(tester, finder);
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

Future<void> _expectVisible(WidgetTester tester, Finder finder) async {
  await _reveal(tester, finder);
  expect(finder, findsOneWidget);
}

/// Поля формы продажи сверху вниз: количество, цена, комментарий.
Finder _field(int index) => find.byType(TextField).at(index);

String _fieldText(WidgetTester tester, int index) =>
    tester.widget<TextField>(_field(index)).controller!.text;

Finder _chip(String label) => find.widgetWithText(FinanceChip, label);

Future<bool> _selected(WidgetTester tester, String label) async {
  await _reveal(tester, _chip(label));
  return tester.widget<FinanceChip>(_chip(label)).selected;
}

Finder _soldLine(String digits) => find.byWidgetPredicate(
  (widget) =>
      widget is RichText &&
      widget.text.toPlainText() ==
          '${_l10n.financeSoldLabel} ${_money(digits)}',
);

Sale _sale({
  required int id,
  required String product,
  required int day,
  int? buyer,
  int price = 100,
  SaleUnit unit = SaleUnit.liter,
}) => Sale(
  id: id,
  counterpartyId: buyer,
  saleDate: DateTime.utc(2026, 9, day),
  productName: product,
  quantity: Quantity.whole(1),
  unit: unit,
  pricePerUnit: Money.tenge(price),
  amount: Money.tenge(price),
  paid: true,
);

void main() {
  group('rules', () {
    final sales = [
      _sale(id: 1, product: 'Молоко', day: 1, buyer: 5, price: 240),
      _sale(id: 2, product: 'молоко', day: 10, buyer: 6, price: 250),
      _sale(id: 3, product: 'Молоко', day: 12, price: 300),
      _sale(id: 4, product: 'Творог', day: 15, buyer: 5, price: 2200),
    ];

    test('the price hint prefers the same buyer, then the latest sale', () {
      expect(lastSaleOf(sales, 'Молоко', 5)?.id, 1);
      expect(lastSaleOf(sales, ' МОЛОКО ', 6)?.id, 2);
      // Без покупателя — последняя продажа тоже без покупателя.
      expect(lastSaleOf(sales, 'Молоко', null)?.id, 3);
      expect(lastSaleOf(sales, 'Молоко', 7)?.id, 3);
      expect(lastSaleOf(sales, 'Кефир', 5), isNull);
      expect(lastSaleOf(sales, '  ', 5), isNull);
    });

    test('buyers: recent first, the rest by name, hidden left out', () {
      const buyers = [
        Counterparty(id: 5, name: 'Береке', active: true),
        Counterparty(id: 6, name: 'Достык', active: true),
        Counterparty(id: 7, name: 'Арман', active: true),
        Counterparty(id: 8, name: 'Скрытый', active: false),
        Counterparty(id: 9, name: 'Бахыт', active: true),
      ];
      expect(recentCounterparties(buyers, sales).map((b) => b.id), [
        5,
        6,
        7,
        9,
      ]);
    });

    test('income filters; overdue is counted on the fly', () {
      final due = Sale(
        id: 1,
        saleDate: DateTime.utc(2026, 9, 1),
        productName: 'Молоко',
        quantity: Quantity.whole(1),
        unit: SaleUnit.liter,
        pricePerUnit: Money.tenge(1),
        amount: Money.tenge(1),
        paid: false,
        dueDate: DateTime.utc(2026, 9, 19),
      );
      expect(IncomeFilter.debt.matches(due, _today), isTrue);
      expect(IncomeFilter.paid.matches(due, _today), isFalse);
      // В день срока ещё не просрочено, на следующий — уже.
      expect(IncomeFilter.overdue.matches(due, _today), isFalse);
      expect(
        IncomeFilter.overdue.matches(due, DateTime.utc(2026, 9, 20)),
        isTrue,
      );
    });
  });

  group('income tab', () {
    testWidgets('month totals, statuses and rows by day', (tester) async {
      await _pump(tester, '/finance?tab=income', _repo());

      expect(_soldLine('666 400'), findsOneWidget);
      expect(
        find.text(_l10n.financeUnpaidAmount(_money('351 000'))),
        findsOneWidget,
      );
      expect(find.text('Сегодня, 19 сентября'), findsOneWidget);
      expect(find.text('Молоко · 120 л'), findsOneWidget);
      expect(find.text('Магазин «Достык» · ${_money('250')}/л'), findsWidgets);
      expect(find.text('Молоко · 60 л'), findsOneWidget);
      expect(
        find.text('${_l10n.financeNoBuyer} · ${_money('300')}/л'),
        findsOneWidget,
      );
      expect(find.text(_l10n.financeSaleStatusDue('24.09')), findsOneWidget);
      await _expectVisible(
        tester,
        find.text(_l10n.financeSaleStatusOverdue(6)),
      );
      expect(find.byType(FinanceSaleRow), findsNWidgets(9));
      // Оплату можно получить только у неоплаченных.
      expect(find.text(_l10n.financeGetPayment), findsNWidgets(3));
    });

    testWidgets('filters hide rows but keep the month totals', (tester) async {
      await _pump(tester, '/finance?tab=income', _repo());

      await _tap(tester, _chip(_l10n.financeIncomeFilterOverdue));
      expect(find.byType(FinanceSaleRow), findsOneWidget);
      expect(find.text('Молоко · 580 л'), findsOneWidget);
      expect(_soldLine('666 400'), findsOneWidget);

      await _tap(tester, _chip(_l10n.financeIncomeFilterDebt));
      expect(find.byType(FinanceSaleRow), findsNWidgets(3));
      await _tap(tester, _chip(_l10n.financeIncomeFilterPaid));
      expect(find.byType(FinanceSaleRow), findsNWidgets(6));
      expect(find.text(_l10n.financeGetPayment), findsNothing);
    });

    testWidgets('August has the older debt', (tester) async {
      await _pump(tester, '/finance?tab=income', _repo());
      await _tap(tester, find.byTooltip(_l10n.financePrevMonth));
      expect(_soldLine('339 000'), findsOneWidget);
      expect(find.text(_l10n.financeSaleStatusOverdue(16)), findsOneWidget);
    });

    testWidgets('payment from the row moves the money to the account', (
      tester,
    ) async {
      final repo = _repo();
      await _pump(tester, '/finance?tab=income', repo);
      await _tap(tester, _chip(_l10n.financeIncomeFilterOverdue));
      await _tap(tester, find.text(_l10n.financeGetPayment));

      expect(find.text(_money('145 000')), findsWidgets);
      expect(
        find.text('Магазин Береке · Молоко, 580 л · продажа 01.09.2026'),
        findsOneWidget,
      );
      // Счёт по умолчанию — касса, пока другим не пользовались.
      expect(
        find.text(_l10n.financeBalanceWillBe('Касса', _money('306 900'))),
        findsOneWidget,
      );
      await _tap(tester, _chip('Kaspi'));
      expect(
        find.text(_l10n.financeBalanceWillBe('Kaspi', _money('1 067 000'))),
        findsOneWidget,
      );
      await _tap(tester, find.text(_l10n.financePayConfirm));

      expect(
        find.text(_l10n.financePaymentReceived(_money('145 000'), 'Kaspi')),
        findsOneWidget,
      );
      // Просроченных больше нет.
      expect(find.text(_l10n.financeSalesEmptyTitle), findsOneWidget);
      final paid = (await repo.getSales(
        const SaleFilter(),
      )).firstWhere((sale) => sale.id == 12);
      expect(paid.paid, isTrue);
      expect(paid.accountId, 2);
      expect(paid.paidAt, _today);
      final kaspi = (await repo.getAccounts()).firstWhere((a) => a.id == 2);
      expect(kaspi.balance, Money.tenge(1067000));

      // Следующая продажа предлагает тот же счёт.
      await _tap(tester, find.byType(FinanceAddButton));
      expect(await _selected(tester, 'Kaspi'), isTrue);
    });
  });

  group('sale form', () {
    testWidgets('empty form points at what is missing', (tester) async {
      await _pump(tester, '/finance?tab=income', _repo());
      await _tap(tester, find.byType(FinanceAddButton));
      expect(find.byType(FinanceSaleFormScreen), findsOneWidget);
      // Без покупателя и оплачено — умолчания формы.
      expect(await _selected(tester, _l10n.financeNoBuyer), isTrue);
      expect(await _selected(tester, 'Касса'), isTrue);

      await _tap(tester, find.text(_l10n.financeSaleSaveNew));
      await _expectVisible(tester, find.text(_l10n.financeSaleProductError));
      await _expectVisible(tester, find.text(_l10n.financeSaleQuantityError));
      await _expectVisible(tester, find.text(_l10n.financeSalePriceError));
    });

    testWidgets('buyer and product fill in the unit and the last price', (
      tester,
    ) async {
      final repo = _repo();
      await _pump(tester, '/finance/sales/new', repo);

      await _tap(tester, _chip('Магазин Береке'));
      await _tap(tester, _chip(_l10n.financeProductMilk));
      expect(_fieldText(tester, 1), '250');
      expect(
        find.text(_l10n.financeSalePriceHintBuyer(_money('250'))),
        findsOneWidget,
      );
      await tester.enterText(_field(0), '100');
      await tester.pump();
      expect(find.text(_money('25 000')), findsOneWidget);
      await _expectVisible(
        tester,
        find.text(_l10n.financeBalanceWillBe('Касса', _money('186 900'))),
      );
      await _tap(tester, find.text(_l10n.financeSaleSaveNew));

      final saved = (await repo.getSales(const SaleFilter())).first;
      expect(saved.counterpartyId, 5);
      expect(saved.productName, 'Молоко');
      expect(saved.unit, SaleUnit.liter);
      expect(saved.amount, Money.tenge(25000));
      expect(saved.paid, isTrue);
      expect(saved.accountId, 1);
      expect(saved.paidAt, _today);
    });

    testWidgets('a typed price stays when the buyer changes', (tester) async {
      await _pump(tester, '/finance/sales/new', _repo());

      // Без покупателя — розничная цена прошлой продажи без покупателя.
      await _tap(tester, _chip(_l10n.financeProductMilk));
      expect(_fieldText(tester, 1), '300');
      expect(
        find.text(_l10n.financeSalePriceHintLast(_money('300'))),
        findsOneWidget,
      );
      await _tap(tester, _chip('Магазин «Достык»'));
      expect(_fieldText(tester, 1), '250');

      await tester.enterText(_field(1), '260');
      await tester.pump();
      await _tap(tester, _chip('Магазин Береке'));
      expect(_fieldText(tester, 1), '260');
      expect(find.textContaining('прошлый раз'), findsNothing);

      // Кг у творога — из прошлой продажи.
      await _tap(tester, _chip(_l10n.financeProductCottageCheese));
      expect(find.text(_l10n.financeSalePriceLabel('кг')), findsOneWidget);
      expect(_fieldText(tester, 1), '260');
    });

    testWidgets('a debt needs a buyer and gets a due date in 14 days', (
      tester,
    ) async {
      final repo = _repo();
      await _pump(tester, '/finance/sales/new', repo);

      await _tap(tester, _chip(_l10n.financeProductKefir));
      await tester.enterText(_field(0), '10');
      await tester.enterText(_field(1), '400');
      await _tap(tester, find.text(_l10n.financeSaleStatusDebt));
      await _expectVisible(tester, find.text('03.10.2026'));
      expect(find.text(_l10n.financeSaleDueHint(14)), findsOneWidget);
      await _expectVisible(tester, find.text(_l10n.financeSaleDebtNote));

      await _tap(tester, find.text(_l10n.financeSaleSaveNew));
      await _expectVisible(tester, find.text(_l10n.financeSaleDebtBuyerError));

      await _tap(tester, _chip('ИП Сауле, молочный отдел'));
      await _tap(tester, find.text(_l10n.financeSaleSaveNew));
      expect(find.text(_l10n.financeSaleSaved), findsOneWidget);

      final saved = (await repo.getSales(const SaleFilter())).first;
      expect(saved.paid, isFalse);
      expect(saved.accountId, isNull);
      expect(saved.dueDate, DateTime.utc(2026, 10, 3));
      expect(saved.counterpartyId, 7);
      // Остатки не изменились.
      final cash = (await repo.getAccounts()).firstWhere((a) => a.id == 1);
      expect(cash.balance, Money.tenge(161900));
    });

    testWidgets('a buyer created from the form is selected', (tester) async {
      await _pump(tester, '/finance/sales/new', _repo());

      await _tap(tester, _chip(_l10n.financeNewBuyer));
      await tester.enterText(find.byType(TextField).first, 'Кафе «Самал»');
      await _tap(tester, find.text(_l10n.financeCounterpartyAdd));

      expect(find.byType(FinanceSaleFormScreen), findsOneWidget);
      expect(await _selected(tester, 'Кафе «Самал»'), isTrue);
      expect(await _selected(tester, _l10n.financeNoBuyer), isFalse);
    });

    testWidgets('own products from past sales and "Other"', (tester) async {
      final repo = _repo();
      await repo.createSale(
        SaleInput(
          saleDate: DateTime.utc(2026, 9, 18),
          productName: 'Айран',
          quantity: Quantity.whole(5),
          unit: SaleUnit.liter,
          pricePerUnit: Money.tenge(500),
          paid: true,
          accountId: 1,
        ),
      );
      await _pump(tester, '/finance/sales/new', repo);

      await _tap(tester, _chip('Айран'));
      expect(_fieldText(tester, 1), '500');

      await _tap(tester, _chip(_l10n.financeProductOther));
      // Подсказанная цена относилась к айрану — поле очищено.
      expect(_fieldText(tester, 2), '');
      await tester.enterText(_field(0), 'айр');
      await tester.pump();
      expect(find.widgetWithText(FinanceChip, 'Айран'), findsNWidgets(2));

      await tester.enterText(_field(0), 'Қымыз');
      await tester.enterText(_field(1), '3');
      await tester.enterText(_field(2), '1500');
      await _tap(tester, find.text(_l10n.financeSaleSaveNew));
      final saved = (await repo.getSales(const SaleFilter())).first;
      expect(saved.productName, 'Қымыз');
      expect(saved.amount, Money.tenge(4500));
    });

    testWidgets('editing a paid sale returns the old amount first', (
      tester,
    ) async {
      final repo = _repo();
      await _pump(tester, '/finance?tab=income', repo);

      await _tap(tester, find.text('Молоко · 120 л'));
      expect(find.text(_l10n.financeSaleTitle), findsOneWidget);
      expect(await _selected(tester, 'Магазин «Достык»'), isTrue);
      expect(await _selected(tester, _l10n.financeProductMilk), isTrue);
      // Ничего не меняли — и об остатке писать нечего.
      expect(find.textContaining('станет'), findsNothing);

      await tester.enterText(_field(0), '100');
      await tester.pump();
      await _expectVisible(
        tester,
        find.text(_l10n.financeBalanceWillBe('Касса', _money('156 900'))),
      );
      await _tap(tester, find.text(_l10n.financeSaleStatusDebt));
      await _expectVisible(
        tester,
        find.text(_l10n.financeBalanceWillBe('Касса', _money('131 900'))),
      );
      await _tap(tester, find.text(_l10n.financeSave));

      expect(find.text(_l10n.financeSaleUpdated), findsOneWidget);
      final edited = (await repo.getSales(
        const SaleFilter(),
      )).firstWhere((sale) => sale.id == 20);
      expect(edited.paid, isFalse);
      expect(edited.amount, Money.tenge(25000));
      expect(edited.dueDate, DateTime.utc(2026, 10, 3));
    });

    testWidgets('delete asks first', (tester) async {
      final repo = _repo();
      await _pump(tester, '/finance?tab=income', repo);

      await _tap(tester, find.text('Молоко · 60 л'));
      await _tap(tester, find.text(_l10n.financeSaleDelete));
      expect(
        find.text(_l10n.financeSaleDeleteConfirm('Молоко, 60 л')),
        findsOneWidget,
      );
      await _tap(tester, find.text(_l10n.financeDeleteAction));

      expect(find.text(_l10n.financeSaleDeleted), findsOneWidget);
      expect(find.text('Молоко · 60 л'), findsNothing);
      expect(_soldLine('648 400'), findsOneWidget);
    });

    testWidgets('a saved sale is not hidden by the active filter', (
      tester,
    ) async {
      await _pump(tester, '/finance?tab=income', _repo());
      await _tap(tester, _chip(_l10n.financeIncomeFilterOverdue));

      await _tap(tester, find.byType(FinanceAddButton));
      await _tap(tester, _chip(_l10n.financeProductButter));
      await tester.enterText(_field(0), '2');
      await tester.enterText(_field(1), '3500');
      await _tap(tester, find.text(_l10n.financeSaleSaveNew));

      expect(find.text('Масло · 2 кг'), findsOneWidget);
      expect(await _selected(tester, _l10n.financeFilterAll), isTrue);
    });

    testWidgets('opens by a direct link without the list', (tester) async {
      await _pump(tester, '/finance/sales/12', _repo());
      expect(find.text(_l10n.financeSaleTitle), findsOneWidget);
      expect(await _selected(tester, 'Магазин Береке'), isTrue);
      expect(_fieldText(tester, 0), '580');
    });

    testWidgets('an unknown id shows a message', (tester) async {
      await _pump(tester, '/finance/sales/999', _repo());
      expect(find.text(_l10n.financeSaleNotFound), findsOneWidget);
    });

    testWidgets('a debt can be saved even without accounts', (tester) async {
      final repo = _repo(demo: false);
      final buyer = await repo.createCounterparty(
        const CounterpartyInput(name: 'Магазин Береке'),
      );
      await _pump(tester, '/finance/sales/new', repo);
      await _expectVisible(tester, find.text(_l10n.financeNoActiveAccounts));

      await _tap(tester, _chip(buyer.name));
      await _tap(tester, _chip(_l10n.financeProductMilk));
      await tester.enterText(_field(0), '10');
      await tester.enterText(_field(1), '250');
      await _tap(tester, find.text(_l10n.financeSaleStatusDebt));
      await _tap(tester, find.text(_l10n.financeSaleSaveNew));

      final saved = (await repo.getSales(const SaleFilter())).single;
      expect(saved.paid, isFalse);
      expect(saved.amount, Money.tenge(2500));
    });
  });
}
