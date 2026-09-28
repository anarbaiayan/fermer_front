import 'package:flutter/material.dart';
import 'package:frontend/core/localization/l10n_extension.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../application/finance_providers.dart';
import '../../domain/entities/finance_date.dart';
import '../finance_format.dart';

/// Переключатель общего месяца вкладок «Сводка», «Доход», «Расход».
class FinanceMonthSwitcher extends ConsumerWidget {
  const FinanceMonthSwitcher({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FinancePeriodSwitcher(
      month: ref.watch(financeMonthProvider),
      maxMonth: ref.watch(financeTodayProvider),
      onChanged: (month) =>
          ref.read(financeMonthProvider.notifier).state = month,
    );
  }
}

/// «‹ Сентябрь 2026 ›». Будущие месяцы недоступны.
class FinancePeriodSwitcher extends StatelessWidget {
  const FinancePeriodSwitcher({
    super.key,
    required this.month,
    required this.maxMonth,
    required this.onChanged,
  });

  /// Первый день выбранного месяца.
  final DateTime month;

  /// Последний доступный месяц — текущий.
  final DateTime maxMonth;
  final ValueChanged<DateTime> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final canGoForward = monthStart(month).isBefore(monthStart(maxMonth));

    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.additional2),
      ),
      child: Row(
        children: [
          IconButton(
            tooltip: l10n.financePrevMonth,
            visualDensity: VisualDensity.compact,
            icon: const Icon(Icons.chevron_left_rounded),
            color: AppColors.primary3,
            onPressed: () => onChanged(addMonths(monthStart(month), -1)),
          ),
          Expanded(
            child: Text(
              FinanceFormat.of(context).month(month),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.primary3,
              ),
            ),
          ),
          IconButton(
            tooltip: l10n.financeNextMonth,
            visualDensity: VisualDensity.compact,
            icon: const Icon(Icons.chevron_right_rounded),
            color: AppColors.primary3,
            disabledColor: AppColors.additional2,
            onPressed: canGoForward
                ? () => onChanged(addMonths(monthStart(month), 1))
                : null,
          ),
        ],
      ),
    );
  }
}
