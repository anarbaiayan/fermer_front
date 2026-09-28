import '../../domain/entities/finance_date.dart';
import '../../domain/entities/finance_entities.dart';
import '../../domain/entities/finance_enums.dart';
import '../../domain/entities/finance_inputs.dart';
import '../../domain/entities/money.dart';

// JSON-контракт `/api/finance/**`.
//
// Счета, покупатели, продажи и расходы сверены с веткой бэкенда `finance`
// (коммит 56cfd72 от 27.09.2026). Сводка и долги пока только в ТЗ, раздел 4:
// эндпоинтов ещё нет, форма ответа может поменяться.

int _id(Object? value) => (value as num).toInt();

int? _idOrNull(Object? value) => (value as num?)?.toInt();

String? _textOrNull(Object? value) {
  final text = value?.toString().trim();
  return text == null || text.isEmpty ? null : text;
}

List<Map<String, dynamic>> _objects(Object? value) =>
    (value as List? ?? const []).cast<Map<String, dynamic>>();

String? _blankToNull(String? value) {
  final text = value?.trim();
  return text == null || text.isEmpty ? null : text;
}

String? _dateOrNull(DateTime? day) => day == null ? null : formatApiDate(day);

// ---- ответы ----

/// `AccountResponse`.
FinanceAccount accountFromJson(Map<String, dynamic> json) => FinanceAccount(
  id: _id(json['id']),
  name: (json['name'] ?? '').toString(),
  type: AccountType.fromApi(json['type']),
  initialBalance: Money.fromJsonOrNull(json['initialBalance']) ?? Money.zero,
  balance:
      Money.fromJsonOrNull(json['balance']) ??
      Money.fromJsonOrNull(json['initialBalance']) ??
      Money.zero,
  active: json['active'] as bool? ?? true,
);

/// `CounterpartyResponse`.
Counterparty counterpartyFromJson(Map<String, dynamic> json) => Counterparty(
  id: _id(json['id']),
  name: (json['name'] ?? '').toString(),
  phone: _textOrNull(json['phone']),
  active: json['active'] as bool? ?? true,
);

/// `SaleResponse`.
Sale saleFromJson(Map<String, dynamic> json) => Sale(
  id: _id(json['id']),
  counterpartyId: _idOrNull(json['counterpartyId']),
  counterpartyName: _textOrNull(json['counterpartyName']),
  saleDate: parseApiDate(json['saleDate'].toString()),
  productName: (json['productName'] ?? '').toString(),
  quantity: Quantity.fromJson(json['quantity']),
  unit: SaleUnit.fromApi(json['unit']),
  pricePerUnit: Money.fromJson(json['pricePerUnit']),
  amount: Money.fromJson(json['amount']),
  accountId: _idOrNull(json['accountId']),
  accountName: _textOrNull(json['accountName']),
  paid: json['paid'] as bool? ?? false,
  paidAt: parseApiDateOrNull(json['paidAt']),
  dueDate: parseApiDateOrNull(json['dueDate']),
  comment: _textOrNull(json['comment']),
);

/// `ExpenseResponse`.
Expense expenseFromJson(Map<String, dynamic> json) => Expense(
  id: _id(json['id']),
  category: ExpenseCategory.fromApi(json['category']),
  name: (json['name'] ?? '').toString(),
  amount: Money.fromJson(json['amount']),
  expenseDate: parseApiDate(json['expenseDate'].toString()),
  accountId: _id(json['accountId']),
  accountName: _textOrNull(json['accountName']),
  comment: _textOrNull(json['comment']),
  cattleId: _idOrNull(json['cattleId']),
);

/// Сводка по ТЗ.
FinanceSummary summaryFromJson(Map<String, dynamic> json) => FinanceSummary(
  periodFrom: parseApiDate(json['periodFrom'].toString()),
  periodTo: parseApiDate(json['periodTo'].toString()),
  totalIncome: Money.fromJsonOrNull(json['totalIncome']) ?? Money.zero,
  totalExpense: Money.fromJsonOrNull(json['totalExpense']) ?? Money.zero,
  profit: Money.fromJsonOrNull(json['profit']) ?? Money.zero,
  accounts: [
    for (final account in _objects(json['accounts']))
      AccountBalance(
        id: _id(account['id']),
        name: (account['name'] ?? '').toString(),
        balance: Money.fromJsonOrNull(account['balance']) ?? Money.zero,
      ),
  ],
  expensesByCategory: [
    for (final item in _objects(json['expensesByCategory']))
      CategoryAmount(
        category: ExpenseCategory.fromApi(item['category']),
        amount: Money.fromJsonOrNull(item['amount']) ?? Money.zero,
      ),
  ],
  totalDebt: Money.fromJsonOrNull(json['totalDebt']) ?? Money.zero,
  overdueDebt: Money.fromJsonOrNull(json['overdueDebt']) ?? Money.zero,
);

