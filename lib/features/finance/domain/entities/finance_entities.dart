import 'package:flutter/foundation.dart';

import 'finance_date.dart';
import 'finance_enums.dart';
import 'money.dart';

/// Срок оплаты продажи в долг по умолчанию (ТЗ, правило 2).
const kDefaultDebtDays = 14;

/// Счёт: касса, карта или банк. Остаток считает бэкенд:
/// начальный + оплаченные продажи − расходы.
@immutable
class FinanceAccount {
  const FinanceAccount({
    required this.id,
    required this.name,
    required this.type,
    required this.initialBalance,
    required this.balance,
    required this.active,
  });

  final int id;
  final String name;
  final AccountType type;
  final Money initialBalance;
  final Money balance;

  /// Скрытый счёт не предлагается в новых записях, но остаётся в истории.
  final bool active;
}

/// Покупатель. В API и ТЗ — «контрагент» (`counterparties`).
@immutable
class Counterparty {
  const Counterparty({
    required this.id,
    required this.name,
    this.phone,
    required this.active,
  });

  final int id;
  final String name;
  final String? phone;
  final bool active;
}

enum SaleStatus { paid, due, overdue }

/// Продажа (доход). Сумму считает бэкенд, клиент только показывает
/// предрасчёт.
@immutable
class Sale {
  const Sale({
    required this.id,
    this.counterpartyId,
    this.counterpartyName,
    required this.saleDate,
    required this.productName,
    required this.quantity,
    required this.unit,
    required this.pricePerUnit,
    required this.amount,
    this.accountId,
    this.accountName,
    required this.paid,
    this.paidAt,
    this.dueDate,
    this.comment,
  });

  final int id;
  final int? counterpartyId;
  final String? counterpartyName;
  final DateTime saleDate;
  final String productName;
  final Quantity quantity;
  final SaleUnit unit;
  final Money pricePerUnit;
  final Money amount;
  final int? accountId;
  final String? accountName;
  final bool paid;
  final DateTime? paidAt;
  final DateTime? dueDate;
  final String? comment;

  /// Просрочка считается на лету: не оплачено и срок прошёл (правило 3).
  /// В день срока продажа ещё не просрочена.
  bool isOverdueOn(DateTime today) =>
      !paid && dueDate != null && dateOnly(dueDate!).isBefore(dateOnly(today));

  int overdueDaysOn(DateTime today) =>
      isOverdueOn(today) ? daysBetween(dueDate!, today) : 0;

  SaleStatus statusOn(DateTime today) {
    if (paid) return SaleStatus.paid;
    return isOverdueOn(today) ? SaleStatus.overdue : SaleStatus.due;
  }
}

/// Расход. `cattleId` в интерфейсе не показываем (ТЗ 3.4), но передаём
/// обратно при правке, чтобы не стереть привязку.
@immutable
class Expense {
  const Expense({
    required this.id,
    required this.category,
    required this.name,
    required this.amount,
    required this.expenseDate,
    required this.accountId,
    this.accountName,
    this.comment,
    this.cattleId,
  });

  final int id;
  final ExpenseCategory category;
  final String name;
  final Money amount;
  final DateTime expenseDate;
  final int accountId;
  final String? accountName;
  final String? comment;
  final int? cattleId;
}

@immutable
class AccountBalance {
  const AccountBalance({
    required this.id,
    required this.name,
    required this.balance,
  });

  final int id;
  final String name;
  final Money balance;
}

@immutable
class CategoryAmount {
  const CategoryAmount({required this.category, required this.amount});

  final ExpenseCategory category;
  final Money amount;
}

/// `GET /api/finance/summary?from=&to=` (ТЗ, раздел 4).
@immutable
class FinanceSummary {
  const FinanceSummary({
    required this.periodFrom,
    required this.periodTo,
    required this.totalIncome,
    required this.totalExpense,
    required this.profit,
    required this.accounts,
    required this.expensesByCategory,
    required this.totalDebt,
    required this.overdueDebt,
  });

  final DateTime periodFrom;
  final DateTime periodTo;
  final Money totalIncome;
  final Money totalExpense;
  final Money profit;
  final List<AccountBalance> accounts;
  final List<CategoryAmount> expensesByCategory;
  final Money totalDebt;
  final Money overdueDebt;

  Money get totalBalance => Money.sum(accounts.map((a) => a.balance));
}

@immutable
class DebtSale {
  const DebtSale({
    required this.id,
    required this.saleDate,
    required this.amount,
    this.dueDate,
  });

  final int id;
  final DateTime saleDate;
  final Money amount;
  final DateTime? dueDate;

  bool isOverdueOn(DateTime today) =>
      dueDate != null && dateOnly(dueDate!).isBefore(dateOnly(today));
}

/// Готовый PDF от бэкенда. [fileName] — из `Content-Disposition`, если
/// бэкенд его прислал.
@immutable
class FinanceReportFile {
  const FinanceReportFile({required this.bytes, this.fileName});

  final Uint8List bytes;
  final String? fileName;
}

/// Долг одного покупателя: `GET /api/finance/debts` (ТЗ, раздел 4).
@immutable
class CounterpartyDebt {
  const CounterpartyDebt({
    this.counterpartyId,
    this.counterpartyName,
    this.phone,
    required this.totalDebt,
    required this.overdueDays,
    required this.sales,
  });

  final int? counterpartyId;
  final String? counterpartyName;
  final String? phone;
  final Money totalDebt;

  /// Самая долгая просрочка среди продаж покупателя, 0 — просрочки нет.
  final int overdueDays;
  final List<DebtSale> sales;

  Money overdueAmountOn(DateTime today) => Money.sum(
    sales.where((sale) => sale.isOverdueOn(today)).map((sale) => sale.amount),
  );
}
