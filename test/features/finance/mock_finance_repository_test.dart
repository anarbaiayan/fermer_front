import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/core/network/api_exceptions.dart';
import 'package:frontend/features/finance/data/mock/mock_finance_repository.dart';
import 'package:frontend/features/finance/domain/entities/finance_date.dart';
import 'package:frontend/features/finance/domain/entities/finance_entities.dart';
import 'package:frontend/features/finance/domain/entities/finance_enums.dart';
import 'package:frontend/features/finance/domain/entities/finance_inputs.dart';
import 'package:frontend/features/finance/domain/entities/money.dart';

// «Сегодня» как в прототипе и примерах ТЗ.
final _today = DateTime.utc(2026, 9, 19);

// Id демо-данных: счета 1–4, покупатели 5–8.
const _cash = 1;
const _kaspi = 2;
const _halyk = 3;
const _oldCard = 4;
const _bereke = 5;
const _saule = 7;
const _zhailau = 8;

Money tenge(int value) => Money.tenge(value);

SaleInput saleInput({
  int? counterpartyId = _bereke,
  bool paid = false,
  int? accountId,
  int quantity = 100,
  int price = 250,
  DateTime? saleDate,
  DateTime? dueDate,
  DateTime? paidAt,
}) => SaleInput(
  counterpartyId: counterpartyId,
  saleDate: saleDate ?? _today,
  productName: 'Молоко',
  quantity: Quantity.whole(quantity),
  unit: SaleUnit.liter,
  pricePerUnit: tenge(price),
  paid: paid,
  accountId: accountId,
  dueDate: dueDate,
  paidAt: paidAt,
);

ExpenseInput expenseInput({int accountId = _cash, int amount = 10000}) =>
    ExpenseInput(
      category: ExpenseCategory.fuel,
      name: 'Дизель',
      amount: tenge(amount),
      expenseDate: _today,
      accountId: accountId,
    );

