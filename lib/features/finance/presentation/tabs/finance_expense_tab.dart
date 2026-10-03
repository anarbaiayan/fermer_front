import 'package:flutter/material.dart';
import 'package:frontend/core/localization/l10n_extension.dart';
import 'package:frontend/core/network/api_exceptions.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../application/finance_providers.dart';
import '../../domain/entities/finance_date.dart';
import '../../domain/entities/finance_entities.dart';
import '../../domain/entities/finance_enums.dart';
import '../../domain/entities/finance_inputs.dart';
import '../../domain/entities/money.dart';
import '../finance_format.dart';
import '../finance_styles.dart';
import '../widgets/finance_chips.dart';
import '../widgets/finance_common.dart';
import '../widgets/finance_day_list.dart';
import '../widgets/finance_period_switcher.dart';
import '../widgets/finance_sheet.dart';

/// Вкладка «Расход»: расходы месяца по дням с фильтрами по счёту и
/// категории. Комментарий виден прямо в списке (FP-509).
class FinanceExpenseTab extends ConsumerWidget {
  const FinanceExpenseTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final period = FinancePeriod.month(ref.watch(financeMonthProvider));
    final category = ref.watch(financeExpenseCategoryFilterProvider);
    final accountId = ref.watch(financeExpenseAccountFilterProvider);
    final filter = ExpenseFilter(
      from: period.from,
      to: period.to,
      category: category,
      accountId: accountId,
    );
    final expenses = ref.watch(financeExpensesProvider(filter));

    return ListView(
      // Снизу место под плавающую кнопку.
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 96),
      children: [
        const FinanceMonthSwitcher(),
        const SizedBox(height: 16),
        const _Filters(),
        const SizedBox(height: 14),
        expenses.when(
          loading: () => const Padding(
            padding: EdgeInsets.symmetric(vertical: 32),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (error, _) => FinanceMessageCard.error(
            context,
            message: extractApiMessage(error),
            onRetry: () => ref.invalidate(financeExpensesProvider(filter)),
          ),
          data: (list) => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _SpentLine(
                total: Money.sum(list.map((expense) => expense.amount)),
                count: list.length,
              ),
              const SizedBox(height: 12),
              if (list.isEmpty)
                FinanceMessageCard(
                  title: l10n.financeExpensesEmptyTitle,
                  message: l10n.financeExpensesEmptyText,
                )
              else
                FinanceDayList<Expense>(
                  items: list,
                  dateOf: (expense) => expense.expenseDate,
                  rowBuilder: (expense) => FinanceExpenseRow(
                    expense: expense,
                    onTap: () => context.push(
                      '/finance/expenses/${expense.id}',
                      extra: expense,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Filters extends ConsumerWidget {
  const _Filters();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final category = ref.watch(financeExpenseCategoryFilterProvider);
    final accountId = ref.watch(financeExpenseAccountFilterProvider);
    final accounts = ref.watch(financeAccountsProvider).valueOrNull ?? [];
    final account = accounts.where((a) => a.id == accountId).firstOrNull;

    Future<void> pickAccount() async {
      // Скрытые счета тоже: по ним есть история.
      final picked = await showFinancePickerSheet<int?>(
        context: context,
        title: l10n.financeAccountTitle,
        options: {
          null: l10n.financeAllAccounts,
          for (final account in accounts) account.id: account.name,
        },
        selected: accountId,
      );
      if (picked == null || !context.mounted) return;
      ref.read(financeExpenseAccountFilterProvider.notifier).state = picked.$1;
    }

    void setCategory(ExpenseCategory? value) =>
        ref.read(financeExpenseCategoryFilterProvider.notifier).state = value;

    return FinanceChipRow(
      children: [
        FinanceChip(
          label: account?.name ?? l10n.financeAllAccounts,
          icon: account?.type.iconName ?? AccountType.cash.iconName,
          trailingIcon: Icons.expand_more_rounded,
          onTap: pickAccount,
        ),
        FinanceChip(
          label: l10n.financeFilterAll,
          selected: category == null,
          onTap: () => setCategory(null),
        ),
        for (final value in ExpenseCategory.values)
          FinanceChip(
            label: value.localizedLabel(l10n),
            selected: category == value,
            onTap: () => setCategory(value),
          ),
      ],
    );
  }
}

class _SpentLine extends StatelessWidget {
  const _SpentLine({required this.total, required this.count});

  final Money total;
  final int count;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    const muted = TextStyle(fontSize: 13, color: AppColors.additional3);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Expanded(
          child: Text.rich(
            TextSpan(
              style: muted,
              children: [
                TextSpan(text: '${l10n.financeSpentLabel} '),
                TextSpan(
                  text: FinanceFormat.of(context).money(total),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary3,
                  ),
                ),
              ],
            ),
          ),
        ),
        Text(l10n.financeRecordsCount(count), style: muted),
      ],
    );
  }
}

/// Строка расхода: категория, на что, счёт, комментарий и сумма с минусом.
/// Сумма тёмная: красный цвет в модуле только у просрочек.
class FinanceExpenseRow extends StatelessWidget {
  const FinanceExpenseRow({super.key, required this.expense, this.onTap});

  final Expense expense;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final category = expense.category;
    final comment = expense.comment;
    return FinanceListRow(
      leading: FinanceIconSquare.small(
        icon: category.iconName,
        color: category.color,
      ),
      title: expense.name,
      subtitle: [
        category.localizedLabel(l10n),
        if (expense.accountName != null) expense.accountName!,
      ].join(' · '),
      footer: comment == null
          ? null
          : Text(
              comment,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 13,
                fontStyle: FontStyle.italic,
                color: AppColors.additional3,
              ),
            ),
      trailing: Text(
        FinanceFormat.of(context).money(-expense.amount),
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: AppColors.primary3,
        ),
      ),
      onTap: onTap,
    );
  }
}
