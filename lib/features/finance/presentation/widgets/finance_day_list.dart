import 'package:flutter/material.dart';
import 'package:frontend/core/localization/l10n_extension.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../application/finance_providers.dart';
import '../../domain/entities/finance_date.dart';
import '../finance_format.dart';
import 'finance_common.dart';

/// Операции по дням: заголовок дня и карточка со строками. Новые сверху,
/// порядок внутри дня — как пришёл с бэкенда.
class FinanceDayList<T> extends ConsumerWidget {
  const FinanceDayList({
    super.key,
    required this.items,
    required this.dateOf,
    required this.rowBuilder,
  });

  final List<T> items;
  final DateTime Function(T item) dateOf;
  final Widget Function(T item) rowBuilder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final today = ref.watch(financeTodayProvider);
    final days = <DateTime, List<T>>{};
    for (final item in items) {
      days.putIfAbsent(dateOnly(dateOf(item)), () => []).add(item);
    }
    final sorted = days.keys.toList()..sort((a, b) => b.compareTo(a));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < sorted.length; i++) ...[
          Padding(
            padding: EdgeInsets.fromLTRB(2, i == 0 ? 0 : 16, 2, 8),
            child: Text(
              financeDayTitle(context, sorted[i], today),
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppColors.additional3,
              ),
            ),
          ),
          FinanceCardList(
            children: [for (final item in days[sorted[i]]!) rowBuilder(item)],
          ),
        ],
      ],
    );
  }
}

/// «Сегодня, 19 сентября», «Вчера, 18 сентября», «17 сентября, чт».
String financeDayTitle(BuildContext context, DateTime day, DateTime today) {
  final l10n = context.l10n;
  final format = FinanceFormat.of(context);
  return switch (daysBetween(day, today)) {
    0 => l10n.financeDateToday(format.dayTitle(day)),
    1 => l10n.financeDateYesterday(format.dayTitle(day)),
    _ => format.dayTitleWithWeekday(day),
  };
}
