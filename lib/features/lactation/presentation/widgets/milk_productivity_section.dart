import 'package:flutter/material.dart';
import 'package:frontend/core/icons/app_icons.dart';
import 'package:frontend/core/localization/l10n_extension.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import '../../application/lactation_providers.dart';
import '../../domain/entities/lactation.dart';
import '../lactation_error_message.dart';

/// Сколько последних замеров учитываем в "среднем" и показываем в истории
/// до нажатия "Показать все".
const _recentCount = 4;

/// Блок "Молочная продуктивность" в карточке животного.
///
/// Только аналитика по контрольным надоям: добавление замеров живёт в разделе
/// "Лактация" → "Контрольный надой", в карточке его намеренно нет.
class MilkProductivitySection extends ConsumerStatefulWidget {
  final int cattleId;

  const MilkProductivitySection({super.key, required this.cattleId});

  @override
  ConsumerState<MilkProductivitySection> createState() =>
      _MilkProductivitySectionState();
}

class _MilkProductivitySectionState
    extends ConsumerState<MilkProductivitySection> {
  bool _showAllHistory = false;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final historyAsync = ref.watch(lactationsByCattleProvider(widget.cattleId));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: AppColors.primary2,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(child: AppIcons.svg('lactation_number')),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                l10n.milkProductivityTitle,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary3,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        const Divider(height: 1, color: AppColors.additional2),
        const SizedBox(height: 8),
        historyAsync.when(
          loading: () => const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Center(child: CircularProgressIndicator()),
          ),
          error: (error, _) => Text(
            lactationErrorMessage(error, l10n),
            style: const TextStyle(fontSize: 13, color: AppColors.additional3),
          ),
          data: _buildData,
        ),
      ],
    );
  }

  Widget _buildData(List<Lactation> records) {
    final l10n = context.l10n;

    if (records.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.milkProductivityEmpty,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.primary3,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            l10n.milkProductivityEmptyHint,
            style: const TextStyle(fontSize: 13, color: AppColors.additional3),
          ),
        ],
      );
    }

    // Бэкенд отдаёт историю отсортированной, но порядок здесь критичен для
    // "последнего" и "среднего за последние N" — сортируем явно.
    final sorted = [...records]
      ..sort((a, b) {
        final byDate = b.milkingDate.compareTo(a.milkingDate);
        if (byDate != 0) return byDate;
        final bTime = b.milkingDateTime;
        final aTime = a.milkingDateTime;
        if (bTime == null || aTime == null) return 0;
        return bTime.compareTo(aTime);
      });

    final recent = sorted.take(_recentCount).toList();
    final average =
        recent.fold<double>(0, (sum, r) => sum + r.milkLiters) / recent.length;
    final max = sorted.map((r) => r.milkLiters).reduce((a, b) => a > b ? a : b);

    final dmy = DateFormat('dd.MM.yyyy');
    final liters = NumberFormat('0.##', l10n.localeName);
    final visible = _showAllHistory ? sorted : recent;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _MetricRow(
          title: l10n.milkProductivityLastControl,
          value: l10n.unitLitersValue(liters.format(sorted.first.milkLiters)),
          hint: dmy.format(sorted.first.milkingDate),
        ),
        const SizedBox(height: 10),
        _MetricRow(
          title: l10n.milkProductivityAverage,
          value: l10n.unitLitersValue(liters.format(average)),
          hint: l10n.milkProductivityAverageHint(recent.length),
        ),
        const SizedBox(height: 10),
        _MetricRow(
          title: l10n.milkProductivityMax,
          value: l10n.unitLitersValue(liters.format(max)),
        ),
        const SizedBox(height: 10),
        _MetricRow(
          title: l10n.milkProductivityMeasurements,
          value: '${sorted.length}',
        ),
        const SizedBox(height: 14),
        Text(
          l10n.milkProductivityHistory,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.primary3,
          ),
        ),
        const SizedBox(height: 6),
        for (final record in visible)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    dmy.format(record.milkingDate),
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.additional3,
                    ),
                  ),
                ),
                Text(
                  l10n.unitLitersValue(liters.format(record.milkLiters)),
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary3,
                  ),
                ),
              ],
            ),
          ),
        if (sorted.length > _recentCount)
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: () =>
                  setState(() => _showAllHistory = !_showAllHistory),
              style: TextButton.styleFrom(padding: EdgeInsets.zero),
              child: Text(
                _showAllHistory
                    ? l10n.hideText
                    : l10n.showAllCount(sorted.length),
              ),
            ),
          ),
      ],
    );
  }
}

class _MetricRow extends StatelessWidget {
  final String title;
  final String value;
  final String? hint;

  const _MetricRow({required this.title, required this.value, this.hint});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.primary3,
                ),
              ),
              if (hint != null)
                Text(
                  hint!,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.additional3,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.primary3,
          ),
        ),
      ],
    );
  }
}
