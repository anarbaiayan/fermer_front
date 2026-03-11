import 'package:flutter/material.dart';
import 'package:frontend/core/icons/app_icons.dart';
import 'package:frontend/core/localization/l10n_extension.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/widgets/masked_date_picker.dart';
import 'package:frontend/features/lactation/application/lactation_providers.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

class LactationMilkAccountingSection extends ConsumerWidget {
  const LactationMilkAccountingSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final range = ref.watch(lactationRangeProvider);
    final bulkAsync = ref.watch(lactationBulkListProvider);
    final summary = ref.watch(lactationBulkSummaryProvider);

    final dmy = DateFormat('dd.MM.yyyy');
    final fromText = dmy.format(range.from);
    final toText = dmy.format(range.to);

    Future<void> pickFrom() async {
      if (range.mode != LactationRangeMode.period) return;

      final picked = await showMaskedDatePicker(
        context: context,
        initialDate: range.from,
        firstDate: DateTime(2020),
        lastDate: DateTime(2100),
        helpText: l10n.lactationDateStartPeriod,
      );

      if (picked != null) {
        ref.read(lactationRangeProvider.notifier).setFrom(picked);
      }
    }

    Future<void> pickTo() async {
      if (range.mode != LactationRangeMode.period) return;

      final picked = await showMaskedDatePicker(
        context: context,
        initialDate: range.to,
        firstDate: DateTime(2020),
        lastDate: DateTime(2100),
        helpText: l10n.lactationDateEndPeriod,
      );

      if (picked != null) {
        ref.read(lactationRangeProvider.notifier).setTo(picked);
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 14),

        // filter buttons
        Row(
          children: [
            Expanded(
              child: _FilterButton(
                text: l10n.lactationAccountingWeek,
                active: range.mode == LactationRangeMode.week,
                onTap: () => ref
                    .read(lactationRangeProvider.notifier)
                    .setMode(LactationRangeMode.week),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _FilterButton(
                text: l10n.lactationAccountingMonth,
                active: range.mode == LactationRangeMode.month,
                onTap: () => ref
                    .read(lactationRangeProvider.notifier)
                    .setMode(LactationRangeMode.month),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _FilterButton(
                text: l10n.lactationAccountingPeriod,
                active: range.mode == LactationRangeMode.period,
                onTap: () => ref
                    .read(lactationRangeProvider.notifier)
                    .setMode(LactationRangeMode.period),
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        Row(
          children: [
            Expanded(
              child: _DateField(
                text: fromText,
                enabled: range.mode == LactationRangeMode.period,
                onTap: pickFrom,
              ),
            ),
            const SizedBox(width: 12),
            const Text('-', style: TextStyle(color: AppColors.additional3)),
            const SizedBox(width: 12),
            Expanded(
              child: _DateField(
                text: toText,
                enabled: range.mode == LactationRangeMode.period,
                onTap: pickTo,
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        Expanded(
          child: bulkAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(
              child: Text(
                l10n.errorLoadingData('$e'),
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.additional3),
              ),
            ),
            data: (_) {
              return _MilkSummaryGrid(
                cows: summary.cowsTotal,
                totalLiters: summary.totalMilkLiters,
                calvesLiters: summary.milkUsedForCalves,
                unsuitableLiters: summary.unsuitableMilk,
              );
            },
          ),
        ),
      ],
    );
  }
}

class _FilterButton extends StatelessWidget {
  final String text;
  final bool active;
  final VoidCallback onTap;

  const _FilterButton({
    required this.text,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
          side: BorderSide(
            color: active ? AppColors.success : AppColors.additional1,
          ),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        onPressed: onTap,
        child: Text(
          text,
          style: TextStyle(
            fontSize: 13,
            color: active ? AppColors.primary3 : AppColors.additional1,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }
}

class _DateField extends StatelessWidget {
  final String text;
  final bool enabled;
  final VoidCallback onTap;

  const _DateField({
    required this.text,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: InkWell(
        onTap: enabled ? onTap : null,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.additional2),
          ),
          child: Row(
            children: [
              AppIcons.svg('calendar', size: 18, color: AppColors.primary3),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  text,
                  style: TextStyle(
                    color: AppColors.primary3,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MilkSummaryGrid extends StatelessWidget {
  final int cows;
  final double totalLiters;
  final double calvesLiters;
  final double unsuitableLiters;

  const _MilkSummaryGrid({
    required this.cows,
    required this.totalLiters,
    required this.calvesLiters,
    required this.unsuitableLiters,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      children: [
        const SizedBox(height: 8),
        _Pair(
          left: _Cell(
            title: l10n.lactationMilkedCows,
            valueText: cows.toString(),
            valueColor: const Color.fromRGBO(47, 108, 168, 1),
            showArrow: true,
          ),
          right: _Cell(
            title: l10n.lactationTotalMilk,
            valueText: l10n.unitLitersValue(totalLiters.toStringAsFixed(0)),
            valueColor: const Color.fromRGBO(238, 102, 31, 1),
            showArrow: true,
          ),
        ),
        const SizedBox(height: 4),
        _Pair(
          left: _Cell(
            title: l10n.lactationCalfUsed,
            valueText: l10n.unitLitersValue(calvesLiters.toStringAsFixed(1)),
            valueColor: const Color.fromRGBO(166, 95, 58, 1),
          ),
          right: _Cell(
            title: l10n.lactationUnfitMilk,
            valueText: l10n.unitLitersValue(
              unsuitableLiters.toStringAsFixed(0),
            ),
            valueColor: const Color.fromRGBO(19, 186, 186, 1),
          ),
        ),
      ],
    );
  }
}

class _Cell extends StatelessWidget {
  final String title;
  final String valueText;
  final Color valueColor;
  final bool showArrow;

  const _Cell({
    required this.title,
    required this.valueText,
    required this.valueColor,
    this.showArrow = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.zero,
        boxShadow: [
          BoxShadow(
            color: Color.fromRGBO(213, 215, 218, 0.22),
            offset: Offset(0, 4),
            blurRadius: 20,
          ),
          BoxShadow(
            color: Color.fromRGBO(213, 215, 218, 0.4),
            offset: Offset(0, -2),
            blurRadius: 12,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: double.infinity,
            child: Container(
              padding: const EdgeInsets.only(bottom: 4),
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: AppColors.additional2, width: 1),
                ),
              ),
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.primary3,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                valueText,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: valueColor,
                ),
              ),
              if (showArrow)
                Container(
                  width: 40,
                  height: 36,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color.fromRGBO(213, 215, 218, 0.4),
                      width: 1,
                    ),
                  ),
                  child: Center(
                    child: AppIcons.svg('arrow2', size: 22, color: valueColor),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 26),
        ],
      ),
    );
  }
}

class _Pair extends StatelessWidget {
  final _Cell left;
  final _Cell right;

  const _Pair({required this.left, required this.right});

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: left),
          Container(width: 1, color: AppColors.additional2),
          Expanded(child: right),
        ],
      ),
    );
  }
}
