import 'package:flutter/material.dart';
import 'package:frontend/core/localization/l10n_extension.dart';
import 'package:frontend/core/network/api_exceptions.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/widgets/app_primary_button.dart';
import 'package:frontend/features/auth/application/auth_providers.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../application/finance_providers.dart';
import '../../application/finance_report.dart';
import '../../domain/entities/finance_date.dart';
import '../../domain/entities/finance_enums.dart';
import '../../domain/entities/finance_inputs.dart';
import '../finance_format.dart';
import '../finance_styles.dart';
import '../widgets/finance_chips.dart';
import '../widgets/finance_common.dart';
import '../widgets/finance_date_field.dart';
import '../widgets/finance_form_parts.dart';
import '../widgets/finance_report_contents.dart';

/// Вкладка «Отчёт» (FP-512): период, тип и что попадёт в документ.
/// PDF формирует бэкенд; приложение сохраняет файл и открывает экран
/// «Отчёт готов» с «Отправить».
class FinanceReportTab extends ConsumerStatefulWidget {
  const FinanceReportTab({super.key});

  @override
  ConsumerState<FinanceReportTab> createState() => _FinanceReportTabState();
}

class _FinanceReportTabState extends ConsumerState<FinanceReportTab> {
  bool _busy = false;
  String? _error;

  FinanceReportRequest get _request => FinanceReportRequest(
    period: ref
        .read(financeReportPeriodProvider)
        .resolve(ref.read(financeTodayProvider)),
    type: ref.read(financeReportTypeProvider),
  );

  /// Имя на случай, если бэкенд не пришлёт своё: «Финансы_Акбулак_
  /// сентябрь_2026.pdf» или с датами для произвольного периода.
  String _fallbackName(FinanceReportRequest request) {
    final l10n = context.l10n;
    final format = FinanceFormat.of(context);
    final period = request.period;
    final farm = ref.read(authControllerProvider).user?.farmName?.trim();
    final isMonth =
        period.from == monthStart(period.from) &&
        period.to == addDays(addMonths(period.from, 1), -1);
    final when = isMonth
        ? '${format.monthName(period.from)}_${period.from.year}'
        : '${format.date(period.from)}-${format.date(period.to)}';
    return [
      l10n.financeReportFilePrefix,
      if (farm != null && farm.isNotEmpty) farm,
      when,
    ].join('_');
  }

  Future<void> _generate() async {
    final request = _request;
    final fallback = _fallbackName(request);
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final document = await ref
          .read(financeReportFilesProvider)
          .generate(request, fallbackName: fallback);
      if (mounted) context.push('/finance/report/ready', extra: document);
    } catch (error) {
      if (mounted) setState(() => _error = extractApiMessage(error));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final format = FinanceFormat.of(context);
    final today = ref.watch(financeTodayProvider);
    final choice = ref.watch(financeReportPeriodProvider);
    final type = ref.watch(financeReportTypeProvider);
    final period = choice.resolve(today);

    void setChoice(FinanceReportPeriodChoice value) {
      ref.read(financeReportPeriodProvider.notifier).state = value;
      setState(() => _error = null);
    }

    final periods = {
      FinanceReportPeriodKind.thisMonth: l10n.financeReportThisMonth,
      FinanceReportPeriodKind.lastMonth: l10n.financeReportLastMonth,
      FinanceReportPeriodKind.quarter: l10n.financeReportQuarter,
      FinanceReportPeriodKind.custom: l10n.financeReportCustom,
    };

    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
      children: [
        FinanceLabeled(
          label: l10n.financeReportPeriodLabel,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              FinanceChipRow(
                wrap: true,
                children: [
                  for (final entry in periods.entries)
                    FinanceChip(
                      label: entry.value,
                      selected: choice.kind == entry.key,
                      onTap: () => setChoice(
                        FinanceReportPeriodChoice(
                          entry.key,
                          from: choice.from,
                          to: choice.to,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              if (choice.kind == FinanceReportPeriodKind.custom) ...[
                FinanceDateField(
                  label: l10n.financeReportFrom,
                  value: period.from,
                  lastDate: period.to,
                  onChanged: (date) => setChoice(
                    FinanceReportPeriodChoice(
                      choice.kind,
                      from: date,
                      to: period.to,
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                FinanceDateField(
                  label: l10n.financeReportTo,
                  value: period.to,
                  firstDate: period.from,
                  lastDate: today,
                  onChanged: (date) => setChoice(
                    FinanceReportPeriodChoice(
                      choice.kind,
                      from: period.from,
                      to: date,
                    ),
                  ),
                ),
              ] else
                Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: Text(
                    '${format.date(period.from)} — ${format.date(period.to)}',
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.additional3,
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        FinanceLabeled(
          label: l10n.financeReportTypeLabel,
          child: Column(
            children: [
              for (final value in FinanceReportType.values) ...[
                if (value.index > 0) const SizedBox(height: 8),
                _TypeTile(
                  title: value.localizedLabel(l10n),
                  hint: value.localizedHint(l10n),
                  selected: value == type,
                  onTap: () {
                    ref.read(financeReportTypeProvider.notifier).state = value;
                    setState(() => _error = null);
                  },
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 22),
        FinanceReportContents(
          request: FinanceReportRequest(period: period, type: type),
        ),
        const SizedBox(height: 22),
        AppPrimaryButton(
          text: l10n.financeReportMake,
          isLoading: _busy,
          onPressed: _generate,
        ),
        if (_error != null) ...[
          const SizedBox(height: 10),
          FinanceNote(_error!, color: AppColors.error),
        ],
      ],
    );
  }
}

/// Тип отчёта — плитка-переключатель с пояснением.
class _TypeTile extends StatelessWidget {
  const _TypeTile({
    required this.title,
    required this.hint,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String hint;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      inMutuallyExclusiveGroup: true,
      checked: selected,
      button: true,
      child: Material(
        color: selected ? FinanceColors.softGreen : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: selected ? AppColors.primary1 : AppColors.additional2,
            width: 1.5,
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 20,
                  height: 20,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: selected
                          ? AppColors.primary1
                          : AppColors.additional2,
                      width: 2,
                    ),
                  ),
                  child: selected
                      ? Container(
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.primary1,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary3,
                        ),
                      ),
                      Text(
                        hint,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.additional3,
                        ),
                      ),
                    ],
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
