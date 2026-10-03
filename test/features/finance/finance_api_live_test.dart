// Живая сверка `FinanceApi` с бэкендом. По умолчанию пропускается.
//
// Только для локального или dev-сервера: тест регистрирует нового
// пользователя и заводит ему данные. Запуск:
//   flutter test test/features/finance/finance_api_live_test.dart \
//     --dart-define=FINANCE_LIVE_API=http://localhost:8888/api
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/core/network/api_exceptions.dart';
import 'package:frontend/features/finance/data/datasources/finance_api.dart';
import 'package:frontend/features/finance/domain/entities/finance_date.dart';
import 'package:frontend/features/finance/domain/entities/finance_enums.dart';
import 'package:frontend/features/finance/domain/entities/finance_inputs.dart';
import 'package:frontend/features/finance/domain/entities/money.dart';
import 'package:frontend/features/lactation/data/datasources/lactation_api.dart';

const _baseUrl = String.fromEnvironment('FINANCE_LIVE_API');

void main() {
  group(
    'finance API live',
    skip: _baseUrl.isEmpty ? 'нужен --dart-define=FINANCE_LIVE_API=…' : null,
    _liveTests,
  );
}

void _liveTests() {
  late Dio dio;
  late FinanceApi api;
  // Бэкенд считает «сегодня» в Asia/Almaty (UTC+5).
  final now = DateTime.now().toUtc().add(const Duration(hours: 5));
  final today = DateTime.utc(now.year, now.month, now.day);

  setUpAll(() async {
    final phone = '+7700${Random().nextInt(9000000) + 1000000}';
    final auth = await Dio(BaseOptions(baseUrl: _baseUrl)).post(
      '/auth/register',
      data: {
        'phoneNumber': phone,
        'password': 'Finance-check-1',
        'firstName': 'Финансы',
        'farmName': 'Ферма Проверка',
      },
    );
    dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        headers: {'Authorization': 'Bearer ${auth.data['accessToken']}'},
      ),
    );
    api = FinanceApi(dio);
  });

  test('full flow against the backend', () async {
    expect(await api.getAccounts(), isEmpty);

    final cash = await api.createAccount(
      AccountInput(
        name: 'Касса',
        type: AccountType.cash,
        initialBalance: Money.tenge(245000),
      ),
    );
    final kaspi = await api.createAccount(
      AccountInput(
        name: 'Kaspi',
        type: AccountType.card,
        initialBalance: Money.tryParse('1120000,50')!,
      ),
    );
    expect(cash.balance, Money.tenge(245000));
    expect(kaspi.balance, Money.tryParse('1120000,50'));

    final shop = await api.createCounterparty(
      const CounterpartyInput(name: 'Магазин Береке', phone: '+77011234567'),
    );
    expect(shop.active, isTrue);

    final feed = await api.createExpense(
      ExpenseInput(
        category: ExpenseCategory.feed,
        name: 'Комбикорм 2 мешка',
        amount: Money.tenge(45000),
        expenseDate: today,
        accountId: cash.id,
        comment: 'КК-60',
      ),
    );
    expect(feed.accountName, 'Касса');
    expect(feed.comment, 'КК-60');

    // Оплачено: 120 л × 250 ₸.
    final paid = await api.createSale(
      SaleInput(
        saleDate: today,
        productName: 'Молоко',
        quantity: Quantity.whole(120),
        unit: SaleUnit.liter,
        pricePerUnit: Money.tenge(250),
        paid: true,
        accountId: cash.id,
        paidAt: today,
      ),
    );
    expect(paid.amount, Money.tenge(30000));
    expect(paid.paid, isTrue);

    // В долг без срока: бэкенд ставит продажа + 14 дней.
    // 10,5 кг × 1500,25 ₸ = 15 752,625 → 15 752,63.
    final debt = await api.createSale(
      SaleInput(
        counterpartyId: shop.id,
        saleDate: today,
        productName: 'Творог',
        quantity: Quantity.tryParse('10,5')!,
        unit: SaleUnit.kilogram,
        pricePerUnit: Money.tryParse('1500,25')!,
        paid: false,
      ),
    );
    expect(debt.amount, Money.tryParse('15752,63'));
    expect(debt.accountId, isNull);
    expect(debt.dueDate, SaleInput.defaultDueDate(today));

    // Просрочено на 6 дней.
    final overdue = await api.createSale(
      SaleInput(
        counterpartyId: shop.id,
        saleDate: addDays(today, -20),
        productName: 'Молоко',
        quantity: Quantity.whole(580),
        unit: SaleUnit.liter,
        pricePerUnit: Money.tenge(250),
        paid: false,
        dueDate: addDays(today, -6),
      ),
    );

    final unpaid = await api.getSales(const SaleFilter(paid: false));
    expect(unpaid.map((s) => s.id), unorderedEquals([debt.id, overdue.id]));
    expect(
      unpaid.firstWhere((s) => s.id == overdue.id).isOverdueOn(today),
      isTrue,
    );
    expect((await api.getSales(SaleFilter(counterpartyId: shop.id))).length, 2);
    expect(await api.getProductNames(), containsAll(['Молоко', 'Творог']));

    // Долг не меняет остаток: 245 000 + 30 000 − 45 000.
    var accounts = await api.getAccounts();
    expect(
      accounts.firstWhere((a) => a.id == cash.id).balance,
      Money.tenge(230000),
    );

    final debts = await api.getDebts();
    expect(debts.single.counterpartyId, shop.id);
    expect(debts.single.overdueDays, 6);
    expect(debts.single.totalDebt, Money.tryParse('160752,63'));
    expect(debts.single.sales.first.id, overdue.id);

    // Списки за период: раньше бэкенд падал 500, когда даты переданы.
    final period = FinancePeriod.month(today);
    expect(
      (await api.getSales(SaleFilter.period(period))).map((s) => s.id),
      containsAll([paid.id, debt.id]),
    );
    expect(
      (await api.getExpenses(ExpenseFilter.period(period))).single.id,
      feed.id,
    );

    var summary = await api.getSummary(period);
    expect(summary.periodFrom, period.from);
    expect(summary.totalExpense, Money.tenge(45000));
    expect(summary.overdueDebt, Money.tenge(145000));
    expect(
      Money.sum(summary.expensesByCategory.map((c) => c.amount)),
      summary.totalExpense,
    );
    expect(summary.profit, summary.totalIncome - summary.totalExpense);

    // Оплата долга поднимает остаток Kaspi.
    final paidDebt = await api.paySale(
      overdue.id,
      SalePayment(accountId: kaspi.id, paidAt: today),
    );
    expect(paidDebt.paid, isTrue);
    expect(paidDebt.accountName, 'Kaspi');
    accounts = await api.getAccounts();
    expect(
      accounts.firstWhere((a) => a.id == kaspi.id).balance,
      Money.tryParse('1265000,50'),
    );
    summary = await api.getSummary(period);
    expect(summary.overdueDebt, Money.zero);
    expect((await api.getDebts()).single.overdueDays, 0);

    // Правка и удаление.
    final edited = await api.updateExpense(
      feed.id,
      ExpenseInput(
        category: ExpenseCategory.veterinary,
        name: 'Вакцина',
        amount: Money.tenge(12000),
        expenseDate: today,
        accountId: kaspi.id,
      ),
    );
    expect(edited.category, ExpenseCategory.veterinary);
    expect(
      (await api.getExpenses(
        const ExpenseFilter(category: ExpenseCategory.veterinary),
      )).single.id,
      feed.id,
    );
    await api.deleteExpense(feed.id);
    expect(await api.getExpenses(const ExpenseFilter()), isEmpty);

    final renamed = await api.updateSale(
      debt.id,
      SaleInput(
        counterpartyId: shop.id,
        saleDate: today,
        productName: 'Сметана',
        quantity: Quantity.whole(2),
        unit: SaleUnit.kilogram,
        pricePerUnit: Money.tenge(3000),
        paid: false,
        dueDate: addDays(today, 7),
      ),
    );
    expect(renamed.amount, Money.tenge(6000));
    expect(renamed.dueDate, addDays(today, 7));

    await api.updateCounterparty(
      shop.id,
      const CounterpartyInput(name: 'Береке', phone: ''),
    );
    expect((await api.getCounterparties()).single.phone, isNull);

    // Скрытый счёт остаётся в списке и не принимает новые расходы.
    await api.deactivateAccount(cash.id);
    accounts = await api.getAccounts();
    expect(accounts.firstWhere((a) => a.id == cash.id).active, isFalse);
    await expectLater(
      api.createExpense(
        ExpenseInput(
          category: ExpenseCategory.other,
          name: 'Прочее',
          amount: Money.tenge(100),
          expenseDate: today,
          accountId: cash.id,
        ),
      ),
      throwsA(
        isA<ApiException>()
            .having((e) => e.statusCode, 'status', 400)
            .having((e) => e.message, 'message', contains('деактивирован')),
      ),
    );

    await api.deleteSale(paid.id);
    await expectLater(
      api.paySale(paid.id, SalePayment(accountId: kaspi.id)),
      throwsA(
        isA<ApiException>()
            .having((e) => e.statusCode, 'status', 404)
            .having((e) => e.message, 'message', 'Продажа не найдена'),
      ),
    );
  });

  test('pdf report for every type', () async {
    for (final type in FinanceReportType.values) {
      final file = await api.getReportPdf(
        FinanceReportRequest(
          period: FinancePeriod(addDays(today, -40), today),
          type: type,
        ),
      );
      expect(String.fromCharCodes(file.bytes.take(4)), '%PDF');
      expect(
        file.fileName,
        'finance-report-${type.apiValue.toLowerCase()}.pdf',
      );
    }
  });

  test('milk for the home block', () async {
    final milk = await LactationApi(
      dio,
    ).getDailySummary(date: formatApiDate(today));
    expect(milk.totalLiters, 0);
  });
}
