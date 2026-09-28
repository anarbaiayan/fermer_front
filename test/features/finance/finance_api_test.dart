import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/core/network/api_exceptions.dart';
import 'package:frontend/features/finance/data/datasources/finance_api.dart';
import 'package:frontend/features/finance/domain/entities/finance_date.dart';
import 'package:frontend/features/finance/domain/entities/finance_enums.dart';
import 'package:frontend/features/finance/domain/entities/finance_inputs.dart';
import 'package:frontend/features/finance/domain/entities/money.dart';

class _Adapter implements HttpClientAdapter {
  _Adapter(this.handler);

  final FutureOr<Object?> Function(RequestOptions) handler;
  final requests = <RequestOptions>[];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    final data = await handler(options);
    if (data is ResponseBody) return data;
    return ResponseBody.fromString(
      jsonEncode(data),
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

// Ответы в форме DTO бэкенда (ветка finance, 27.09.2026).
const _saleJson = {
  'id': 88,
  'counterpartyId': 3,
  'counterpartyName': 'Магазин Береке',
  'saleDate': '2026-09-01',
  'productName': 'Молоко',
  'quantity': 580.000,
  'unit': 'L',
  'pricePerUnit': 250.00,
  'amount': 145000.00,
  'accountId': null,
  'accountName': null,
  'paid': false,
  'paidAt': null,
  'dueDate': '2026-09-13',
  'comment': null,
  'createdAt': '2026-09-01T10:15:30',
};

const _expenseJson = {
  'id': 7,
  'category': 'FEED',
  'name': 'Комбикорм КК-60, 2 мешка',
  'amount': 45000.5,
  'expenseDate': '2026-09-19',
  'accountId': 1,
  'accountName': 'Касса',
  'comment': 'Агро-Трейд',
  'cattleId': 12,
  'createdAt': '2026-09-19T08:00:00',
};

const _accountJson = {
  'id': 1,
  'name': 'Касса',
  'type': 'CASH',
  'initialBalance': 400000.00,
  'balance': 161900.00,
  'active': true,
  'createdAt': '2026-09-01T09:00:00',
};

(FinanceApi, _Adapter) _api(
  FutureOr<Object?> Function(RequestOptions) handler,
) {
  final adapter = _Adapter(handler);
  final dio = Dio(BaseOptions(baseUrl: 'https://test/api'))
    ..httpClientAdapter = adapter;
  return (FinanceApi(dio), adapter);
}

Map<String, dynamic> _body(RequestOptions options) =>
    options.data as Map<String, dynamic>;

void main() {
  group('responses', () {
    test('sale', () async {
      final (api, adapter) = _api((_) => [_saleJson]);
      final sale = (await api.getSales(const SaleFilter())).single;

      expect(adapter.requests.single.path, '/finance/sales');
      expect(sale.id, 88);
      expect(sale.counterpartyName, 'Магазин Береке');
      expect(sale.saleDate, DateTime.utc(2026, 9, 1));
      expect(sale.quantity, const Quantity.whole(580));
      expect(sale.unit, SaleUnit.liter);
      expect(sale.pricePerUnit, Money.tenge(250));
      expect(sale.amount, Money.tenge(145000));
      expect(sale.paid, isFalse);
      expect(sale.accountId, isNull);
      expect(sale.dueDate, DateTime.utc(2026, 9, 13));
      expect(sale.overdueDaysOn(DateTime.utc(2026, 9, 19)), 6);
    });

    test('expense keeps fractions and the hidden cattle id', () async {
      final (api, _) = _api((_) => [_expenseJson]);
      final expense = (await api.getExpenses(const ExpenseFilter())).single;
      expect(expense.category, ExpenseCategory.feed);
      expect(expense.amount, const Money.tiyn(4500050));
      expect(expense.accountName, 'Касса');
      expect(expense.comment, 'Агро-Трейд');
      expect(expense.cattleId, 12);
    });

    test('account with a computed balance', () async {
      final (api, _) = _api((_) => [_accountJson]);
      final account = (await api.getAccounts()).single;
      expect(account.type, AccountType.cash);
      expect(account.initialBalance, Money.tenge(400000));
      expect(account.balance, Money.tenge(161900));
      expect(account.active, isTrue);
    });

    test('unknown enum values fall back safely', () async {
      final (api, _) = _api(
        (_) => [
          {..._expenseJson, 'category': 'TAXES'},
        ],
      );
      final expense = (await api.getExpenses(const ExpenseFilter())).single;
      expect(expense.category, ExpenseCategory.other);
    });

    test('summary and debts in the shape from the spec', () async {
      final (api, adapter) = _api((options) {
        if (options.path == '/finance/summary') {
          return {
            'periodFrom': '2026-09-01',
            'periodTo': '2026-09-30',
            'totalIncome': 1450000,
            'totalExpense': 620000,
            'profit': 830000,
            'accounts': [
              {'id': 1, 'name': 'Касса', 'balance': 245000},
              {'id': 2, 'name': 'Kaspi', 'balance': 1120000},
            ],
            'expensesByCategory': [
              {'category': 'FEED', 'amount': 380000},
              {'category': 'SALARY', 'amount': 150000},
            ],
            'totalDebt': 287000,
            'overdueDebt': 145000,
          };
        }
        return [
          {
            'counterpartyId': 3,
            'counterpartyName': 'Магазин Береке',
            'phone': '+7701...',
            'totalDebt': 145000,
            'overdueDays': 6,
            'sales': [
              {
                'id': 88,
                'saleDate': '2026-09-01',
                'amount': 145000,
                'dueDate': '2026-09-13',
              },
            ],
          },
        ];
      });

      final summary = await api.getSummary(
        FinancePeriod.month(DateTime.utc(2026, 9, 19)),
      );
      expect(adapter.requests.last.queryParameters, {
        'from': '2026-09-01',
        'to': '2026-09-30',
      });
      expect(summary.profit, Money.tenge(830000));
      expect(summary.totalBalance, Money.tenge(1365000));
      expect(summary.expensesByCategory.first.category, ExpenseCategory.feed);
      expect(summary.overdueDebt, Money.tenge(145000));

      final debt = (await api.getDebts()).single;
      expect(adapter.requests.last.path, '/finance/debts');
      expect(debt.overdueDays, 6);
      expect(debt.sales.single.dueDate, DateTime.utc(2026, 9, 13));
    });
  });

  group('requests', () {
    test('sale filter uses the backend name `paid`', () async {
      final (api, adapter) = _api((_) => []);
      await api.getSales(
        SaleFilter(
          from: DateTime.utc(2026, 9, 1),
          to: DateTime.utc(2026, 9, 30),
          counterpartyId: 3,
          paid: false,
        ),
      );
      expect(adapter.requests.single.queryParameters, {
        'from': '2026-09-01',
        'to': '2026-09-30',
        'counterpartyId': 3,
        'paid': false,
      });
    });

    test('expense filter', () async {
      final (api, adapter) = _api((_) => []);
      await api.getExpenses(
        const ExpenseFilter(category: ExpenseCategory.feed, accountId: 2),
      );
      expect(adapter.requests.single.queryParameters, {
        'category': 'FEED',
        'accountId': 2,
      });
    });

    test('debt sale: no amount, no account, due date only', () async {
      final (api, adapter) = _api((_) => _saleJson);
      await api.createSale(
        SaleInput(
          counterpartyId: 3,
          saleDate: DateTime.utc(2026, 9, 1),
          productName: ' Молоко ',
          quantity: Quantity.tryParse('580,5')!,
          unit: SaleUnit.liter,
          pricePerUnit: Money.tenge(250),
          paid: false,
          accountId: 1,
          paidAt: DateTime.utc(2026, 9, 1),
          dueDate: DateTime.utc(2026, 9, 15),
          comment: '  ',
        ),
      );
      final request = adapter.requests.single;
      expect(request.method, 'POST');
      expect(request.path, '/finance/sales');
      expect(_body(request), {
        'counterpartyId': 3,
        'saleDate': '2026-09-01',
        'productName': 'Молоко',
        'quantity': 580.5,
        'unit': 'L',
        'pricePerUnit': 250,
        'paid': false,
        'accountId': null,
        'paidAt': null,
        'dueDate': '2026-09-15',
        'comment': null,
      });
    });

    test('paid sale: account and payment date, no due date', () async {
      final (api, adapter) = _api((_) => _saleJson);
      await api.updateSale(
        88,
        SaleInput(
          saleDate: DateTime.utc(2026, 9, 19),
          productName: 'Творог',
          quantity: const Quantity.whole(12),
          unit: SaleUnit.kilogram,
          pricePerUnit: Money.tryParse('2200,50')!,
          paid: true,
          accountId: 1,
          dueDate: DateTime.utc(2026, 10, 3),
        ),
      );
      final request = adapter.requests.single;
      expect(request.method, 'PUT');
      expect(request.path, '/finance/sales/88');
      final body = _body(request);
      expect(body['accountId'], 1);
      expect(body['pricePerUnit'], 2200.5);
      expect(body['dueDate'], isNull);
      expect(body.containsKey('amount'), isFalse);
    });

    test('payment goes to PUT /sales/{id}/pay', () async {
      final (api, adapter) = _api((_) => {..._saleJson, 'paid': true});
      await api.paySale(
        88,
        SalePayment(accountId: 2, paidAt: DateTime.utc(2026, 9, 19)),
      );
      final request = adapter.requests.single;
      expect(request.method, 'PUT');
      expect(request.path, '/finance/sales/88/pay');
      expect(_body(request), {'accountId': 2, 'paidAt': '2026-09-19'});
    });

    test('expense keeps the cattle id', () async {
      final (api, adapter) = _api((_) => _expenseJson);
      await api.createExpense(
        ExpenseInput(
          category: ExpenseCategory.feed,
          name: 'Комбикорм',
          amount: Money.tenge(45000),
          expenseDate: DateTime.utc(2026, 9, 19),
          accountId: 1,
          cattleId: 12,
        ),
      );
      expect(_body(adapter.requests.single), {
        'category': 'FEED',
        'name': 'Комбикорм',
        'amount': 45000,
        'expenseDate': '2026-09-19',
        'accountId': 1,
        'comment': null,
        'cattleId': 12,
      });
    });

    test('account and buyer bodies, delete is a deactivation call', () async {
      final (api, adapter) = _api((options) {
        if (options.method == 'DELETE') return null;
        if (options.path.contains('counterparties')) {
          return {'id': 5, 'name': 'Кафе', 'phone': null, 'active': true};
        }
        return _accountJson;
      });
      await api.createAccount(
        AccountInput(
          name: 'Касса',
          type: AccountType.cash,
          initialBalance: Money.tenge(245000),
        ),
      );
      await api.updateCounterparty(
        5,
        const CounterpartyInput(name: 'Кафе', phone: ''),
      );
      await api.deactivateAccount(1);

      expect(_body(adapter.requests[0]), {
        'name': 'Касса',
        'type': 'CASH',
        'initialBalance': 245000,
      });
      expect(adapter.requests[1].method, 'PUT');
      expect(_body(adapter.requests[1]), {'name': 'Кафе', 'phone': null});
      expect(adapter.requests[2].method, 'DELETE');
      expect(adapter.requests[2].path, '/finance/accounts/1');
    });
  });

  test('backend message is passed to the user', () async {
    final (api, _) = _api(
      (_) => ResponseBody.fromString(
        jsonEncode({
          'status': 400,
          'message': 'Нельзя провести оплату через деактивированный счёт',
        }),
        400,
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        },
      ),
    );
    await expectLater(
      api.paySale(1, const SalePayment(accountId: 4)),
      throwsA(
        isA<ApiException>()
            .having((e) => e.statusCode, 'status', 400)
            .having(
              (e) => e.message,
              'message',
              'Нельзя провести оплату через деактивированный счёт',
            ),
      ),
    );
  });
}
