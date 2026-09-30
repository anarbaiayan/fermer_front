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
import '../widgets/finance_common.dart';
import '../widgets/finance_period_switcher.dart';

/// Вкладка «Сводка» (FP-510): прибыль за месяц, доход и расход, остатки
/// по счетам, долги и расходы по категориям.
///
/// Итоги месяца берутся из `GET /summary`. Остатки — из списка счетов:
/// там есть тип для иконки и видно, какие счета скрыты.
class FinanceSummaryTab extends ConsumerWidget {
  const FinanceSummaryTab({
    super.key,
    required this.onOpenIncome,
    required this.onOpenExpenses,
  });

  final VoidCallback onOpenIncome;

  /// Открыть вкладку «Расход». Фильтры сводка выставляет сама.
  final VoidCallback onOpenExpenses;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final period = FinancePeriod.month(ref.watch(financeMonthProvider));
    final summary = ref.watch(financeSummaryProvider(period));

    void openExpenses(ExpenseCategory? category) {
      ref.read(financeExpenseCategoryFilterProvider.notifier).state = category;
      // Сумма категории на сводке — по всем счетам.
      ref.read(financeExpenseAccountFilterProvider.notifier).state = null;
      onOpenExpenses();
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      children: [
        const FinanceMonthSwitcher(),
        const SizedBox(height: 16),
        summary.when(
          loading: () => const Padding(
            padding: EdgeInsets.symmetric(vertical: 32),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (error, _) => FinanceMessageCard.error(
            context,
            message: extractApiMessage(error),
            onRetry: () => ref.invalidate(financeSummaryProvider(period)),
          ),
          data: (data) => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _ResultCard(
                summary: data,
                period: period,
                onOpenIncome: onOpenIncome,
                onOpenExpenses: () => openExpenses(null),
              ),
              const SizedBox(height: 14),
              const _AddButtons(),
              const SizedBox(height: 24),
              const _Balances(),
              if (data.totalDebt.isPositive) ...[
                const SizedBox(height: 24),
                _Debts(summary: data),
              ],
              const SizedBox(height: 24),
              _Categories(
                summary: data,
                month: period.from,
                onOpen: openExpenses,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title, {this.trailing});

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.primary3,
              ),
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}

/// Прибыль за месяц крупно, под ней доход и расход с полосками.
class _ResultCard extends ConsumerWidget {
  const _ResultCard({
    required this.summary,
    required this.period,
    required this.onOpenIncome,
    required this.onOpenExpenses,
  });

  final FinanceSummary summary;
  final FinancePeriod period;
  final VoidCallback onOpenIncome;
  final VoidCallback onOpenExpenses;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final format = FinanceFormat.of(context);
    final profit = summary.profit;
    // Неоплаченное за месяц — из тех же продаж, что на вкладке «Доход».
    final sales = ref
        .watch(financeSalesProvider(SaleFilter.period(period)))
        .valueOrNull;
    final unpaid = sales == null
        ? null
        : Money.sum(sales.where((s) => !s.paid).map((s) => s.amount));
    final max = summary.totalIncome > summary.totalExpense
        ? summary.totalIncome
        : summary.totalExpense;

    return FinanceCard(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.financeProfitFor(format.monthName(period.from)).toUpperCase(),
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.7,
              color: AppColors.additional3,
            ),
          ),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              format.signedMoney(profit),
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w700,
                color: profit.isNegative ? AppColors.error : AppColors.primary1,
              ),
            ),
          ),
          const SizedBox(height: 14),
          _Ratio(
            share: _share(summary.totalIncome, max),
            color: AppColors.accent,
          ),
          const SizedBox(height: 6),
          _Ratio(
            share: _share(summary.totalExpense, max),
            color: FinanceColors.expenseBar,
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _Total(
                  label: l10n.financeTabIncome,
                  color: AppColors.accent,
                  amount: format.money(summary.totalIncome),
                  note: unpaid != null && unpaid.isPositive
                      ? l10n.financeUnpaidAmount(format.money(unpaid))
                      : null,
                  onTap: onOpenIncome,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _Total(
                  label: l10n.financeTabExpense,
                  color: FinanceColors.expenseBar,
                  amount: format.money(summary.totalExpense),
                  onTap: onOpenExpenses,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Доля для полоски. Только для рисования — не деньги.
  static double _share(Money value, Money max) =>
      max.isPositive ? value.tiyn / max.tiyn : 0;
}

class _Ratio extends StatelessWidget {
  const _Ratio({required this.share, required this.color});

  final double share;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(4),
      child: Container(
        height: 8,
        color: FinanceColors.fieldFill,
        alignment: Alignment.centerLeft,
        child: FractionallySizedBox(
          widthFactor: share.clamp(0, 1),
          heightFactor: 1,
          child: ColoredBox(color: color),
        ),
      ),
    );
  }
}

