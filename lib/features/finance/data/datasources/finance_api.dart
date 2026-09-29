import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:frontend/core/network/api_exceptions.dart';

import '../../domain/entities/finance_date.dart';
import '../../domain/entities/finance_entities.dart';
import '../../domain/entities/finance_inputs.dart';
import '../../domain/finance_repository.dart';
import '../models/finance_json.dart';

/// [FinanceRepository] поверх `/api/finance/**`.
///
/// Пока бэкенд не выкатил модуль, экраны работают на моке
/// (см. `financeRepositoryProvider`). Сводка и долги вызывают пути из ТЗ —
/// на бэкенде их ещё нет.
class FinanceApi implements FinanceRepository {
  FinanceApi(this._dio);

  final Dio _dio;

  Future<T> _call<T>(Future<T> Function() request) async {
    try {
      return await request();
    } on DioException catch (e) {
      throw ApiException(extractApiMessage(e), e.response?.statusCode);
    }
  }

  Future<List<T>> _getList<T>(
    String path,
    T Function(Map<String, dynamic>) parse, {
    Map<String, dynamic>? query,
  }) => _call(() async {
    final r = await _dio.get(
      path,
      queryParameters: query == null || query.isEmpty ? null : query,
    );
    return (r.data as List).cast<Map<String, dynamic>>().map(parse).toList();
  });

  Future<T> _send<T>(
    String method,
    String path,
    Map<String, dynamic> body,
    T Function(Map<String, dynamic>) parse,
  ) => _call(() async {
    final r = await _dio.request(
      path,
      data: body,
      options: Options(method: method),
    );
    return parse(r.data as Map<String, dynamic>);
  });

  Future<void> _delete(String path) => _call(() => _dio.delete(path));

  // ---- счета ----

  @override
  Future<List<FinanceAccount>> getAccounts() =>
      _getList('/finance/accounts', accountFromJson);

  @override
  Future<FinanceAccount> createAccount(AccountInput input) => _send(
    'POST',
    '/finance/accounts',
    accountInputToJson(input),
    accountFromJson,
  );

  @override
  Future<FinanceAccount> updateAccount(int id, AccountInput input) => _send(
    'PUT',
    '/finance/accounts/$id',
    accountInputToJson(input),
    accountFromJson,
  );

  @override
  Future<void> deactivateAccount(int id) => _delete('/finance/accounts/$id');

  // ---- покупатели ----

  @override
  Future<List<Counterparty>> getCounterparties() =>
      _getList('/finance/counterparties', counterpartyFromJson);

  @override
  Future<Counterparty> createCounterparty(CounterpartyInput input) => _send(
    'POST',
    '/finance/counterparties',
    counterpartyInputToJson(input),
    counterpartyFromJson,
  );

  @override
  Future<Counterparty> updateCounterparty(int id, CounterpartyInput input) =>
      _send(
        'PUT',
        '/finance/counterparties/$id',
        counterpartyInputToJson(input),
        counterpartyFromJson,
      );

  @override
  Future<void> deactivateCounterparty(int id) =>
      _delete('/finance/counterparties/$id');

  // ---- продажи ----

  @override
  Future<List<Sale>> getSales(SaleFilter filter) => _getList(
    '/finance/sales',
    saleFromJson,
    query: saleFilterToQuery(filter),
  );

  @override
  Future<List<String>> getProductNames() => _call(() async {
    final r = await _dio.get('/finance/sales/products');
    return (r.data as List).map((name) => name.toString()).toList();
  });

  @override
  Future<Sale> createSale(SaleInput input) =>
      _send('POST', '/finance/sales', saleInputToJson(input), saleFromJson);

  @override
  Future<Sale> updateSale(int id, SaleInput input) =>
      _send('PUT', '/finance/sales/$id', saleInputToJson(input), saleFromJson);

  /// В ТЗ — `POST`, на бэкенде — `PUT /sales/{id}/pay`.
  @override
  Future<Sale> paySale(int id, SalePayment payment) => _send(
    'PUT',
    '/finance/sales/$id/pay',
    salePaymentToJson(payment),
    saleFromJson,
  );

  @override
  Future<void> deleteSale(int id) => _delete('/finance/sales/$id');

  // ---- расходы ----

  @override
  Future<List<Expense>> getExpenses(ExpenseFilter filter) => _getList(
    '/finance/expenses',
    expenseFromJson,
    query: expenseFilterToQuery(filter),
  );

  @override
  Future<Expense> createExpense(ExpenseInput input) => _send(
    'POST',
    '/finance/expenses',
    expenseInputToJson(input),
    expenseFromJson,
  );

  @override
  Future<Expense> updateExpense(int id, ExpenseInput input) => _send(
    'PUT',
    '/finance/expenses/$id',
    expenseInputToJson(input),
    expenseFromJson,
  );

  @override
  Future<void> deleteExpense(int id) => _delete('/finance/expenses/$id');

  // ---- сводка и долги (контракт из ТЗ) ----

  @override
  Future<FinanceSummary> getSummary(FinancePeriod period) => _call(() async {
    final r = await _dio.get(
      '/finance/summary',
      queryParameters: periodToQuery(period),
    );
    return summaryFromJson(r.data as Map<String, dynamic>);
  });

  @override
  Future<List<CounterpartyDebt>> getDebts() =>
      _getList('/finance/debts', debtFromJson);

  // ---- отчёт (контракт из ТЗ) ----

  @override
  Future<FinanceReportFile> getReportPdf(FinanceReportRequest request) async {
    try {
      final r = await _dio.get<List<int>>(
        '/finance/report/pdf',
        queryParameters: reportRequestToQuery(request),
        options: Options(
          responseType: ResponseType.bytes,
          headers: {'Accept': 'application/pdf'},
        ),
      );
      return FinanceReportFile(
        bytes: Uint8List.fromList(r.data ?? const []),
        fileName: fileNameFromDisposition(
          r.headers.value('content-disposition'),
        ),
      );
    } on DioException catch (e) {
      throw ApiException(
        _bytesMessage(e.response?.data) ?? extractApiMessage(e),
        e.response?.statusCode,
      );
    }
  }

  /// При `ResponseType.bytes` и ошибка бэкенда приходит байтами:
  /// достаём `{message}` сами.
  static String? _bytesMessage(Object? data) {
    if (data is! List<int>) return null;
    try {
      final json = jsonDecode(utf8.decode(data, allowMalformed: true));
      final message = json is Map ? json['message']?.toString().trim() : null;
      return message == null || message.isEmpty ? null : message;
    } on FormatException {
      return null;
    }
  }
}
