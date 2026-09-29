import 'package:flutter/material.dart';
import 'package:frontend/core/localization/l10n_extension.dart';
import 'package:frontend/core/network/api_exceptions.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../application/finance_providers.dart';
import '../../domain/entities/finance_entities.dart';
import '../../domain/entities/finance_inputs.dart';
import '../../domain/entities/money.dart';
import '../finance_contact.dart';
import '../finance_format.dart';
import '../finance_phone.dart';
import '../finance_styles.dart';
import '../widgets/finance_common.dart';
import '../widgets/finance_page.dart';
import '../widgets/finance_pay_sheet.dart';

/// «Долги» (FP-503): кто сколько должен, самые просроченные сверху.
/// Покупатель раскрывается: его продажи с «Получить», звонок и напоминание.
///
/// Список — `GET /debts` по ТЗ. Товар и количество в нём не приходят,
/// поэтому берутся из неоплаченных продаж, если те загрузились.
/// [counterpartyId] — из пуша о просрочке: этот покупатель раскрыт.
class FinanceDebtsScreen extends ConsumerStatefulWidget {
  const FinanceDebtsScreen({super.key, this.counterpartyId});

  final int? counterpartyId;

  @override
  ConsumerState<FinanceDebtsScreen> createState() => _FinanceDebtsScreenState();
}

class _FinanceDebtsScreenState extends ConsumerState<FinanceDebtsScreen> {
  static const _unpaid = SaleFilter(paid: false);

  /// Раскрытые покупатели. `null` в множестве — продажи без покупателя.
  Set<int?>? _expanded;
  final _targetKey = GlobalKey();

  void _toggle(int? id) {
    setState(() {
      final expanded = _expanded ??= {};
      if (!expanded.remove(id)) expanded.add(id);
    });
  }

  /// Первый раз раскрываем покупателя из пуша или самого просроченного.
  Set<int?> _initialExpanded(List<CounterpartyDebt> debts) {
    final target = widget.counterpartyId;
    if (target != null && debts.any((d) => d.counterpartyId == target)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final context = _targetKey.currentContext;
        if (context != null) {
          Scrollable.ensureVisible(
            context,
            alignment: 0.1,
            duration: const Duration(milliseconds: 250),
          );
        }
      });
      return {target};
    }
    return debts.isEmpty ? {} : {debts.first.counterpartyId};
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final debtsAsync = ref.watch(financeDebtsProvider);
    final today = ref.watch(financeTodayProvider);

    final List<Widget> children;
    final debts = debtsAsync.valueOrNull;
    if (debts == null) {
      children = [
        if (debtsAsync.hasError)
          FinanceMessageCard.error(
            context,
            message: extractApiMessage(debtsAsync.error!),
            onRetry: () => ref.invalidate(financeDebtsProvider),
          )
        else
          const Center(child: CircularProgressIndicator()),
      ];
    } else if (debts.isEmpty) {
      children = [
        FinanceMessageCard(
          icon: const Icon(
            Icons.check_circle_outline_rounded,
            size: 32,
            color: FinanceColors.paidText,
          ),
          title: l10n.financeNoDebtsTitle,
          message: l10n.financeNoDebtsText,
        ),
      ];
    } else {
      final expanded = _expanded ??= _initialExpanded(debts);
      final sales = {
        for (final sale
            in ref.watch(financeSalesProvider(_unpaid)).valueOrNull ??
                const <Sale>[])
          sale.id: sale,
      };
      children = [
        _Totals(
          total: Money.sum(debts.map((d) => d.totalDebt)),
          overdue: Money.sum(debts.map((d) => d.overdueAmountOn(today))),
        ),
        for (final debt in debts)
          _DebtCard(
            key: debt.counterpartyId == widget.counterpartyId
                ? _targetKey
                : null,
            debt: debt,
            sales: sales,
            today: today,
            expanded: expanded.contains(debt.counterpartyId),
            onToggle: () => _toggle(debt.counterpartyId),
          ),
      ];
    }

    return FinancePage(
      title: l10n.financeDebtsTitle,
      spacing: 12,
      children: children,
    );
  }
}

class _Totals extends StatelessWidget {
  const _Totals({required this.total, required this.overdue});

  final Money total;
  final Money overdue;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final format = FinanceFormat.of(context);
    Widget cell(String label, Money value, Color color) => Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 13, color: AppColors.additional3),
          ),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              format.money(value),
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );

    return FinanceCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          cell(l10n.financeDebtsTotal, total, AppColors.primary3),
          const SizedBox(width: 12),
          cell(
            l10n.financeIncomeFilterOverdue,
            overdue,
            overdue.isPositive
                ? FinanceColors.overdueText
                : AppColors.additional3,
          ),
        ],
      ),
    );
  }
}

class _DebtCard extends ConsumerWidget {
  const _DebtCard({
    super.key,
    required this.debt,
    required this.sales,
    required this.today,
    required this.expanded,
    required this.onToggle,
  });

  final CounterpartyDebt debt;

  /// Неоплаченные продажи по id — для товара и количества.
  final Map<int, Sale> sales;
  final DateTime today;
  final bool expanded;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final format = FinanceFormat.of(context);
    final name = debt.counterpartyName ?? l10n.financeNoBuyer;
    final phone = debt.phone;
    final dueDates = debt.sales.map((s) => s.dueDate).nonNulls.toList()..sort();