class _Total extends StatelessWidget {
  const _Total({
    required this.label,
    required this.color,
    required this.amount,
    required this.onTap,
    this.note,
  });

  final String label;
  final Color color;
  final String amount;
  final String? note;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _Dot(color: color, size: 8),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.additional3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              amount,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppColors.primary3,
              ),
            ),
          ),
          if (note != null)
            Text(
              note!,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: FinanceColors.dueText,
              ),
            ),
        ],
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

/// «+ Продажа» и «+ Расход» — записать сразу со сводки.
class _AddButtons extends StatelessWidget {
  const _AddButtons();

  @override
  Widget build(BuildContext context) {
    return FinanceQuickAddButtons(
      onAddSale: () => context.push('/finance/sales/new'),
      onAddExpense: () => context.push('/finance/expenses/new'),
    );
  }
}

/// Остатки по счетам и их сумма. Скрытый счёт виден внизу, пока на нём
/// есть деньги, и входит в итог — иначе итог меньше реальных денег.
class _Balances extends ConsumerWidget {
  const _Balances();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final format = FinanceFormat.of(context);
    final accounts = balanceAccounts(
      ref.watch(financeAccountsProvider).valueOrNull ?? [],
    );
    const amountStyle = TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.w700,
      color: AppColors.primary3,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionTitle(
          l10n.financeBalancesTitle,
          trailing: Text(
            format.money(Money.sum(accounts.map((a) => a.balance))),
            style: amountStyle,
          ),
        ),
        if (accounts.isEmpty)
          FinanceMessageCard(
            title: l10n.financeAccountsEmptyTitle,
            message: l10n.financeAccountsEmptyText,
          )
        else
          FinanceCardList(
            children: [
              for (final account in accounts)
                FinanceListRow(
                  leading: FinanceIconSquare.small(
                    icon: account.type.iconName,
                    color: account.active
                        ? AppColors.primary1
                        : AppColors.additional3,
                  ),
                  title: account.name,
                  subtitle: account.active
                      ? account.type.localizedLabel(l10n)
                      : l10n.financeAccountHidden,
                  trailing: Text(
                    format.money(account.balance),
                    style: amountStyle,
                  ),
                  onTap: () => context.push('/finance/accounts/${account.id}'),
                ),
            ],
          ),
      ],
    );
  }
}

/// Кто должен: сумма и просрочка из сводки, три самых просроченных
/// покупателя — из списка долгов. Пока бэкенд не отдаёт `/debts`,
/// карточка показывает только суммы.
class _Debts extends ConsumerWidget {
  const _Debts({required this.summary});

