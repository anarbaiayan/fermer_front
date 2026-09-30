import 'package:frontend/core/network/network_providers.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../data/datasources/finance_api.dart';
import '../data/mock/mock_finance_repository.dart';
import '../domain/entities/finance_date.dart';
import '../domain/entities/finance_entities.dart';
import '../domain/entities/finance_enums.dart';
import '../domain/entities/finance_inputs.dart';
import '../domain/finance_repository.dart';

/// Реальный API или мок. По умолчанию — API (`/api/finance/**`). Мок —
/// для демо без сервера: `flutter run --dart-define=FINANCE_MOCK=true`.
const bool kFinanceUseMock = bool.fromEnvironment('FINANCE_MOCK');

/// Часы модуля. В тестах подменяется, чтобы «сегодня» было фиксированным.
final financeClockProvider = Provider<DateTime Function()>(
  (ref) => DateTime.now,
);

/// Сегодняшний календарный день для просрочек и дат по умолчанию.
final financeTodayProvider = Provider.autoDispose<DateTime>(
  (ref) => dateOnly(ref.watch(financeClockProvider)()),
);

/// Живёт всё время работы приложения: данные мока не теряются при уходе
/// с экрана.
final financeRepositoryProvider = Provider<FinanceRepository>((ref) {
  if (kFinanceUseMock) {
    return MockFinanceRepository(clock: ref.read(financeClockProvider));
  }
  return FinanceApi(ref.read(dioClientProvider).dio);
});

// ---- чтение ----

/// Все счета, включая скрытые (у них `active = false`).
final financeAccountsProvider =
    FutureProvider.autoDispose<List<FinanceAccount>>(
      (ref) => ref.watch(financeRepositoryProvider).getAccounts(),
    );

/// Все покупатели, включая скрытых.
final financeCounterpartiesProvider =
    FutureProvider.autoDispose<List<Counterparty>>(
      (ref) => ref.watch(financeRepositoryProvider).getCounterparties(),
    );

final financeSalesProvider = FutureProvider.autoDispose
    .family<List<Sale>, SaleFilter>(
      (ref, filter) => ref.watch(financeRepositoryProvider).getSales(filter),
    );

/// Названия товаров из прошлых продаж — для подсказки в форме.
final financeProductNamesProvider = FutureProvider.autoDispose<List<String>>(
  (ref) => ref.watch(financeRepositoryProvider).getProductNames(),
);

final financeExpensesProvider = FutureProvider.autoDispose
    .family<List<Expense>, ExpenseFilter>(
      (ref, filter) => ref.watch(financeRepositoryProvider).getExpenses(filter),
    );

final financeSummaryProvider = FutureProvider.autoDispose
    .family<FinanceSummary, FinancePeriod>(
      (ref, period) => ref.watch(financeRepositoryProvider).getSummary(period),
    );

final financeDebtsProvider = FutureProvider.autoDispose<List<CounterpartyDebt>>(
  (ref) => ref.watch(financeRepositoryProvider).getDebts(),
);

/// Месяц, выбранный на вкладках «Сводка», «Доход» и «Расход» — общий, как
/// в прототипе. Сбрасывается на текущий, когда раздел закрыт.
final financeMonthProvider = StateProvider.autoDispose<DateTime>(
  (ref) => monthStart(ref.watch(financeTodayProvider)),
);

/// Фильтр категории на вкладке «Расход»; `null` — все. Живёт, пока открыт
/// раздел: сводка открывает вкладку сразу с нужной категорией.
final financeExpenseCategoryFilterProvider =
    StateProvider.autoDispose<ExpenseCategory?>((ref) => null);

/// Фильтр счёта на вкладке «Расход»; `null` — все счета.
final financeExpenseAccountFilterProvider = StateProvider.autoDispose<int?>(
  (ref) => null,
);

