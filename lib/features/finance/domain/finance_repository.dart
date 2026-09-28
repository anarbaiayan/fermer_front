import 'entities/finance_date.dart';
import 'entities/finance_entities.dart';
import 'entities/finance_inputs.dart';

/// Источник данных «Финансов». Экраны работают только через этот
/// интерфейс, поэтому мок и реальный API взаимозаменяемы.
///
/// Ошибки — `ApiException` с сообщением для пользователя, как в остальных
/// модулях.
abstract interface class FinanceRepository {
  // Счета: /api/finance/accounts. Список включает скрытые (active = false).
  Future<List<FinanceAccount>> getAccounts();
  Future<FinanceAccount> createAccount(AccountInput input);
  Future<FinanceAccount> updateAccount(int id, AccountInput input);

  /// Бэкенд не удаляет счёт, а скрывает его (`DELETE` → active = false).
  Future<void> deactivateAccount(int id);

  // Покупатели: /api/finance/counterparties.
  Future<List<Counterparty>> getCounterparties();
  Future<Counterparty> createCounterparty(CounterpartyInput input);
  Future<Counterparty> updateCounterparty(int id, CounterpartyInput input);
  Future<void> deactivateCounterparty(int id);

  // Продажи: /api/finance/sales. Новые сверху.
  Future<List<Sale>> getSales(SaleFilter filter);

  /// Уникальные названия товаров из прошлых продаж.
  Future<List<String>> getProductNames();
  Future<Sale> createSale(SaleInput input);
  Future<Sale> updateSale(int id, SaleInput input);
  Future<Sale> paySale(int id, SalePayment payment);
  Future<void> deleteSale(int id);

  // Расходы: /api/finance/expenses. Новые сверху.
  Future<List<Expense>> getExpenses(ExpenseFilter filter);
  Future<Expense> createExpense(ExpenseInput input);
  Future<Expense> updateExpense(int id, ExpenseInput input);
  Future<void> deleteExpense(int id);

  // Сводка и долги: /api/finance/summary, /api/finance/debts.
  Future<FinanceSummary> getSummary(FinancePeriod period);

  /// Сверху — самые просроченные.
  Future<List<CounterpartyDebt>> getDebts();
}
