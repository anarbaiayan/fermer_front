import 'package:flutter/material.dart';
import 'package:frontend/core/icons/app_icons.dart';
import 'package:frontend/core/localization/l10n_extension.dart';
import 'package:frontend/core/network/api_exceptions.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/widgets/app_scaffold.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../application/finance_providers.dart';
import '../../application/finance_report.dart';
import '../widgets/finance_common.dart';
import '../tabs/finance_expense_tab.dart';
import '../tabs/finance_income_tab.dart';
import '../tabs/finance_report_tab.dart';
import '../tabs/finance_summary_tab.dart';
import '../widgets/finance_onboarding.dart';
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

  /// Идёт первый вход. Решается один раз по первой загрузке счетов и
  /// держится, пока фермер не нажмёт «Начать», даже если он уже добавил
  /// счёт через «Другой счёт». `null` — счета ещё не загружены.
  bool? _onboarding;

  @override
  void didUpdateWidget(FinanceScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialTab != widget.initialTab) _tab = widget.initialTab;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    // Месяц и фильтры живут, пока открыт раздел: при переходе между
    // вкладками и в формы и обратно они не сбрасываются.
    ref
      ..listen(financeMonthProvider, (_, _) {})
      ..listen(financeExpenseCategoryFilterProvider, (_, _) {})
      ..listen(financeExpenseAccountFilterProvider, (_, _) {})
      ..listen(financeIncomeFilterProvider, (_, _) {})
      ..listen(financeReportPeriodProvider, (_, _) {})
      ..listen(financeReportTypeProvider, (_, _) {});
    final accountsAsync = ref.watch(financeAccountsProvider);
    final accounts = accountsAsync.valueOrNull;
    // Поле, а не setState: решение принимается по данным этого же кадра.
    // Повторно не пересчитываем: сразу после «Начать» список ещё старый.
    if (accounts != null) _onboarding ??= accounts.isEmpty;
    final ready = accounts != null && _onboarding == false;

    final Widget content;
    if (accounts == null) {
      content = accountsAsync.hasError
          ? ListView(
              padding: const EdgeInsets.all(24),
              children: [
                FinanceMessageCard.error(
                  context,
                  message: extractApiMessage(accountsAsync.error!),
                  onRetry: () => ref.invalidate(financeAccountsProvider),
                ),
              ],
            )
          : const Center(child: CircularProgressIndicator());
    } else if (_onboarding == true) {
      content = FinanceOnboarding(
        createdAccounts: accounts,
        onDone: () => setState(() => _onboarding = false),
      );
    } else {
      content = _TabBody(
        tab: _tab,
        onOpenTab: (tab) => setState(() => _tab = tab),
      );
    }

    return AppScaffold(
      bottomNavIndex: 4,
      farmName: l10n.farmName,
      floatingActionButton: !ready
          ? null
          : switch (_tab) {
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
                onSettings: ready
                    ? () => context.push('/finance/settings')
                    : null,
              ),
            ),
            if (ready)
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
            Expanded(child: content),
          ],
        ),
      ),
    );
  }
}

class _FinanceHeader extends StatelessWidget {
  const _FinanceHeader({required this.onSettings});

  /// `null` — шестерёнка скрыта (первый вход, загрузка).
  final VoidCallback? onSettings;

  /// Назад туда, откуда открыли: «Ещё» или главная. Открыт по ссылке —
  /// в «Ещё», где живёт раздел.
  void _back(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/more');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Row(
      children: [
        IconButton(
          padding: EdgeInsets.zero,
          tooltip: MaterialLocalizations.of(context).backButtonTooltip,
          icon: AppIcons.svg('arrow', size: 32),
          onPressed: () => _back(context),
        ),
        const SizedBox(width: 6),
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
        // Высота как у кнопки, чтобы заголовок не прыгал после загрузки.
        if (onSettings == null)
          const SizedBox(height: 44)
        else
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

/// Содержимое вкладки.
class _TabBody extends StatelessWidget {
  const _TabBody({required this.tab, required this.onOpenTab});

  final FinanceTab tab;

  /// Сводка открывает доход и расход по нажатию на итоги.
  final ValueChanged<FinanceTab> onOpenTab;

  @override
  Widget build(BuildContext context) {
    return switch (tab) {
      FinanceTab.summary => FinanceSummaryTab(
        onOpenIncome: () => onOpenTab(FinanceTab.income),
        onOpenExpenses: () => onOpenTab(FinanceTab.expense),
      ),
      FinanceTab.income => const FinanceIncomeTab(),
      FinanceTab.expense => const FinanceExpenseTab(),
      FinanceTab.report => const FinanceReportTab(),
    };
  }
}