/// Фильтр на вкладке «Доход». Живёт, пока открыт раздел.
final financeIncomeFilterProvider = StateProvider.autoDispose<IncomeFilter>(
  (ref) => IncomeFilter.all,
);

/// Фильтры вкладки «Доход». Просрочка считается на лету (правило 3), поэтому
/// фильтруем на клиенте: бэкенд умеет только `paid`.
enum IncomeFilter {
  all,
  paid,
  debt,
  overdue;

  bool matches(Sale sale, DateTime today) => switch (this) {
    IncomeFilter.all => true,
    IncomeFilter.paid => sale.paid,
    IncomeFilter.debt => !sale.paid,
    IncomeFilter.overdue => sale.isOverdueOn(today),
  };
}

/// Последний счёт, через который платили или получали деньги. Форма
/// подставляет его, чтобы запись занимала секунды (решение Р4 прототипа).
final financeLastAccountProvider = StateProvider<int?>((ref) => null);

/// Прошлая продажа товара — источник единицы и цены в форме (вопрос В3:
/// пока считаем на клиенте по списку продаж). Сначала последняя продажа
/// тому же покупателю (или тоже без покупателя), иначе последняя вообще.
/// Товары из списка сравниваются на любом языке: «Сүт» находит «Молоко».
Sale? lastSaleOf(List<Sale> sales, String productName, int? counterpartyId) {
  if (productName.trim().isEmpty) return null;
  final key = saleProductKey(productName);
  Sale? latest;
  Sale? sameBuyer;
  for (final sale in sales) {
    if (saleProductKey(sale.productName) != key) continue;
    if (latest == null || _isLater(sale, latest)) latest = sale;
    if (sale.counterpartyId == counterpartyId &&
        (sameBuyer == null || _isLater(sale, sameBuyer))) {
      sameBuyer = sale;
    }
  }
  return sameBuyer ?? latest;
}

bool _isLater(Sale a, Sale b) {
  final byDate = a.saleDate.compareTo(b.saleDate);
  return byDate != 0 ? byDate > 0 : a.id > b.id;
}

/// Активные покупатели для формы продажи: кому продавали недавно — первыми
/// (ТЗ: «последние сверху»), остальные по имени.
List<Counterparty> recentCounterparties(
  List<Counterparty> counterparties,
  List<Sale> sales,
) {
  final lastSale = <int, DateTime>{};
  for (final sale in sales) {
    final id = sale.counterpartyId;
    if (id == null) continue;
    final known = lastSale[id];
    if (known == null || sale.saleDate.isAfter(known)) {
      lastSale[id] = sale.saleDate;
    }
  }
  return counterparties.where((c) => c.active).toList()..sort((a, b) {
    final aLast = lastSale[a.id];
    final bLast = lastSale[b.id];
    if (aLast != null && bLast != null) {
      final byDate = bLast.compareTo(aLast);
      if (byDate != 0) return byDate;
    } else if (aLast != null || bLast != null) {
      return aLast != null ? -1 : 1;
    }
    return a.name.toLowerCase().compareTo(b.name.toLowerCase());
  });
}

/// Счета для остатков в сводке и на главной: активные, а за ними скрытые,
/// на которых остались деньги. Без них итог был бы меньше реальных денег;
/// пустые скрытые счета не показываем.
List<FinanceAccount> balanceAccounts(List<FinanceAccount> accounts) => [
  ...accounts.where((account) => account.active),
  ...accounts.where((account) => !account.active && !account.balance.isZero),
];

/// Счёт по умолчанию для новой записи: последний использованный, иначе
/// первая касса, иначе первый активный.
FinanceAccount? pickDefaultAccount(
  List<FinanceAccount> accounts,
  int? lastUsedId,
) {
  final active = accounts.where((account) => account.active).toList();
  return active.where((a) => a.id == lastUsedId).firstOrNull ??
      active.where((a) => a.type == AccountType.cash).firstOrNull ??
      active.firstOrNull;
}

