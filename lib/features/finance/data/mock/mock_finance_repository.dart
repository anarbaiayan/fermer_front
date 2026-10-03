import 'dart:convert';
import 'dart:typed_data';

import 'package:frontend/core/network/api_exceptions.dart';

import '../../domain/entities/finance_date.dart';
import '../../domain/entities/finance_entities.dart';
import '../../domain/entities/finance_enums.dart';
import '../../domain/entities/finance_inputs.dart';
import '../../domain/entities/money.dart';
import '../../domain/finance_repository.dart';

/// Репозиторий в памяти, пока бэкенд не выкатил `/api/finance/**`.
///
/// Повторяет правила бэкенда (ветка `finance`) и ТЗ:
/// - остаток = начальный + оплаченные продажи − расходы;
/// - продажа в долг не меняет остаток, деньги приходят после оплаты;
/// - срок долга по умолчанию — дата продажи + 14 дней (на бэкенде пока нет,
///   форма присылает срок сама);
/// - счёт и покупатель не удаляются, а скрываются;
/// - начальный остаток и цена ≥ 0, количество и сумма расхода > 0.
///
/// Сообщения ошибок — как у бэкенда. Данные живут до перезапуска.
class MockFinanceRepository implements FinanceRepository {
  MockFinanceRepository({
    DateTime Function()? clock,
    this.latency = const Duration(milliseconds: 300),
    bool withDemoData = true,
  }) : _clock = clock ?? DateTime.now {
    if (withDemoData) _seedDemoData();
  }

  final DateTime Function() _clock;

  /// Задержка ответа, чтобы на экранах были видны состояния загрузки.
  final Duration latency;

  final _accounts = <_AccountRow>[];
  final _counterparties = <_CounterpartyRow>[];
  final _sales = <_SaleRow>[];
  final _expenses = <_ExpenseRow>[];
  var _nextId = 1;

  DateTime get _today => dateOnly(_clock());

  Future<void> _respond() =>
      latency == Duration.zero ? Future.value() : Future.delayed(latency);

  // ---- счета ----

  @override
  Future<List<FinanceAccount>> getAccounts() async {
    await _respond();
    return _sortedAccounts().map(_account).toList();
  }

  /// Активные первыми, дальше по имени — как `ORDER BY active DESC, name`.
  List<_AccountRow> _sortedAccounts() => [..._accounts]
    ..sort((a, b) {
      if (a.active != b.active) return a.active ? -1 : 1;
      return a.name.toLowerCase().compareTo(b.name.toLowerCase());
    });

  @override
  Future<FinanceAccount> createAccount(AccountInput input) async {
    await _respond();
    _validateAccount(input);
    final row = _AccountRow(
      id: _nextId++,
      name: input.name.trim(),
      type: input.type,
      initialBalance: input.initialBalance,
    );
    _accounts.add(row);
    return _account(row);
  }

  @override
  Future<FinanceAccount> updateAccount(int id, AccountInput input) async {
    await _respond();
    final row = _accountRow(id);
    _validateAccount(input);
    row
      ..name = input.name.trim()
      ..type = input.type
      ..initialBalance = input.initialBalance;
    return _account(row);
  }

  @override
  Future<void> deactivateAccount(int id) async {
    await _respond();
    _accountRow(id).active = false;
  }

  // ---- покупатели ----

  @override
  Future<List<Counterparty>> getCounterparties() async {
    await _respond();
    final rows = [..._counterparties]
      ..sort((a, b) {
        if (a.active != b.active) return a.active ? -1 : 1;
        return a.name.toLowerCase().compareTo(b.name.toLowerCase());
      });
    return rows.map(_counterparty).toList();
  }

  @override
  Future<Counterparty> createCounterparty(CounterpartyInput input) async {
    await _respond();
    _validateCounterparty(input);
    final row = _CounterpartyRow(
      id: _nextId++,
      name: input.name.trim(),
      phone: _blankToNull(input.phone),
    );
    _counterparties.add(row);
    return _counterparty(row);
  }