void main() {
  late DateTime now;
  late MockFinanceRepository repo;

  setUp(() {
    now = DateTime(2026, 9, 19, 14, 30);
    repo = MockFinanceRepository(clock: () => now, latency: Duration.zero);
  });

  Future<Money> balanceOf(int accountId) async =>
      (await repo.getAccounts()).firstWhere((a) => a.id == accountId).balance;

  Matcher apiError(int status) => throwsA(
    isA<ApiException>().having((e) => e.statusCode, 'status', status),
  );

  group('balance', () {
    test('initial + paid sales − expenses on the demo data', () async {
      expect(await balanceOf(_cash), tenge(161900));
      expect(await balanceOf(_kaspi), tenge(922000));
      expect(await balanceOf(_halyk), tenge(350000));
      expect(await balanceOf(_oldCard), Money.zero);
    });

    test('initial balance counts from the start', () async {
      final empty = MockFinanceRepository(
        latency: Duration.zero,
        withDemoData: false,
      );
      final account = await empty.createAccount(
        AccountInput(
          name: ' Касса ',
          type: AccountType.cash,
          initialBalance: tenge(245000),
        ),
      );
      expect(account.name, 'Касса');
      expect(account.balance, tenge(245000));

      await empty.createExpense(expenseInput(accountId: account.id));
      expect((await empty.getAccounts()).single.balance, tenge(235000));
    });

    test('a debt sale leaves every balance unchanged', () async {
      final before = {
        for (final a in await repo.getAccounts()) a.id: a.balance,
      };
      // Даже если счёт передан, долг не зачисляется до оплаты.
      await repo.createSale(saleInput(accountId: _cash));
      final after = {for (final a in await repo.getAccounts()) a.id: a.balance};
      expect(after, before);
    });

    test('paying a debt adds its amount to the chosen account', () async {
      final debt = await repo.createSale(saleInput());
      final paid = await repo.paySale(
        debt.id,
        const SalePayment(accountId: _cash),
      );
      expect(paid.paid, isTrue);
      expect(paid.accountId, _cash);
      expect(paid.accountName, 'Касса');
      expect(paid.paidAt, _today);
      expect(await balanceOf(_cash), tenge(161900 + 25000));
    });

    test('a paid sale goes straight to the account', () async {
      await repo.createSale(saleInput(paid: true, accountId: _kaspi));
      expect(await balanceOf(_kaspi), tenge(922000 + 25000));
    });

    test('editing or deleting an expense moves the balance back', () async {
      final expense = await repo.createExpense(expenseInput(amount: 5000));
      expect(await balanceOf(_cash), tenge(156900));

      await repo.updateExpense(expense.id, expenseInput(accountId: _kaspi));
      expect(await balanceOf(_cash), tenge(161900));
      expect(await balanceOf(_kaspi), tenge(912000));

      await repo.deleteExpense(expense.id);
      expect(await balanceOf(_kaspi), tenge(922000));
    });
  });

  group('sales', () {
    test('amount is computed from quantity and price', () async {
      final sale = await repo.createSale(
        saleInput(quantity: 120, price: 250, paid: true, accountId: _cash),
      );
      expect(sale.amount, tenge(30000));
    });

    test('a debt without a due date gets sale date + 14 days', () async {
      final sale = await repo.createSale(
        saleInput(saleDate: DateTime.utc(2026, 9, 20)),
      );
      expect(sale.dueDate, DateTime.utc(2026, 10, 4));
      expect(SaleInput.defaultDueDate(DateTime.utc(2026, 9, 20)), sale.dueDate);
    });

    test('keeps a due date chosen in the form', () async {
      final sale = await repo.createSale(
        saleInput(dueDate: DateTime.utc(2026, 9, 25)),
      );
      expect(sale.dueDate, DateTime.utc(2026, 9, 25));
    });

    test('paid sale needs an active account', () async {
      await expectLater(repo.createSale(saleInput(paid: true)), apiError(400));
      await expectLater(
        repo.createSale(saleInput(paid: true, accountId: _oldCard)),
        apiError(400),
      );
      await expectLater(
        repo.createSale(saleInput(paid: true, accountId: 999)),
        apiError(404),
      );
    });

    test('quantity must be positive, price may be zero', () async {
      await expectLater(repo.createSale(saleInput(quantity: 0)), apiError(400));
      final free = await repo.createSale(saleInput(price: 0));
      expect(free.amount, Money.zero);
    });

    test('filters by period, buyer and payment, newest first', () async {
      final september = FinancePeriod.month(_today);
      final sales = await repo.getSales(SaleFilter.period(september));
      expect(sales, hasLength(9));
      expect(sales.first.saleDate, _today);
      expect(sales.last.saleDate, DateTime.utc(2026, 9, 1));

      final unpaid = await repo.getSales(const SaleFilter(paid: false));
      expect(unpaid, hasLength(4));

      final bereke = await repo.getSales(
        const SaleFilter(counterpartyId: _bereke),
      );
      expect(bereke.map((s) => s.counterpartyName).toSet(), {'Магазин Береке'});
    });

    test('product names are unique and sorted', () async {
      expect(await repo.getProductNames(), ['Молоко', 'Сметана', 'Творог']);
    });

    test('rejects a period that ends before it starts', () async {
      await expectLater(
        repo.getSales(SaleFilter(from: _today, to: addDays(_today, -1))),
        apiError(400),
      );
    });
  });

  group('expenses', () {
    test('amount must be positive', () async {
      await expectLater(
        repo.createExpense(expenseInput(amount: 0)),
        apiError(400),
      );
    });

    test('a hidden account takes no new expenses but keeps old ones', () async {
      final expense = await repo.createExpense(expenseInput());
      await repo.deactivateAccount(_cash);
      await expectLater(repo.createExpense(expenseInput()), apiError(400));
      await repo.updateExpense(expense.id, expenseInput(amount: 20000));
    });

    test('keeps the hidden cattle link on edit', () async {
      final expense = await repo.createExpense(
        ExpenseInput(
          category: ExpenseCategory.veterinary,
          name: 'Вакцина',
          amount: tenge(5000),
          expenseDate: _today,
          accountId: _cash,
          cattleId: 42,
        ),
      );
      expect(expense.cattleId, 42);
    });

    test('filters by category and account', () async {
      final feed = await repo.getExpenses(
        ExpenseFilter(
          from: DateTime.utc(2026, 9, 1),
          to: DateTime.utc(2026, 9, 30),
          category: ExpenseCategory.feed,
        ),
      );
      expect(feed, hasLength(3));
      expect(feed.map((e) => e.accountName).toSet(), {'Kaspi', 'Касса'});

      final cash = await repo.getExpenses(
        const ExpenseFilter(accountId: _cash),
      );
      expect(cash.every((e) => e.accountId == _cash), isTrue);
    });
  });

  group('accounts and buyers', () {
    test('initial balance cannot be negative, zero is fine', () async {
      await expectLater(
        repo.createAccount(
          AccountInput(
            name: 'Kaspi',
            type: AccountType.card,
            initialBalance: tenge(-1),
          ),
        ),
        apiError(400),
      );
      final zero = await repo.createAccount(
        const AccountInput(
          name: 'Jusan',
          type: AccountType.bank,
          initialBalance: Money.zero,
        ),
      );
      expect(zero.balance, Money.zero);
    });

    test('deleting only hides, hidden go last', () async {
      await repo.deactivateAccount(_halyk);
      final accounts = await repo.getAccounts();
      expect(accounts, hasLength(4));
      expect(accounts.where((a) => !a.active).map((a) => a.name), {
        'Halyk',
        'Старая карта',
      });
      expect(accounts.take(2).every((a) => a.active), isTrue);

      await repo.deactivateCounterparty(_saule);
      final buyers = await repo.getCounterparties();
      expect(buyers.last.active, isFalse);
    });

    test('a hidden buyer cannot get a new sale', () async {
      await repo.deactivateCounterparty(_saule);
      await expectLater(
        repo.createSale(saleInput(counterpartyId: _saule)),
        apiError(400),
      );
    });

    test('blank phone is stored as none', () async {
      final buyer = await repo.createCounterparty(
        const CounterpartyInput(name: 'Кафе', phone: '  '),
      );
      expect(buyer.phone, isNull);
    });
  });

  group('summary', () {
    test('month totals, profit and categories add up', () async {
      final summary = await repo.getSummary(FinancePeriod.month(_today));
      expect(summary.totalIncome, tenge(666400));
      expect(summary.totalExpense, tenge(593500));
      expect(summary.profit, summary.totalIncome - summary.totalExpense);
      expect(
        Money.sum(summary.expensesByCategory.map((c) => c.amount)),
        summary.totalExpense,
      );
      expect(summary.expensesByCategory.first.category, ExpenseCategory.feed);
      expect(summary.expensesByCategory.first.amount, tenge(390000));
    });

    test('balances cover active accounts only', () async {
      final summary = await repo.getSummary(FinancePeriod.month(_today));
      expect(summary.accounts.map((a) => a.id), [_cash, _kaspi, _halyk]);
      expect(summary.totalBalance, tenge(161900 + 922000 + 350000));
    });

    test('debts: total and overdue as of today', () async {
      final summary = await repo.getSummary(FinancePeriod.month(_today));
      expect(summary.totalDebt, tenge(378000));
      expect(summary.overdueDebt, tenge(27000 + 145000));
    });

    test('overdue flips at the day boundary', () async {
      // Долг «Береке» 10.09, срок 24.09.
      now = DateTime(2026, 9, 24, 23, 59);
      var summary = await repo.getSummary(FinancePeriod.month(_today));
      expect(summary.overdueDebt, tenge(172000));

      now = DateTime(2026, 9, 25, 0, 1);
      summary = await repo.getSummary(FinancePeriod.month(_today));
      expect(summary.overdueDebt, tenge(172000 + 140000));
    });
  });

  group('debts', () {
    test('grouped by buyer, most overdue first', () async {
      final debts = await repo.getDebts();
      expect(debts.map((d) => d.counterpartyId), [_zhailau, _bereke, _saule]);

      final bereke = debts[1];
      expect(bereke.counterpartyName, 'Магазин Береке');
      expect(bereke.phone, '+7 701 234 56 78');
      expect(bereke.totalDebt, tenge(285000));
      expect(bereke.overdueDays, 6);
      expect(bereke.overdueAmountOn(_today), tenge(145000));
      expect(bereke.sales.map((s) => s.saleDate), [
        DateTime.utc(2026, 9, 1),
        DateTime.utc(2026, 9, 10),
      ]);

      expect(debts.last.overdueDays, 0);
    });

    test('a paid debt disappears from the list', () async {
      final saule = (await repo.getDebts()).last;
      await repo.paySale(
        saule.sales.single.id,
        const SalePayment(accountId: _cash),
      );
      expect(
        (await repo.getDebts()).map((d) => d.counterpartyId),
        isNot(contains(_saule)),
      );
    });
  });

  test('demo data follows today', () async {
    now = DateTime(2027, 3, 5);
    final later = MockFinanceRepository(
      clock: () => now,
      latency: Duration.zero,
    );
    final march = await later.getSales(
      SaleFilter.period(FinancePeriod.month(DateTime.utc(2027, 3, 5))),
    );
    expect(march, isNotEmpty);
    expect(march.first.saleDate, DateTime.utc(2027, 3, 5));
  });

  test('status of a sale matches the overdue rule', () async {
    final sales = await repo.getSales(const SaleFilter(paid: false));
    final statuses = {for (final s in sales) s.id: s.statusOn(_today)};
    expect(statuses.values.where((s) => s == SaleStatus.overdue), hasLength(2));
  });
}
