import 'package:flutter/material.dart';
import 'package:frontend/core/icons/app_icons.dart';
import 'package:frontend/core/localization/l10n_extension.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/widgets/app_primary_button.dart';
import 'package:frontend/features/cattle_events/application/planned_events_providers.dart';
import 'package:frontend/features/finance/application/finance_providers.dart';
import 'package:frontend/features/finance/domain/entities/finance_date.dart';
import 'package:frontend/features/finance/domain/entities/finance_entities.dart';
import 'package:frontend/features/finance/domain/entities/finance_inputs.dart';
import 'package:frontend/features/finance/domain/entities/money.dart';
import 'package:frontend/features/finance/presentation/finance_format.dart';
import 'package:frontend/features/finance/presentation/finance_styles.dart';
import 'package:frontend/features/finance/presentation/widgets/finance_common.dart';
import 'package:frontend/features/lactation/application/lactation_providers.dart';
import 'package:frontend/features/lactation/data/models/lactation_daily_summary_dto.dart';
import 'package:frontend/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

/// Блок «Сегодня» над главной (FP-505): надой, продажи и расходы за день,
/// деньги на счетах, долги и дела. Причина открывать приложение каждый
/// день.
///
/// Если за сегодня ничего нет, строки не пропадают, а зовут записать
/// (ТЗ: «показываются поля ввода, а не пустой экран»). Надой читается
/// из `GET /lactations/user/daily-summary` (вопрос В4: контракт по ТЗ).
class TodaySection extends ConsumerWidget {
  const TodaySection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).languageCode;
    final today = ref.watch(financeTodayProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              l10n.todayTitle,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColors.primary3,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                DateFormat('EEEE, d MMMM', locale).format(today),
                textAlign: TextAlign.right,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.additional3,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        const _DayCard(),
        const SizedBox(height: 24),
        const _Money(),
        const _Debts(),
        const SizedBox(height: 24),
        const _Tasks(),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, this.link, this.onLink});

  final String title;
  final String? link;
  final VoidCallback? onLink;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
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
          if (link != null)
            TextButton(
              onPressed: onLink,
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
                    link!,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded, size: 18),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// Маленькая кнопка в строке-приглашении: «+ Продажа».
class _RowButton extends StatelessWidget {
  const _RowButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.primary1,
        side: const BorderSide(color: AppColors.primary1, width: 1.5),
        minimumSize: const Size(0, 36),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        shape: const StadiumBorder(),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
    );
  }
}

const _amountStyle = TextStyle(
  fontSize: 15,
  fontWeight: FontWeight.w700,
  color: AppColors.primary3,
);

/// Надой, продажи и расходы за сегодня.
class _DayCard extends ConsumerWidget {
  const _DayCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final format = FinanceFormat.of(context);
    final today = ref.watch(financeTodayProvider);
    final sales = ref
        .watch(financeSalesProvider(SaleFilter(from: today, to: today)))
        .valueOrNull;
    final expenses = ref
        .watch(financeExpensesProvider(ExpenseFilter(from: today, to: today)))
        .valueOrNull;
    final hasRecords =
        (sales?.isNotEmpty ?? false) || (expenses?.isNotEmpty ?? false);

    final Widget salesRow;
    if (sales != null && sales.isNotEmpty) {
      salesRow = FinanceListRow(
        leading: const FinanceIconSquare(
          icon: 'cart_plain',
          color: AppColors.accent,
        ),
        title: l10n.todaySold,
        subtitle: sales
            .map(
              (s) => [
                s.counterpartyName ?? l10n.financeNoBuyer,
                '${s.productName.toLowerCase()} '
                    '${format.quantity(s.quantity)} '
                    '${s.unit.localizedLabel(l10n)}',
              ].join(' · '),
            )
            .join(', '),
        trailing: Text(
          format.money(Money.sum(sales.map((s) => s.amount))),
          style: _amountStyle,
        ),
        onTap: () => context.push('/finance?tab=income'),
      );
    } else {
      salesRow = FinanceListRow(
        leading: const FinanceIconSquare(
          icon: 'cart_plain',
          color: AppColors.accent,
        ),
        title: l10n.todayNoSales,
        subtitle: l10n.todayNoSalesHint,
        trailing: _RowButton(
          label: '+ ${l10n.financeAddSale}',
          onPressed: () => context.push('/finance/sales/new'),
        ),
      );
    }