  @override
  Future<Counterparty> updateCounterparty(
    int id,
    CounterpartyInput input,
  ) async {
    await _respond();
    final row = _counterpartyRow(id);
    _validateCounterparty(input);
    row
      ..name = input.name.trim()
      ..phone = _blankToNull(input.phone);
    return _counterparty(row);
  }

  @override
  Future<void> deactivateCounterparty(int id) async {
    await _respond();
    _counterpartyRow(id).active = false;
  }

  // ---- продажи ----

  @override
  Future<List<Sale>> getSales(SaleFilter filter) async {
    await _respond();
    _validatePeriod(filter.from, filter.to);
    if (filter.counterpartyId != null) _counterpartyRow(filter.counterpartyId!);
    final rows =
        _sales.where((sale) {
          if (filter.from != null && sale.saleDate.isBefore(filter.from!)) {
            return false;
          }
          if (filter.to != null && sale.saleDate.isAfter(filter.to!)) {
            return false;
          }
          if (filter.counterpartyId != null &&
              sale.counterpartyId != filter.counterpartyId) {
            return false;
          }
          return filter.paid == null || sale.paid == filter.paid;
        }).toList()..sort((a, b) {
          final byDate = b.saleDate.compareTo(a.saleDate);
          return byDate != 0 ? byDate : b.id.compareTo(a.id);
        });
    return rows.map(_sale).toList();
  }

  @override
  Future<List<String>> getProductNames() async {
    await _respond();
    return _sales.map((sale) => sale.productName).toSet().toList()..sort();
  }

  @override
  Future<Sale> createSale(SaleInput input) async {
    await _respond();
    _validateSale(input);
    _checkCounterparty(input.counterpartyId, requireActive: true);
    _checkSaleAccount(input);
    final row = _SaleRow(id: _nextId++);
    _applySale(row, input);
    _sales.add(row);
    return _sale(row);
  }

  @override
  Future<Sale> updateSale(int id, SaleInput input) async {
    await _respond();
    final row = _saleRow(id);
    _validateSale(input);
    _checkCounterparty(input.counterpartyId, requireActive: false);
    _checkSaleAccount(input);
    _applySale(row, input);
    return _sale(row);
  }

  @override
  Future<Sale> paySale(int id, SalePayment payment) async {
    await _respond();
    final row = _saleRow(id);
    final account = _accountRow(payment.accountId);
    if (!account.active) {
      throw ApiException(
        'Нельзя провести оплату через деактивированный счёт',
        400,
      );
    }
    row
      ..accountId = account.id
      ..paid = true
      ..paidAt = dateOnly(payment.paidAt ?? _today);
    return _sale(row);
  }

  @override
  Future<void> deleteSale(int id) async {
    await _respond();
    _sales.remove(_saleRow(id));
  }

  // ---- расходы ----

  @override
  Future<List<Expense>> getExpenses(ExpenseFilter filter) async {
    await _respond();
    _validatePeriod(filter.from, filter.to);
    if (filter.accountId != null) _accountRow(filter.accountId!);
    final rows =
        _expenses.where((expense) {
          if (filter.from != null &&
              expense.expenseDate.isBefore(filter.from!)) {
            return false;
          }
          if (filter.to != null && expense.expenseDate.isAfter(filter.to!)) {
            return false;
          }
          if (filter.category != null && expense.category != filter.category) {
            return false;
          }
          return filter.accountId == null ||
              expense.accountId == filter.accountId;
        }).toList()..sort((a, b) {
          final byDate = b.expenseDate.compareTo(a.expenseDate);
          return byDate != 0 ? byDate : b.id.compareTo(a.id);
        });
    return rows.map(_expense).toList();
  }

  @override
  Future<Expense> createExpense(ExpenseInput input) async {
    await _respond();
    _validateExpense(input);
    final account = _accountRow(input.accountId);
    if (!account.active) {
      throw ApiException(
        'Нельзя добавить расход на деактивированный счёт',
        400,
      );
    }
    final row = _ExpenseRow(id: _nextId++);
    _applyExpense(row, input);
    _expenses.add(row);
    return _expense(row);
  }