  final FinanceSummary summary;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final format = FinanceFormat.of(context);
    final today = ref.watch(financeTodayProvider);
    final debts = ref.watch(financeDebtsProvider).valueOrNull ?? const [];
    void open() => context.push('/finance/debts');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionTitle(
          l10n.financeDebtsTitle,
          trailing: TextButton(
            onPressed: open,
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primary1,
              minimumSize: const Size(0, 32),
              padding: const EdgeInsets.symmetric(horizontal: 4),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  l10n.financeFilterAll,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, size: 18),
              ],
            ),
          ),
        ),
        FinanceCard(
          color: FinanceColors.debtCardBackground,
          borderColor: FinanceColors.debtCardBorder,
          child: InkWell(
            onTap: open,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
                  // Метка просрочки справа, а на узком экране — под суммой.
                  child: Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    spacing: 12,
                    runSpacing: 8,
                    children: [
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.financeOwedToYou,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.additional3,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            format.money(summary.totalDebt),
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary3,
                            ),
                          ),
                        ],
                      ),
                      if (summary.overdueDebt.isPositive)
                        FinancePill(
                          label: l10n.financeOverdueAmount(
                            format.money(summary.overdueDebt),
                          ),
                          tone: FinancePillTone.overdue,
                        ),
                    ],
                  ),
                ),
                for (final debt in debts.take(3)) ...[
                  const Divider(height: 1, color: FinanceColors.debtCardBorder),
                  _DebtRow(debt: debt, today: today),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _DebtRow extends StatelessWidget {
  const _DebtRow({required this.debt, required this.today});

  final CounterpartyDebt debt;
  final DateTime today;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final format = FinanceFormat.of(context);
    final dueDates = debt.sales.map((s) => s.dueDate).nonNulls.toList()..sort();
    final String? note;
    final bool overdue = debt.overdueDays > 0;
    if (overdue) {
      note = l10n.financeDebtOverdueDays(debt.overdueDays);
    } else if (dueDates.isNotEmpty) {
      note = l10n.financeDebtDueUntil(format.dayMonth(dueDates.first));
    } else {
      note = null;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  debt.counterpartyName ?? l10n.financeNoBuyer,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary3,
                  ),
                ),
                if (note != null)
                  Text(
                    note,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: overdue ? FontWeight.w600 : FontWeight.w400,
                      color: overdue
                          ? FinanceColors.overdueText
                          : AppColors.additional3,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            format.money(debt.totalDebt),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppColors.primary3,
            ),
          ),
        ],
      ),
    );
  }
}

/// Расходы месяца по категориям: полоса долей и строки с процентом.
/// Строка «Всего» внизу — сумма категорий сходится с расходом (FP-510).
class _Categories extends StatelessWidget {
  const _Categories({
    required this.summary,
    required this.month,
    required this.onOpen,
  });

  final FinanceSummary summary;
  final DateTime month;
  final ValueChanged<ExpenseCategory> onOpen;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final format = FinanceFormat.of(context);
    final total = summary.totalExpense;
    final categories =
        summary.expensesByCategory.where((c) => c.amount.isPositive).toList()
          ..sort((a, b) {
            final byAmount = b.amount.compareTo(a.amount);
            return byAmount != 0
                ? byAmount
                : a.category.index.compareTo(b.category.index);
          });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionTitle(l10n.financeExpensesByCategory),
        if (!total.isPositive || categories.isEmpty)
          FinanceMessageCard(
            title: l10n.financeNoExpensesFor(format.monthName(month)),
          )
        else
          FinanceCard(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: SizedBox(
                    height: 12,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        for (var i = 0; i < categories.length; i++) ...[
                          if (i > 0) const SizedBox(width: 2),
                          Expanded(
                            flex: _permille(categories[i].amount, total),
                            child: ColoredBox(
                              color: categories[i].category.color,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                for (final item in categories) ...[
                  _CategoryRow(
                    color: item.category.color,
                    label: item.category.localizedLabel(l10n),
                    percent: '${_percent(item.amount, total)}%',
                    amount: format.money(item.amount),
                    onTap: () => onOpen(item.category),
                  ),
                  const Divider(height: 1, color: AppColors.additional2),
                ],
                _CategoryRow(
                  label: l10n.financeTotal,
                  amount: format.money(total),
                  bold: true,
                ),
              ],
            ),
          ),
      ],
    );
  }

  /// Доля в тысячных для ширины полосы; видна даже крошечная категория.
  static int _permille(Money part, Money total) {
    final value = (part.tiyn * 1000 / total.tiyn).round();
    return value < 1 ? 1 : value;
  }

  static int _percent(Money part, Money total) =>
      (part.tiyn * 100 / total.tiyn).round();
}

class _CategoryRow extends StatelessWidget {
  const _CategoryRow({
    required this.label,
    required this.amount,
    this.color,
    this.percent,
    this.onTap,
    this.bold = false,
  });

  final String label;
  final String amount;
  final Color? color;
  final String? percent;
  final VoidCallback? onTap;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            if (color != null) ...[
              _Dot(color: color!, size: 10),
              const SizedBox(width: 10),
            ],
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: bold ? FontWeight.w600 : FontWeight.w500,
                  color: AppColors.primary3,
                ),
              ),
            ),
            if (percent != null) ...[
              Text(
                percent!,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.additional3,
                ),
              ),
              const SizedBox(width: 12),
            ],
            ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 92),
              child: Text(
                amount,
                textAlign: TextAlign.right,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
