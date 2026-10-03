import 'package:flutter/material.dart';
import 'package:frontend/core/localization/l10n_extension.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/features/auth/application/auth_providers.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../application/finance_providers.dart';
import '../../domain/entities/finance_enums.dart';
import '../../domain/entities/finance_inputs.dart';
import '../../domain/entities/money.dart';
import '../finance_format.dart';
import 'finance_common.dart';

/// «В документ попадут»: хозяйство, период, итоги и число операций —
/// чтобы не формировать PDF вслепую. ТЗ требует в документе хозяйство,
/// период, итоги, таблицу операций и дату формирования.
class FinanceReportContents extends ConsumerWidget {
  const FinanceReportContents({super.key, required this.request});

  final FinanceReportRequest request;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final format = FinanceFormat.of(context);
    final period = request.period;
    final type = request.type;
    final farm = ref.watch(authControllerProvider).user?.farmName?.trim();

    final summary = ref.watch(financeSummaryProvider(period)).valueOrNull;
    String money(Money? Function() pick) {
      final value = summary == null ? null : pick();
      return value == null ? '…' : format.money(value);
    }

    // Операции — строки таблицы в документе.
    int? count(List<Object>? list) => list?.length;
    final int? operations = switch (type) {
      FinanceReportType.full => () {
        final sales = count(
          ref
              .watch(financeSalesProvider(SaleFilter.period(period)))
              .valueOrNull,
        );
        final expenses = count(
          ref
              .watch(financeExpensesProvider(ExpenseFilter.period(period)))
              .valueOrNull,
        );
        return sales == null || expenses == null ? null : sales + expenses;
      }(),
      FinanceReportType.income => count(
        ref.watch(financeSalesProvider(SaleFilter.period(period))).valueOrNull,
      ),
      FinanceReportType.expense => count(
        ref
            .watch(financeExpensesProvider(ExpenseFilter.period(period)))
            .valueOrNull,
      ),
      FinanceReportType.debts => count(
        ref
            .watch(financeSalesProvider(const SaleFilter(paid: false)))
            .valueOrNull,
      ),
    };

    final rows = <(String, String)>[
      (l10n.financeReportFarm, farm == null || farm.isEmpty ? '—' : farm),
      (
        l10n.financeReportPeriodLabel,
        '${format.date(period.from)} — ${format.date(period.to)}',
      ),
      if (type == FinanceReportType.full || type == FinanceReportType.income)
        (l10n.financeTabIncome, money(() => summary!.totalIncome)),
      if (type == FinanceReportType.full || type == FinanceReportType.expense)
        (l10n.financeTabExpense, money(() => summary!.totalExpense)),
      if (type == FinanceReportType.full)
        (l10n.financeProfit, money(() => summary!.profit)),
      if (type == FinanceReportType.debts)
        (l10n.financeDebtsTitle, money(() => summary!.totalDebt)),
      (l10n.financeReportOperations, operations?.toString() ?? '…'),
    ];

    return FinanceCard(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.financeReportContents.toUpperCase(),
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.7,
              color: AppColors.additional3,
            ),
          ),
          const SizedBox(height: 10),
          for (final (key, value) in rows)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    key,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.additional3,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      value,
                      textAlign: TextAlign.right,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