// ---- изменения ----

final financeMutationsProvider = Provider<FinanceMutations>(
  (ref) => FinanceMutations(ref),
);

/// Все изменения данных «Финансов». Каждый метод после успеха сбрасывает
/// ровно те провайдеры, чьи данные поменялись.
class FinanceMutations {
  FinanceMutations(this._ref);

  final Ref _ref;

  FinanceRepository get _repository => _ref.read(financeRepositoryProvider);

  Future<FinanceAccount> createAccount(AccountInput input) async {
    final account = await _repository.createAccount(input);
    _balancesChanged();
    return account;
  }

  Future<FinanceAccount> updateAccount(int id, AccountInput input) async {
    final account = await _repository.updateAccount(id, input);
    _balancesChanged();
    // Название счёта показывается в строках продаж и расходов.
    _ref
      ..invalidate(financeSalesProvider)
      ..invalidate(financeExpensesProvider);
    return account;
  }

  Future<void> deactivateAccount(int id) async {
    await _repository.deactivateAccount(id);
    _balancesChanged();
  }

  Future<Counterparty> createCounterparty(CounterpartyInput input) async {
    final counterparty = await _repository.createCounterparty(input);
    _ref.invalidate(financeCounterpartiesProvider);
    return counterparty;
  }

  Future<Counterparty> updateCounterparty(
    int id,
    CounterpartyInput input,
  ) async {
    final counterparty = await _repository.updateCounterparty(id, input);
    // Имя и телефон видны в продажах и долгах.
    _ref
      ..invalidate(financeCounterpartiesProvider)
      ..invalidate(financeSalesProvider)
      ..invalidate(financeDebtsProvider);
    return counterparty;
  }

  Future<void> deactivateCounterparty(int id) async {
    await _repository.deactivateCounterparty(id);
    _ref.invalidate(financeCounterpartiesProvider);
  }

  Future<Sale> createSale(SaleInput input) async {
    final sale = await _repository.createSale(input);
    _salesChanged();
    _ref.invalidate(financeProductNamesProvider);
    if (input.paid) _usedAccount(input.accountId);
    return sale;
  }

  Future<Sale> updateSale(int id, SaleInput input) async {
    final sale = await _repository.updateSale(id, input);
    _salesChanged();
    _ref.invalidate(financeProductNamesProvider);
    if (input.paid) _usedAccount(input.accountId);
    return sale;
  }

  Future<Sale> paySale(int id, SalePayment payment) async {
    final sale = await _repository.paySale(id, payment);
    _salesChanged();
    _usedAccount(payment.accountId);
    return sale;
  }

  Future<void> deleteSale(int id) async {
    await _repository.deleteSale(id);
    _salesChanged();
    _ref.invalidate(financeProductNamesProvider);
  }

  Future<Expense> createExpense(ExpenseInput input) async {
    final expense = await _repository.createExpense(input);
    _expensesChanged();
    _usedAccount(input.accountId);
    return expense;
  }

  Future<Expense> updateExpense(int id, ExpenseInput input) async {
    final expense = await _repository.updateExpense(id, input);
    _expensesChanged();
    _usedAccount(input.accountId);
    return expense;
  }

  Future<void> deleteExpense(int id) async {
    await _repository.deleteExpense(id);
    _expensesChanged();
  }

  void _usedAccount(int? id) {
    if (id != null) _ref.read(financeLastAccountProvider.notifier).state = id;
  }

  void _balancesChanged() {
    _ref
      ..invalidate(financeAccountsProvider)
      ..invalidate(financeSummaryProvider);
  }

  void _salesChanged() {
    _balancesChanged();
    _ref
      ..invalidate(financeSalesProvider)
      ..invalidate(financeDebtsProvider);
  }

  void _expensesChanged() {
    _balancesChanged();
    _ref.invalidate(financeExpensesProvider);
  }
}