    final Widget expensesRow;
    if (expenses != null && expenses.isNotEmpty) {
      expensesRow = FinanceListRow(
        leading: const FinanceIconSquare(
          icon: 'money_plain',
          color: AppColors.primary2,
        ),
        title: l10n.financeReportExpense,
        subtitle: expenses.map((e) => e.name).join(', '),
        trailing: Text(
          format.money(-Money.sum(expenses.map((e) => e.amount))),
          style: _amountStyle,
        ),
        onTap: () => context.push('/finance?tab=expense'),
      );
    } else {
      expensesRow = FinanceListRow(
        leading: const FinanceIconSquare(
          icon: 'money_plain',
          color: AppColors.primary2,
        ),
        title: l10n.todayNoExpenses,
        subtitle: l10n.todayNoExpensesHint,
        trailing: _RowButton(
          label: '+ ${l10n.financeAddExpense}',
          onPressed: () => context.push('/finance/expenses/new'),
        ),
      );
    }

    return FinanceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _MilkRow(),
          const Divider(height: 1, color: AppColors.additional2),
          salesRow,
          const Divider(height: 1, color: AppColors.additional2),
          expensesRow,
          // Кнопки внизу, когда строки заняты записями.
          if (hasRecords) ...[
            const Divider(height: 1, color: AppColors.additional2),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
              child: FinanceQuickAddButtons(
                onAddSale: () => context.push('/finance/sales/new'),
                onAddExpense: () => context.push('/finance/expenses/new'),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Надой за сегодня. Нет записи — зовём записать надой группы.
class _MilkRow extends ConsumerWidget {
  const _MilkRow();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).languageCode;
    final liters = NumberFormat('#,##0.#', locale);
    final milk = ref.watch(lactationDailySummaryProvider);
    const icon = FinanceIconSquare(
      icon: 'lactation',
      color: FinanceColors.blue,
    );

    final summary = milk.valueOrNull;
    if (summary == null) {
      if (milk.hasError) {
        return FinanceListRow(
          leading: icon,
          title: l10n.todayMilk,
          subtitle: l10n.todayMilkError,
          onTap: () => ref.invalidate(lactationDailySummaryProvider),
        );
      }
      return FinanceListRow(
        leading: icon,
        title: l10n.todayMilk,
        trailing: const SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    if (summary.totalLiters <= 0) {
      return FinanceListRow(
        leading: icon,
        title: l10n.todayMilkEmpty,
        subtitle: l10n.todayMilkEmptyHint,
        trailing: _RowButton(
          label: l10n.todayMilkRecord,
          onPressed: () => context.push('/lactation/bulk/add'),
        ),
      );
    }

    return FinanceListRow(
      leading: icon,
      title: l10n.todayMilk,
      subtitle: _milkNote(l10n, liters, summary),
      trailing: Text(
        l10n.todayMilkLiters(liters.format(summary.totalLiters)),
        style: _amountStyle,
      ),
      onTap: () => context.go('/lactation'),
    );
  }

  /// «утро 248 л · вечер 238 л», если доили по отдельности, иначе число
  /// коров.
  static String _milkNote(
    AppLocalizations l10n,
    NumberFormat liters,
    LactationDailySummaryDto summary,
  ) {
    double sum(double? Function(LactationDailySummaryDetailDto) pick) =>
        summary.details.fold(0, (total, d) => total + (pick(d) ?? 0));
    final morning = sum((d) => d.morningLiters);
    final evening = sum((d) => d.eveningLiters);
    if (morning > 0 || evening > 0) {
      return l10n.todayMilkSessions(
        l10n.todayMilkLiters(liters.format(morning)),
        l10n.todayMilkLiters(liters.format(evening)),
      );
    }
    return l10n.todayMilkCows(summary.cowCount);
  }
}

/// Деньги: всего на счетах и лента счетов.
class _Money extends ConsumerWidget {
  const _Money();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final format = FinanceFormat.of(context);
    final accounts = ref.watch(financeAccountsProvider).valueOrNull;
    final active = accounts?.where((a) => a.active).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionHeader(
          title: l10n.todayMoney,
          link: l10n.financeTitle,
          onLink: () => context.push('/finance'),
        ),
        if (active == null)
          const SizedBox(height: 72)
        else if (active.isEmpty)
          // Первый вход в «Финансы» ещё не пройден.
          FinanceCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  l10n.todaySetUpFinance,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.primary3,
                  ),
                ),
                const SizedBox(height: 12),
                AppPrimaryButton(
                  text: l10n.financeOnboardingStart,
                  height: 40,
                  onPressed: () => context.push('/finance'),
                ),
              ],
            ),
          )
        else
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            clipBehavior: Clip.none,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _AccountTile(
                  label: l10n.todayTotalOnAccounts,
                  amount: format.money(Money.sum(active.map((a) => a.balance))),
                  highlighted: true,
                  onTap: () => context.push('/finance'),
                ),
                for (final account in active) ...[
                  const SizedBox(width: 10),
                  _AccountTile(
                    label: account.name,
                    icon: account.type.iconName,
                    amount: format.money(account.balance),
                    onTap: () => context.push('/finance/settings'),
                  ),
                ],
              ],
            ),
          ),
      ],
    );
  }
}

