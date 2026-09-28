import 'package:flutter/material.dart';
import 'package:frontend/core/icons/app_icons.dart';
import 'package:frontend/core/localization/l10n_extension.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/widgets/masked_date_picker.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../application/finance_providers.dart';
import '../../domain/entities/finance_date.dart';
import '../finance_format.dart';
import '../finance_styles.dart';

/// Поле даты операции: «Сегодня, 19.09.2026» или «24.09.2026».
/// По нажатию открывает общий календарь с ручным вводом.
class FinanceDateField extends ConsumerWidget {
  const FinanceDateField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.firstDate,
    this.lastDate,
    this.hint,
  });

  final String label;
  final DateTime value;
  final ValueChanged<DateTime> onChanged;

  /// По умолчанию — 2000 год.
  final DateTime? firstDate;

  /// По умолчанию — пять лет вперёд.
  final DateTime? lastDate;

  /// Подсказка под полем, например про срок долга.
  final String? hint;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final today = ref.watch(financeTodayProvider);
    final formatted = FinanceFormat.of(context).date(value);
    final text = dateOnly(value) == today
        ? context.l10n.financeDateToday(formatted)
        : formatted;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppColors.primary3,
          ),
        ),
        const SizedBox(height: 8),
        Material(
          color: FinanceColors.fieldFill,
          shape: const StadiumBorder(),
          child: InkWell(
            customBorder: const StadiumBorder(),
            onTap: () => _pick(context, today),
            child: Container(
              height: 52,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  AppIcons.svg('calendar', size: 18, color: AppColors.primary3),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      text,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        color: AppColors.primary3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (hint != null) ...[
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.only(left: 20),
            child: Text(
              hint!,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.additional3,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Future<void> _pick(BuildContext context, DateTime today) async {
    // Календарь работает с локальными датами, модуль — с датами без времени.
    DateTime local(DateTime day) => DateTime(day.year, day.month, day.day);
    final picked = await showMaskedDatePicker(
      context: context,
      initialDate: local(value),
      firstDate: local(firstDate ?? DateTime.utc(2000)),
      lastDate: local(lastDate ?? DateTime.utc(today.year + 5, 12, 31)),
      helpText: label,
    );
    if (picked != null) onChanged(dateOnly(picked));
  }
}