    final Widget? pill = debt.overdueDays > 0
        ? FinancePill(
            label: l10n.financeSaleStatusOverdue(debt.overdueDays),
            tone: FinancePillTone.overdue,
          )
        : dueDates.isEmpty
        ? null
        : FinancePill(
            label: l10n.financeDueUntilPill(format.dayMonth(dueDates.first)),
            tone: FinancePillTone.due,
          );

    return FinanceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Semantics(
            button: true,
            expanded: expanded,
            child: InkWell(
              onTap: onToggle,
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            name,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary3,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          format.money(debt.totalDebt),
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary3,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            phone == null
                                ? l10n.financeNoPhoneFull
                                : FinancePhone.format(phone),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.additional3,
                            ),
                          ),
                        ),
                        if (pill != null) ...[const SizedBox(width: 8), pill],
                        const SizedBox(width: 4),
                        AnimatedRotation(
                          turns: expanded ? 0.5 : 0,
                          duration: const Duration(milliseconds: 150),
                          child: const Icon(
                            Icons.expand_more_rounded,
                            size: 20,
                            color: AppColors.additional3,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (expanded) ...[
            Container(
              decoration: const BoxDecoration(
                color: Color(0xFFFAFAF8),
                border: Border(top: BorderSide(color: AppColors.additional2)),
              ),
              child: Column(
                children: [
                  for (var i = 0; i < debt.sales.length; i++) ...[
                    if (i > 0)
                      const Divider(
                        height: 1,
                        indent: 14,
                        endIndent: 14,
                        color: AppColors.additional2,
                      ),
                    _DebtSaleRow(
                      debtSale: debt.sales[i],
                      sale: sales[debt.sales[i].id],
                      buyerName: name,
                      today: today,
                    ),
                  ],
                ],
              ),
            ),
            if (phone != null)
              Container(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                decoration: const BoxDecoration(
                  border: Border(top: BorderSide(color: AppColors.additional2)),
                ),
                child: _ContactButtons(phone: phone, debt: debt),
              ),
          ],
        ],
      ),
    );
  }
}

class _DebtSaleRow extends StatelessWidget {
  const _DebtSaleRow({
    required this.debtSale,
    required this.sale,
    required this.buyerName,
    required this.today,
  });

  final DebtSale debtSale;
  final Sale? sale;
  final String buyerName;
  final DateTime today;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final format = FinanceFormat.of(context);
    final sale = this.sale;
    final product = sale == null
        ? null
        : '${sale.productName}, ${format.quantity(sale.quantity)} '
              '${sale.unit.localizedLabel(l10n)}';
    final due = debtSale.dueDate;
    final overdue = debtSale.isOverdueOn(today);

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 10, 8, 10),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  [
                    format.dayMonth(debtSale.saleDate),
                    product ?? l10n.financeSaleTitle,
                  ].join(' · '),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary3,
                  ),
                ),
                if (due != null)
                  Text(
                    overdue
                        ? l10n.financeSaleDueWas(format.dayMonth(due))
                        : l10n.financeSalePayUntil(format.dayMonth(due)),
                    style: TextStyle(
                      fontSize: 13,
                      color: overdue
                          ? FinanceColors.overdueText
                          : AppColors.additional3,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                format.money(debtSale.amount),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary3,
                ),
              ),
              TextButton(
                onPressed: () => showFinancePaySheet(
                  context,
                  saleId: debtSale.id,
                  amount: debtSale.amount,
                  saleDate: debtSale.saleDate,
                  caption: [
                    buyerName,
                    ?product,
                    l10n.financeSaleOfDate(format.date(debtSale.saleDate)),
                  ].join(' · '),
                ),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary1,
                  minimumSize: const Size(0, 32),
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  l10n.financeGetPaymentShort,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// «Позвонить» и «Напомнить» в WhatsApp с суммой долга.
class _ContactButtons extends ConsumerWidget {
  const _ContactButtons({required this.phone, required this.debt});

  final String phone;
  final CounterpartyDebt debt;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final contact = FinanceContact(ref.watch(financeUrlLauncherProvider));

    Future<void> run(Future<bool> action, String error) async {
      final messenger = ScaffoldMessenger.of(context);
      if (!await action) showFinanceMessage(messenger, error);
    }

    return Row(
      children: [
        Expanded(
          child: _ContactButton(
            icon: Icons.phone_outlined,
            label: l10n.financeCall,
            onPressed: () => run(contact.call(phone), l10n.financeCallError),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _ContactButton(
            icon: Icons.chat_outlined,
            label: l10n.financeRemind,
            onPressed: () => run(
              contact.whatsApp(
                phone,
                l10n.financeDebtReminderText(
                  FinanceFormat.of(context).money(debt.totalDebt),
                ),
              ),
              l10n.supportOpenWhatsappError,
            ),
          ),
        ),
      ],
    );
  }
}

class _ContactButton extends StatelessWidget {
  const _ContactButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 18),
        label: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            label,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary1,
          side: const BorderSide(color: AppColors.primary1, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    );
  }
}
