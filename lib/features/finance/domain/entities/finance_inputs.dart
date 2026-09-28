import 'package:flutter/foundation.dart';

import 'finance_date.dart';
import 'finance_entities.dart';
import 'finance_enums.dart';
import 'money.dart';

// Данные форм, которые уходят в репозиторий. Сумму продажи здесь не
// передаём: её считает бэкенд из количества и цены.

@immutable
class AccountInput {
  const AccountInput({
    required this.name,
    required this.type,
    required this.initialBalance,
  });

  final String name;
  final AccountType type;

  /// Сколько было на счёте на момент создания. Не может быть отрицательным.
  final Money initialBalance;
}

@immutable
class CounterpartyInput {
  const CounterpartyInput({required this.name, this.phone});

  final String name;
  final String? phone;
}

@immutable
class SaleInput {
  const SaleInput({
    this.counterpartyId,
    required this.saleDate,
    required this.productName,
    required this.quantity,
    required this.unit,
    required this.pricePerUnit,
    required this.paid,
    this.accountId,
    this.paidAt,
    this.dueDate,
    this.comment,
  });

  final int? counterpartyId;
  final DateTime saleDate;
  final String productName;
  final Quantity quantity;
  final SaleUnit unit;
  final Money pricePerUnit;
  final bool paid;

  /// Обязателен для оплаченной продажи.
  final int? accountId;
  final DateTime? paidAt;

  /// Срок для продажи в долг. Бэкенд сам его не подставляет, поэтому форма
  /// всегда присылает значение, по умолчанию [defaultDueDate].
  final DateTime? dueDate;
  final String? comment;

  /// Предрасчёт суммы для формы; итог приходит с бэкенда.
  Money get estimatedAmount => quantity.times(pricePerUnit);

  static DateTime defaultDueDate(DateTime saleDate) =>
      addDays(saleDate, kDefaultDebtDays);
}

@immutable
class SalePayment {
  const SalePayment({required this.accountId, this.paidAt});

  final int accountId;
  final DateTime? paidAt;
}

@immutable
class ExpenseInput {
  const ExpenseInput({
    required this.category,
    required this.name,
    required this.amount,
    required this.expenseDate,
    required this.accountId,
    this.comment,
    this.cattleId,
  });

  final ExpenseCategory category;
  final String name;
  final Money amount;
  final DateTime expenseDate;
  final int accountId;
  final String? comment;
  final int? cattleId;
}

/// Фильтр `GET /api/finance/sales`. Равенство по значению — фильтр служит
/// ключом семейства провайдеров.
@immutable
class SaleFilter {
  const SaleFilter({this.from, this.to, this.counterpartyId, this.paid});

  factory SaleFilter.period(FinancePeriod period) =>
      SaleFilter(from: period.from, to: period.to);

  final DateTime? from;
  final DateTime? to;
  final int? counterpartyId;
  final bool? paid;

  @override
  bool operator ==(Object other) =>
      other is SaleFilter &&
      other.from == from &&
      other.to == to &&
      other.counterpartyId == counterpartyId &&
      other.paid == paid;

  @override
  int get hashCode => Object.hash(from, to, counterpartyId, paid);
}

/// Фильтр `GET /api/finance/expenses`.
@immutable
class ExpenseFilter {
  const ExpenseFilter({this.from, this.to, this.category, this.accountId});

  factory ExpenseFilter.period(FinancePeriod period) =>
      ExpenseFilter(from: period.from, to: period.to);

  final DateTime? from;
  final DateTime? to;
  final ExpenseCategory? category;
  final int? accountId;

  @override
  bool operator ==(Object other) =>
      other is ExpenseFilter &&
      other.from == from &&
      other.to == to &&
      other.category == category &&
      other.accountId == accountId;

  @override
  int get hashCode => Object.hash(from, to, category, accountId);
}