class _AccountTile extends StatelessWidget {
  const _AccountTile({
    required this.label,
    required this.amount,
    required this.onTap,
    this.icon,
    this.highlighted = false,
  });

  final String label;
  final String amount;
  final String? icon;
  final bool highlighted;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final foreground = highlighted ? Colors.white : AppColors.primary3;
    final muted = highlighted ? const Color(0xFFCFE3D6) : AppColors.additional3;
    return Material(
      color: highlighted ? AppColors.primary1 : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: highlighted ? AppColors.primary1 : AppColors.additional2,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 132),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (icon != null) ...[
                      AppIcons.svg(icon!, size: 16, color: muted),
                      const SizedBox(width: 6),
                    ],
                    Text(label, style: TextStyle(fontSize: 12, color: muted)),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  amount,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: foreground,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Кто должен. Карточка только когда должны; красное — только при
/// просрочке. Суммы — из сводки, самый просроченный — из списка долгов.
class _Debts extends ConsumerWidget {
  const _Debts();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final format = FinanceFormat.of(context);
    final today = ref.watch(financeTodayProvider);
    final summary = ref
        .watch(financeSummaryProvider(FinancePeriod.month(today)))
        .valueOrNull;
    if (summary == null || !summary.totalDebt.isPositive) {
      return const SizedBox.shrink();
    }
    final debts = ref.watch(financeDebtsProvider).valueOrNull ?? const [];
    final worst = debts
        .where((d) => d.overdueDays > 0)
        .fold<CounterpartyDebt?>(
          null,
          (max, d) => max == null || d.overdueDays > max.overdueDays ? d : max,
        );

    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: FinanceCard(
        color: FinanceColors.debtCardBackground,
        borderColor: FinanceColors.debtCardBorder,
        child: InkWell(
          onTap: () => context.push('/finance/debts'),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
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
              if (worst != null) ...[
                const Divider(height: 1, color: FinanceColors.debtCardBorder),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.error_outline_rounded,
                        size: 22,
                        color: FinanceColors.overdueText,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              worst.counterpartyName ?? l10n.financeNoBuyer,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary3,
                              ),
                            ),
                            Text(
                              [
                                l10n.financeDebtOverdueDays(worst.overdueDays),
                                format.money(worst.overdueAmountOn(today)),
                              ].join(' · '),
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.additional3,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right_rounded,
                        size: 20,
                        color: AppColors.additional3,
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Дела на сегодня и просроченные — из запланированных событий.
class _Tasks extends ConsumerWidget {
  const _Tasks();

  static const _shown = 3;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final events = ref.watch(plannedEventsProvider('PENDING'));
    // Ошибку показывает раздел «События»; здесь блок просто не мешает.
    if (events.hasError && !events.hasValue) return const SizedBox.shrink();
    final due = (events.valueOrNull ?? const [])
        .where((e) => e.daysUntil <= 0)
        .take(_shown)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionHeader(
          title: l10n.todayTasks,
          link: l10n.financeFilterAll,
          onLink: () => context.go('/events'),
        ),
        if (!events.hasValue)
          const SizedBox(height: 56)
        else if (due.isEmpty)
          FinanceCard(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Text(
              l10n.todayNoTasks,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.additional3,
              ),
            ),
          )
        else
          FinanceCardList(
            children: [
              for (final event in due)
                FinanceListRow(
                  leading: const FinanceIconSquare.small(
                    icon: 'events',
                    color: AppColors.primary1,
                  ),
                  title: event.title.isEmpty ? event.eventType : event.title,
                  subtitle: [
                    event.cattleName,
                    event.cattleTagNumber,
                  ].where((part) => part.isNotEmpty && part != '-').join(' · '),
                  showChevron: true,
                  onTap: () => context.go('/events'),
                ),
            ],
          ),
      ],
    );
  }
}
