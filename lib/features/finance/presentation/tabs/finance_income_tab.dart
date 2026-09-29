import 'package:flutter/material.dart';
import 'package:frontend/core/localization/l10n_extension.dart';
import 'package:frontend/core/network/api_exceptions.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../application/finance_providers.dart';
import '../../domain/entities/finance_date.dart';
import '../../domain/entities/finance_entities.dart';
import '../../domain/entities/finance_inputs.dart';
import '../../domain/entities/money.dart';
import '../finance_format.dart';
import '../widgets/finance_chips.dart';
import '../widgets/finance_common.dart';
import '../widgets/finance_day_list.dart';
import '../widgets/finance_pay_sheet.dart';
import '../widgets/finance_period_switcher.dart';

/// Вкладка «Доход»: продажи месяца по дням со статусом оплаты. Оплату
/// можно отметить прямо в строке (FP-502).
///
/// Итоги над списком — по всем продажам месяца, фильтр только прячет
/// строки: «Продано на» не должно зависеть от выбранного чипа.
class FinanceIncomeTab extends ConsumerWidget {
  const FinanceIncomeTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final period = FinancePeriod.month(ref.watch(financeMonthProvider));
    final filter = ref.watch(financeIncomeFilterProvider);
    final today = ref.watch(financeTodayProvider);
    final query = SaleFilter.period(period);
    final sales = ref.watch(financeSalesProvider(query));

    return ListView(
      // Снизу место под плавающую кнопку.
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 96),
      children: [
        const FinanceMonthSwitcher(),
        const SizedBox(height: 16),
        const _Filters(),
        const SizedBox(height: 14),
        sales.when(
          loading: () => const Padding(
            padding: EdgeInsets.symmetric(vertical: 32),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (error, _) => FinanceMessageCard.error(
            context,
            message: extractApiMessage(error),
            onRetry: () => ref.invalidate(financeSalesProvider(query)),
          ),
          data: (all) {
            final visible = all.where((s) => filter.matches(s, today)).toList();
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _SoldLine(
                  total: Money.sum(all.map((sale) => sale.amount)),
                  unpaid: Money.sum(
                    all.where((sale) => !sale.paid).map((sale) => sale.amount),
                  ),
                ),
                const SizedBox(height: 12),
                if (visible.isEmpty)
                  FinanceMessageCard(
                    title: l10n.financeSalesEmptyTitle,
                    message: l10n.financeSalesEmptyText,
                  )
                else
                  FinanceDayList<Sale>(
                    items: visible,
                    dateOf: (sale) => sale.saleDate,
                    rowBuilder: (sale) => FinanceSaleRow(
                      sale: sale,
                      today: today,
                      onTap: () => context.push(
                        '/finance/sales/${sale.id}',
                        extra: sale,
                      ),
                      onPay: () => showSalePaySheet(context, sale),
                    ),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}

/// Шторка оплаты для продажи из списка.
Future<void> showSalePaySheet(BuildContext context, Sale sale) {
  final l10n = context.l10n;
  final format = FinanceFormat.of(context);
  final caption = [
    sale.counterpartyName ?? l10n.financeNoBuyer,
    '${sale.productName}, ${format.quantity(sale.quantity)} '
        '${sale.unit.localizedLabel(l10n)}',
    l10n.financeSaleOfDate(format.date(sale.saleDate)),
  ].join(' · ');
  return showFinancePaySheet(
    context,
    saleId: sale.id,
    amount: sale.amount,
    saleDate: sale.saleDate,
    caption: caption,
    aboveFab: true,
  );
}

class _Filters extends ConsumerWidget {
  const _Filters();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final selected = ref.watch(financeIncomeFilterProvider);
    final labels = {
      IncomeFilter.all: l10n.financeFilterAll,
      IncomeFilter.paid: l10n.financeIncomeFilterPaid,
      IncomeFilter.debt: l10n.financeIncomeFilterDebt,
      IncomeFilter.overdue: l10n.financeIncomeFilterOverdue,
    };
    return FinanceChipRow(
      children: [
        for (final entry in labels.entries)
          FinanceChip(
            label: entry.value,
            selected: entry.key == selected,
            onTap: () => ref.read(financeIncomeFilterProvider.notifier).state =
                entry.key,
          ),
      ],
    );
  }
}

/// «Продано на 666 400 ₸ · не оплачено 351 000 ₸».
class _SoldLine extends StatelessWidget {
  const _SoldLine({required this.total, required this.unpaid});

  final Money total;
  final Money unpaid;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final format = FinanceFormat.of(context);
    const muted = TextStyle(fontSize: 13, color: AppColors.additional3);
    // По краям одной строки, а на узком экране — друг под другом.
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.end,
      spacing: 12,
      runSpacing: 2,
      children: [
        Text.rich(
          TextSpan(
            style: muted,
            children: [
              TextSpan(text: '${l10n.financeSoldLabel} '),
              TextSpan(
                text: format.money(total),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary3,
                ),
              ),
            ],
          ),
        ),
        if (unpaid.isPositive)
          Padding(
            padding: const EdgeInsets.only(bottom: 1),
            child: Text(
              l10n.financeUnpaidAmount(format.money(unpaid)),
              style: muted,
            ),
          ),
      ],
    );
  }
}

/// Строка продажи: товар и количество, покупатель и цена, сумма и статус.
/// У неоплаченной — «Получить оплату» прямо в строке.
class FinanceSaleRow extends StatelessWidget {
  const FinanceSaleRow({
    super.key,
    required this.sale,
    required this.today,
    this.onTap,
    this.onPay,
  });

  final Sale sale;
  final DateTime today;
  final VoidCallback? onTap;
  final VoidCallback? onPay;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final format = FinanceFormat.of(context);
    final unit = sale.unit.localizedLabel(l10n);
    final comment = sale.comment;
    return FinanceListRow(
      title: '${sale.productName} · ${format.quantity(sale.quantity)} $unit',
      subtitle: [
        sale.counterpartyName ?? l10n.financeNoBuyer,
        '${format.money(sale.pricePerUnit)}/$unit',
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
      trailing: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Text(
            format.money(sale.amount),
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.primary3,
            ),
          ),
          const SizedBox(height: 4),
          SaleStatusPill(sale: sale, today: today),
          if (!sale.paid && onPay != null)
            TextButton(
              onPressed: onPay,
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary1,
                minimumSize: const Size(0, 32),
                padding: const EdgeInsets.symmetric(horizontal: 4),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                l10n.financeGetPayment,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
      onTap: onTap,
    );
  }
}
