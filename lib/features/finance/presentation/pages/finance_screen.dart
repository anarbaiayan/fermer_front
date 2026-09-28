import 'package:flutter/material.dart';
import 'package:frontend/core/icons/app_icons.dart';
import 'package:frontend/core/localization/l10n_extension.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/widgets/app_scaffold.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../application/finance_providers.dart';
import '../widgets/finance_common.dart';
import '../widgets/finance_period_switcher.dart';
import '../widgets/finance_tab_bar.dart';

/// Вкладки раздела. В адресе — `/finance?tab=income`.
enum FinanceTab {
  summary,
  income,
  expense,
  report;

  static FinanceTab fromQuery(String? value) => values.firstWhere(
    (tab) => tab.name == value,
    orElse: () => FinanceTab.summary,
  );
}

/// «Финансы»: сводка, доход, расход и отчёт в одном экране с вкладками.
///
/// Вкладки переключаются внутри экрана, без перехода, поэтому «Назад»
/// с любой вкладки возвращает в «Ещё». Экран живёт в оболочке с нижним
/// баром (вкладка «Ещё»).
class FinanceScreen extends ConsumerStatefulWidget {
  const FinanceScreen({super.key, this.initialTab = FinanceTab.summary});

  final FinanceTab initialTab;

  @override
  ConsumerState<FinanceScreen> createState() => _FinanceScreenState();
}

class _FinanceScreenState extends ConsumerState<FinanceScreen> {
  late FinanceTab _tab = widget.initialTab;

  @override
  void didUpdateWidget(FinanceScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialTab != widget.initialTab) _tab = widget.initialTab;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return AppScaffold(
      bottomNavIndex: 4,
      farmName: l10n.farmName,
      floatingActionButton: switch (_tab) {
        FinanceTab.income => FinanceAddButton(
          label: l10n.financeAddSale,
          onPressed: () => context.push('/finance/sales/new'),
        ),
        FinanceTab.expense => FinanceAddButton(
          label: l10n.financeAddExpense,
          onPressed: () => context.push('/finance/expenses/new'),
        ),
        _ => null,
      },
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 4),
              child: _FinanceHeader(
                onSettings: () => context.push('/finance/settings'),
              ),
            ),
            FinanceTabBar(
              labels: [
                l10n.financeTabSummary,
                l10n.financeTabIncome,
                l10n.financeTabExpense,
                l10n.financeTabReport,
              ],
              index: _tab.index,
              onChanged: (index) =>
                  setState(() => _tab = FinanceTab.values[index]),
            ),
            Expanded(child: _TabBody(tab: _tab)),
          ],
        ),
      ),
    );
  }
}

class _FinanceHeader extends StatelessWidget {
  const _FinanceHeader({required this.onSettings});

  final VoidCallback onSettings;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Row(
      children: [
        Expanded(
          child: Text(
            l10n.financeTitle,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppColors.primary3,
            ),
          ),
        ),
        Tooltip(
          message: l10n.financeSettingsTitle,
          child: Material(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: AppColors.additional2),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: onSettings,
              child: SizedBox(
                width: 44,
                height: 44,
                child: Center(
                  child: AppIcons.svg(
                    'settings',
                    size: 22,
                    color: AppColors.primary1,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Содержимое вкладки. Пока модули не готовы — заглушка под переключателем
/// месяца; модули 1–6 заменяют её экранами из прототипа.
class _TabBody extends ConsumerWidget {
  const _TabBody({required this.tab});

  final FinanceTab tab;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final today = ref.watch(financeTodayProvider);
    final month = ref.watch(financeMonthProvider);

    return ListView(
      // Снизу место под плавающую кнопку.
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 96),
      children: [
        if (tab != FinanceTab.report) ...[
          FinancePeriodSwitcher(
            month: month,
            maxMonth: today,
            onChanged: (value) =>
                ref.read(financeMonthProvider.notifier).state = value,
          ),
          const SizedBox(height: 20),
        ],
        FinanceMessageCard(title: context.l10n.financeStubMessage),
      ],
    );
  }
}
