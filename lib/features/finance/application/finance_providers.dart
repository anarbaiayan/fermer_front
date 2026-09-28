import 'package:frontend/core/network/network_providers.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../data/datasources/finance_api.dart';
import '../data/mock/mock_finance_repository.dart';
import '../domain/entities/finance_date.dart';
import '../domain/entities/finance_entities.dart';
import '../domain/entities/finance_inputs.dart';
import '../domain/finance_repository.dart';

/// Мок или реальный API. Бэкенд ещё не выкатил `/api/finance/**`, поэтому
/// по умолчанию мок. Проверить модуль на dev-сервере:
/// `flutter run --dart-define=FINANCE_API=true --dart-define=API_BASE_URL=...`.
const bool kFinanceUseMock = !bool.fromEnvironment('FINANCE_API');

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
    return sale;
  }

  Future<Sale> updateSale(int id, SaleInput input) async {
    final sale = await _repository.updateSale(id, input);
    _salesChanged();
    _ref.invalidate(financeProductNamesProvider);
    return sale;
  }

  Future<Sale> paySale(int id, SalePayment payment) async {
    final sale = await _repository.paySale(id, payment);
    _salesChanged();
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
    return expense;
  }

  Future<Expense> updateExpense(int id, ExpenseInput input) async {
    final expense = await _repository.updateExpense(id, input);
    _expensesChanged();
    return expense;
  }

  Future<void> deleteExpense(int id) async {
    await _repository.deleteExpense(id);
    _expensesChanged();
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