  @override
  Future<Expense> updateExpense(int id, ExpenseInput input) async {
    await _respond();
    final row = _expenseRow(id);
    _validateExpense(input);
    // При правке бэкенд разрешает оставить скрытый счёт.
    _accountRow(input.accountId);
    _applyExpense(row, input);
    return _expense(row);
  }

  @override
  Future<void> deleteExpense(int id) async {
    await _respond();
    _expenses.remove(_expenseRow(id));
  }

  // ---- сводка и долги ----

  /// Как `FinanceSummaryService` бэкенда: доход — по дате продажи, вместе
  /// с неоплаченными; категории — в порядке списка; счета — все, включая
  /// скрытые, активные первыми. Остатки и долги — на сегодня, независимо
  /// от периода.
  @override
  Future<FinanceSummary> getSummary(FinancePeriod period) async {
    await _respond();
    _validatePeriod(period.from, period.to);
    return _summary(period);
  }

  FinanceSummary _summary(FinancePeriod period) {
    final sales = _sales.where((sale) => period.contains(sale.saleDate));
    final expenses = _expenses.where(
      (expense) => period.contains(expense.expenseDate),
    );
    final income = Money.sum(sales.map((sale) => sale.amount));
    final spent = Money.sum(expenses.map((expense) => expense.amount));

    final byCategory = <ExpenseCategory, Money>{};
    for (final expense in expenses) {
      byCategory[expense.category] =
          (byCategory[expense.category] ?? Money.zero) + expense.amount;
    }
    final categories = [
      for (final category in ExpenseCategory.values)
        if (byCategory[category] case final amount?)
          CategoryAmount(category: category, amount: amount),
    ];

    final unpaid = _sales.where((sale) => !sale.paid);
    final today = _today;
    return FinanceSummary(
      periodFrom: period.from,
      periodTo: period.to,
      totalIncome: income,
      totalExpense: spent,
      profit: income - spent,
      accounts: [
        for (final account in _sortedAccounts())
          AccountBalance(
            id: account.id,
            name: account.name,
            balance: _balance(account),
          ),
      ],
      expensesByCategory: categories,
      totalDebt: Money.sum(unpaid.map((sale) => sale.amount)),
      overdueDebt: Money.sum(
        unpaid
            .where((sale) => _sale(sale).isOverdueOn(today))
            .map((sale) => sale.amount),
      ),
    );
  }

  @override
  Future<List<CounterpartyDebt>> getDebts() async {
    await _respond();
    final today = _today;
    final groups = <int?, List<_SaleRow>>{};
    for (final sale in _sales.where((sale) => !sale.paid)) {
      groups.putIfAbsent(sale.counterpartyId, () => []).add(sale);
    }

    return sortDebts([
      for (final entry in groups.entries) _debt(entry.key, entry.value, today),
    ]);
  }

  CounterpartyDebt _debt(
    int? counterpartyId,
    List<_SaleRow> rows,
    DateTime today,
  ) {
    final counterparty = counterpartyId == null
        ? null
        : _findCounterparty(counterpartyId);
    final sales = rows.map(_sale).toList();
    return CounterpartyDebt(
      counterpartyId: counterpartyId,
      counterpartyName: counterparty?.name,
      phone: counterparty?.phone,
      totalDebt: Money.sum(sales.map((sale) => sale.amount)),
      overdueDays: sales.fold(
        0,
        (max, sale) =>
            sale.overdueDaysOn(today) > max ? sale.overdueDaysOn(today) : max,
      ),
      sales: [
        for (final sale in sales)
          DebtSale(
            id: sale.id,
            saleDate: sale.saleDate,
            amount: sale.amount,
            dueDate: sale.dueDate,
          ),
      ],
    );
  }

  // ---- отчёт ----