/// Элемент `GET /api/finance/debts` по ТЗ.
CounterpartyDebt debtFromJson(Map<String, dynamic> json) => CounterpartyDebt(
  counterpartyId: _idOrNull(json['counterpartyId']),
  counterpartyName: _textOrNull(json['counterpartyName']),
  phone: _textOrNull(json['phone']),
  totalDebt: Money.fromJsonOrNull(json['totalDebt']) ?? Money.zero,
  overdueDays: (json['overdueDays'] as num?)?.toInt() ?? 0,
  sales: [
    for (final sale in _objects(json['sales']))
      DebtSale(
        id: _id(sale['id']),
        saleDate: parseApiDate(sale['saleDate'].toString()),
        amount: Money.fromJsonOrNull(sale['amount']) ?? Money.zero,
        dueDate: parseApiDateOrNull(sale['dueDate']),
      ),
  ],
);

// ---- запросы ----

/// `AccountCreateRequest` / `AccountUpdateRequest`.
Map<String, dynamic> accountInputToJson(AccountInput input) => {
  'name': input.name.trim(),
  'type': input.type.apiValue,
  'initialBalance': input.initialBalance.toJson(),
};

/// `CounterpartyCreateRequest` / `CounterpartyUpdateRequest`.
Map<String, dynamic> counterpartyInputToJson(CounterpartyInput input) => {
  'name': input.name.trim(),
  'phone': _blankToNull(input.phone),
};

/// `SaleCreateRequest` / `SaleUpdateRequest`. Сумму не отправляем: бэкенд
/// её игнорирует и считает сам.
///
/// Счёт и дата оплаты уходят только у оплаченной продажи, срок — только у
/// продажи в долг: бэкенд хранит поля как пришли, и лишний счёт у долга
/// путал бы список.
Map<String, dynamic> saleInputToJson(SaleInput input) => {
  'counterpartyId': input.counterpartyId,
  'saleDate': formatApiDate(input.saleDate),
  'productName': input.productName.trim(),
  'quantity': input.quantity.toJson(),
  'unit': input.unit.apiValue,
  'pricePerUnit': input.pricePerUnit.toJson(),
  'paid': input.paid,
  'accountId': input.paid ? input.accountId : null,
  'paidAt': input.paid ? _dateOrNull(input.paidAt) : null,
  'dueDate': input.paid ? null : _dateOrNull(input.dueDate),
  'comment': _blankToNull(input.comment),
};

/// `SalePaymentRequest`.
Map<String, dynamic> salePaymentToJson(SalePayment payment) => {
  'accountId': payment.accountId,
  'paidAt': _dateOrNull(payment.paidAt),
};

/// `ExpenseCreateRequest` / `ExpenseUpdateRequest`.
Map<String, dynamic> expenseInputToJson(ExpenseInput input) => {
  'category': input.category.apiValue,
  'name': input.name.trim(),
  'amount': input.amount.toJson(),
  'expenseDate': formatApiDate(input.expenseDate),
  'accountId': input.accountId,
  'comment': _blankToNull(input.comment),
  'cattleId': input.cattleId,
};

/// Query для `GET /api/finance/sales`. Параметр оплаты на бэкенде — `paid`,
/// а не `isPaid`, как в ТЗ.
Map<String, dynamic> saleFilterToQuery(SaleFilter filter) => {
  if (filter.from != null) 'from': formatApiDate(filter.from!),
  if (filter.to != null) 'to': formatApiDate(filter.to!),
  if (filter.counterpartyId != null) 'counterpartyId': filter.counterpartyId,
  if (filter.paid != null) 'paid': filter.paid,
};

/// Query для `GET /api/finance/expenses`.
Map<String, dynamic> expenseFilterToQuery(ExpenseFilter filter) => {
  if (filter.from != null) 'from': formatApiDate(filter.from!),
  if (filter.to != null) 'to': formatApiDate(filter.to!),
  if (filter.category != null) 'category': filter.category!.apiValue,
  if (filter.accountId != null) 'accountId': filter.accountId,
};

Map<String, dynamic> periodToQuery(FinancePeriod period) => {
  'from': formatApiDate(period.from),
  'to': formatApiDate(period.to),
};