  /// Настоящий PDF формирует бэкенд. Мок отдаёт одностраничный PDF
  /// латиницей с итогами — чтобы в сборке на моке работали сохранение и
  /// «Поделиться». Имени файла нет, как если бы бэкенд его не прислал.
  @override
  Future<FinanceReportFile> getReportPdf(FinanceReportRequest request) async {
    await _respond();
    final period = request.period;
    _validatePeriod(period.from, period.to);
    final summary = _summary(period);
    String tenge(Money value) => '${value.toPlainString()} KZT';
    final lines = [
      'Fermer+ finance report (demo data)',
      'Type: ${request.type.apiValue}',
      'Period: ${formatApiDate(period.from)} - ${formatApiDate(period.to)}',
      'Income: ${tenge(summary.totalIncome)}',
      'Expense: ${tenge(summary.totalExpense)}',
      'Profit: ${tenge(summary.profit)}',
      'Debts: ${tenge(summary.totalDebt)}',
      'Created: ${formatApiDate(_today)}',
    ];
    return FinanceReportFile(bytes: _pdf(lines));
  }

  /// Минимальный PDF 1.4: одна страница A4, шрифт Helvetica, строки ASCII.
  static Uint8List _pdf(List<String> lines) {
    String escape(String text) => text
        .replaceAll(r'\', r'\\')
        .replaceAll('(', r'\(')
        .replaceAll(')', r'\)');
    final content = StringBuffer('BT /F1 14 Tf 50 790 Td');
    for (var i = 0; i < lines.length; i++) {
      if (i > 0) content.write(' 0 -24 Td');
      content.write(' (${escape(lines[i])}) Tj');
    }
    content.write(' ET');
    final stream = content.toString();

    final objects = [
      '<< /Type /Catalog /Pages 2 0 R >>',
      '<< /Type /Pages /Kids [3 0 R] /Count 1 >>',
      '<< /Type /Page /Parent 2 0 R /MediaBox [0 0 595 842] '
          '/Contents 4 0 R /Resources << /Font << /F1 5 0 R >> >> >>',
      '<< /Length ${stream.length} >>\nstream\n$stream\nendstream',
      '<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica >>',
    ];
    final pdf = StringBuffer('%PDF-1.4\n');
    final offsets = <int>[];
    for (var i = 0; i < objects.length; i++) {
      offsets.add(pdf.length);
      pdf.write('${i + 1} 0 obj\n${objects[i]}\nendobj\n');
    }
    final xref = pdf.length;
    pdf
      ..write('xref\n0 ${objects.length + 1}\n')
      ..write('0000000000 65535 f \n');
    for (final offset in offsets) {
      pdf.write('${offset.toString().padLeft(10, '0')} 00000 n \n');
    }
    pdf.write(
      'trailer\n<< /Size ${objects.length + 1} /Root 1 0 R >>\n'
      'startxref\n$xref\n%%EOF\n',
    );
    return Uint8List.fromList(ascii.encode(pdf.toString()));
  }

  // ---- правила ----

  Money _balance(_AccountRow account) {
    final received = _sales
        .where((sale) => sale.paid && sale.accountId == account.id)
        .map((sale) => sale.amount);
    final spent = _expenses
        .where((expense) => expense.accountId == account.id)
        .map((expense) => expense.amount);
    return account.initialBalance + Money.sum(received) - Money.sum(spent);
  }

  void _applySale(_SaleRow row, SaleInput input) {
    row
      ..counterpartyId = input.counterpartyId
      ..saleDate = dateOnly(input.saleDate)
      ..productName = input.productName.trim()
      ..quantity = input.quantity
      ..unit = input.unit
      ..pricePerUnit = input.pricePerUnit
      ..amount = input.quantity.times(input.pricePerUnit)
      ..accountId = input.accountId
      ..paid = input.paid
      ..paidAt = input.paid ? dateOnly(input.paidAt ?? _today) : null
      ..dueDate = input.dueDate != null
          ? dateOnly(input.dueDate!)
          : (input.paid ? null : SaleInput.defaultDueDate(input.saleDate))
      ..comment = _blankToNull(input.comment);
  }

  void _applyExpense(_ExpenseRow row, ExpenseInput input) {
    row
      ..category = input.category
      ..name = input.name.trim()
      ..amount = input.amount
      ..expenseDate = dateOnly(input.expenseDate)
      ..accountId = input.accountId
      ..comment = _blankToNull(input.comment)
      ..cattleId = input.cattleId;
  }

  void _validateAccount(AccountInput input) {
    _requireText(input.name, 100, 'Укажите название счёта');
    if (input.initialBalance.isNegative) {
      throw ApiException('Начальный остаток не может быть отрицательным', 400);
    }
    _requireMoneyDigits(input.initialBalance);
  }

  void _validateCounterparty(CounterpartyInput input) {
    _requireText(input.name, 200, 'Укажите название покупателя');
    if ((input.phone?.trim().length ?? 0) > 20) {
      throw ApiException('Телефон не длиннее 20 символов', 400);
    }
  }

  void _validateSale(SaleInput input) {
    _requireText(input.productName, 200, 'Укажите товар');
    if (!input.quantity.isPositive) {
      throw ApiException('Количество должно быть больше нуля', 400);
    }
    // `numeric(12,3)`: не больше 9 цифр до запятой.
    if (input.quantity.milli >= 1000000000000) {
      throw ApiException('Слишком большое количество', 400);
    }
    if (input.pricePerUnit.isNegative) {
      throw ApiException('Цена не может быть отрицательной', 400);
    }
    _requireMoneyDigits(input.pricePerUnit);
    _requireComment(input.comment);
  }

  void _validateExpense(ExpenseInput input) {
    _requireText(input.name, 200, 'Укажите, на что потратили');
    if (!input.amount.isPositive) {
      throw ApiException('Сумма расхода должна быть больше нуля', 400);
    }
    _requireMoneyDigits(input.amount);
    _requireComment(input.comment);
  }

  void _checkCounterparty(int? id, {required bool requireActive}) {
    if (id == null) return;
    final counterparty = _counterpartyRow(id);
    if (requireActive && !counterparty.active) {
      throw ApiException('Нельзя выбрать деактивированного контрагента', 400);
    }
  }

  void _checkSaleAccount(SaleInput input) {
    if (input.accountId == null) {
      if (input.paid) {
        throw ApiException('Для оплаченной продажи нужно указать счёт', 400);
      }
      return;
    }
    final account = _accountRow(input.accountId!);
    if (input.paid && !account.active) {
      throw ApiException(
        'Нельзя провести оплату через деактивированный счёт',
        400,
      );
    }
  }

  static void _validatePeriod(DateTime? from, DateTime? to) {
    if (from != null && to != null && from.isAfter(to)) {
      throw ApiException(
        'Дата начала периода не может быть позже даты окончания',
        400,
      );
    }
  }

  static void _requireText(String value, int maxLength, String emptyMessage) {
    final text = value.trim();
    if (text.isEmpty) throw ApiException(emptyMessage, 400);
    if (text.length > maxLength) {
      throw ApiException('Не длиннее $maxLength символов', 400);
    }
  }

  static void _requireComment(String? comment) {
    if ((comment?.trim().length ?? 0) > 2000) {
      throw ApiException('Комментарий не длиннее 2000 символов', 400);
    }
  }

  /// `numeric(15,2)`: не больше 13 цифр до запятой.
  static void _requireMoneyDigits(Money value) {
    if (value.abs().tiyn >= 1000000000000000) {
      throw ApiException('Слишком большая сумма', 400);
    }
  }

  static String? _blankToNull(String? value) {
    final text = value?.trim();
    return text == null || text.isEmpty ? null : text;
  }

  // ---- поиск и преобразование ----

  _AccountRow _accountRow(int id) {
    for (final row in _accounts) {
      if (row.id == id) return row;
    }
    throw ApiException('Счёт не найден', 404);
  }

  _CounterpartyRow? _findCounterparty(int id) {
    for (final row in _counterparties) {
      if (row.id == id) return row;
    }
    return null;
  }

  _CounterpartyRow _counterpartyRow(int id) =>
      _findCounterparty(id) ??
      (throw ApiException('Контрагент не найден', 404));

  _SaleRow _saleRow(int id) {
    for (final row in _sales) {
      if (row.id == id) return row;
    }
    throw ApiException('Продажа не найдена', 404);
  }

  _ExpenseRow _expenseRow(int id) {
    for (final row in _expenses) {
      if (row.id == id) return row;
    }
    throw ApiException('Расход не найден', 404);
  }

  String? _accountName(int? id) {
    if (id == null) return null;
    for (final row in _accounts) {
      if (row.id == id) return row.name;
    }
    return null;
  }

  FinanceAccount _account(_AccountRow row) => FinanceAccount(
    id: row.id,
    name: row.name,
    type: row.type,
    initialBalance: row.initialBalance,
    balance: _balance(row),
    active: row.active,
  );

  Counterparty _counterparty(_CounterpartyRow row) => Counterparty(
    id: row.id,
    name: row.name,
    phone: row.phone,
    active: row.active,
  );

  Sale _sale(_SaleRow row) => Sale(
    id: row.id,
    counterpartyId: row.counterpartyId,
    counterpartyName: row.counterpartyId == null
        ? null
        : _findCounterparty(row.counterpartyId!)?.name,
    saleDate: row.saleDate,
    productName: row.productName,
    quantity: row.quantity,
    unit: row.unit,
    pricePerUnit: row.pricePerUnit,
    amount: row.amount,
    accountId: row.accountId,
    accountName: _accountName(row.accountId),
    paid: row.paid,
    paidAt: row.paidAt,
    dueDate: row.dueDate,
    comment: row.comment,
  );

  Expense _expense(_ExpenseRow row) => Expense(
    id: row.id,
    category: row.category,
    name: row.name,
    amount: row.amount,
    expenseDate: row.expenseDate,
    accountId: row.accountId,
    accountName: _accountName(row.accountId),
    comment: row.comment,
    cattleId: row.cattleId,
  );

  // ---- демо-данные ----

  /// Данные из прототипа. Даты отсчитываются от сегодняшнего дня, чтобы
  /// в текущем месяце всегда были операции, долги и одна просрочка.
  void _seedDemoData() {
    final today = _today;
    DateTime day(int offset) => addDays(today, offset);

    int account(
      String name,
      AccountType type,
      int tenge, {
      bool active = true,
    }) {
      final row = _AccountRow(
        id: _nextId++,
        name: name,
        type: type,
        initialBalance: Money.tenge(tenge),
      )..active = active;
      _accounts.add(row);
      return row.id;
    }

    final cash = account('Касса', AccountType.cash, 400000);
    final kaspi = account('Kaspi', AccountType.card, 950000);
    final halyk = account('Halyk', AccountType.bank, 400000);
    account('Старая карта', AccountType.card, 0, active: false);

    int buyer(String name, String? phone) {
      final row = _CounterpartyRow(id: _nextId++, name: name, phone: phone);
      _counterparties.add(row);
      return row.id;
    }

    final bereke = buyer('Магазин Береке', '+7 701 234 56 78');
    final dostyk = buyer('Магазин «Достык»', '+7 705 118 40 22');
    final saule = buyer('ИП Сауле, молочный отдел', '+7 777 902 13 64');
    final zhailau = buyer('Кафе «Жайлау»', null);

    void sale(
      int offset,
      int? counterpartyId,
      String product,
      int quantity,
      SaleUnit unit,
      int price, {
      int? accountId,
      int? paidOffset,
      int? dueOffset,
    }) {
      final row = _SaleRow(id: _nextId++);
      _applySale(
        row,
        SaleInput(
          counterpartyId: counterpartyId,
          saleDate: day(offset),
          productName: product,
          quantity: Quantity.whole(quantity),
          unit: unit,
          pricePerUnit: Money.tenge(price),
          paid: accountId != null,
          accountId: accountId,
          paidAt: accountId == null ? null : day(paidOffset ?? offset),
          dueDate: dueOffset == null ? null : day(dueOffset),
        ),
      );
      _sales.add(row);
    }

    const l = SaleUnit.liter;
    const kg = SaleUnit.kilogram;
    sale(-45, dostyk, 'Молоко', 800, l, 240, accountId: kaspi);
    sale(-32, bereke, 'Молоко', 500, l, 240, accountId: kaspi, paidOffset: -22);
    sale(-30, zhailau, 'Сметана', 15, kg, 1800, dueOffset: -16);
    sale(-18, bereke, 'Молоко', 580, l, 250, dueOffset: -6);
    sale(-16, dostyk, 'Молоко', 400, l, 250, accountId: kaspi);
    sale(-14, null, 'Творог', 12, kg, 2200, accountId: cash);
    sale(
      -11,
      zhailau,
      'Сметана',
      20,
      kg,
      1800,
      accountId: kaspi,
      paidOffset: -9,
    );
    sale(-9, bereke, 'Молоко', 560, l, 250, dueOffset: 5);
    sale(-7, dostyk, 'Молоко', 420, l, 250, accountId: kaspi);
    sale(-4, saule, 'Творог', 30, kg, 2200, dueOffset: 10);
    sale(-2, null, 'Молоко', 60, l, 300, accountId: cash);
    sale(0, dostyk, 'Молоко', 120, l, 250, accountId: cash);

    void expense(
      int offset,
      ExpenseCategory category,
      String name,
      int tenge,
      int accountId, {
      String? comment,
    }) {
      final row = _ExpenseRow(id: _nextId++);
      _applyExpense(
        row,
        ExpenseInput(
          category: category,
          name: name,
          amount: Money.tenge(tenge),
          expenseDate: day(offset),
          accountId: accountId,
          comment: comment,
        ),
      );
      _expenses.add(row);
    }

    expense(
      -47,
      ExpenseCategory.feed,
      'Комбикорм КК-60, 8 мешков',
      150000,
      kaspi,
    );
    expense(-38, ExpenseCategory.rent, 'Аренда пастбища', 50000, halyk);
    expense(
      -19,
      ExpenseCategory.salary,
      'Зарплата дояркам',
      150000,
      cash,
      comment: 'Айгуль и Серик',
    );
    expense(
      -17,
      ExpenseCategory.feed,
      'Комбикорм КК-60, 10 мешков',
      185000,
      kaspi,
      comment: 'Агро-Трейд, с доставкой',
    );
    expense(
      -15,
      ExpenseCategory.veterinary,
      'Вакцина от ящура, 30 доз',
      24500,
      cash,
    );
    expense(-13, ExpenseCategory.fuel, 'Дизель, 200 л', 64000, kaspi);
    expense(
      -9,
      ExpenseCategory.salary,
      'Аванс доярке',
      75000,
      cash,
      comment: 'Айгуль',
    );
    expense(-5, ExpenseCategory.feed, 'Сено, 40 рулонов', 160000, kaspi);
    expense(
      -3,
      ExpenseCategory.equipment,
      'Запчасти для доильного аппарата',
      18000,
      cash,
    );
    expense(-1, ExpenseCategory.other, 'Электричество', 22000, kaspi);
    expense(0, ExpenseCategory.feed, 'Комбикорм, 2 мешка', 45000, cash);
  }
}

class _AccountRow {
  _AccountRow({
    required this.id,
    required this.name,
    required this.type,
    required this.initialBalance,
  });

  final int id;
  String name;
  AccountType type;
  Money initialBalance;
  bool active = true;
}

class _CounterpartyRow {
  _CounterpartyRow({required this.id, required this.name, this.phone});

  final int id;
  String name;
  String? phone;
  bool active = true;
}

class _SaleRow {
  _SaleRow({required this.id});

  final int id;
  int? counterpartyId;
  late DateTime saleDate;
  late String productName;
  late Quantity quantity;
  late SaleUnit unit;
  late Money pricePerUnit;
  late Money amount;
  int? accountId;
  bool paid = false;
  DateTime? paidAt;
  DateTime? dueDate;
  String? comment;
}

class _ExpenseRow {
  _ExpenseRow({required this.id});

  final int id;
  late ExpenseCategory category;
  late String name;
  late Money amount;
  late DateTime expenseDate;
  late int accountId;
  String? comment;
  int? cattleId;
}
