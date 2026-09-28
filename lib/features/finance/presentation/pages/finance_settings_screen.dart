import 'package:flutter/material.dart';
import 'package:frontend/core/localization/l10n_extension.dart';
import 'package:frontend/core/network/api_exceptions.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/widgets/app_outlined_button.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../application/finance_providers.dart';
import '../../domain/entities/finance_entities.dart';
import '../finance_format.dart';
import '../finance_styles.dart';
import '../widgets/finance_common.dart';
import '../widgets/finance_page.dart';
import '../widgets/finance_segmented_control.dart';

enum FinanceSettingsTab {
  accounts,
  buyers;

  static FinanceSettingsTab fromQuery(String? value) => values.firstWhere(
    (tab) => tab.name == value,
    orElse: () => FinanceSettingsTab.accounts,
  );
}

/// «Счета и покупатели» — общий справочник для дохода и расхода.
/// Открывается шестерёнкой в «Финансах»; `?tab=buyers` — сразу покупатели.
class FinanceSettingsScreen extends StatefulWidget {
  const FinanceSettingsScreen({
    super.key,
    this.initialTab = FinanceSettingsTab.accounts,
  });

  final FinanceSettingsTab initialTab;

  @override
  State<FinanceSettingsScreen> createState() => _FinanceSettingsScreenState();
}

class _FinanceSettingsScreenState extends State<FinanceSettingsScreen> {
  late FinanceSettingsTab _tab = widget.initialTab;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final accounts = _tab == FinanceSettingsTab.accounts;
    return FinancePage(
      title: l10n.financeSettingsTitle,
      spacing: 16,
      children: [
        FinanceSegmentedControl<FinanceSettingsTab>(
          segments: {
            FinanceSettingsTab.accounts: l10n.financeSettingsAccountsTab,
            FinanceSettingsTab.buyers: l10n.financeSettingsBuyersTab,
          },
          selected: _tab,
          onChanged: (tab) => setState(() => _tab = tab),
        ),
        if (accounts) const _AccountsSection() else const _BuyersSection(),
        FinanceCallout(
          text: accounts
              ? l10n.financeAccountsCallout
              : l10n.financeBuyersCallout,
        ),
      ],
    );
  }
}

class _AccountsSection extends ConsumerWidget {
  const _AccountsSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final format = FinanceFormat.of(context);

    return ref
        .watch(financeAccountsProvider)
        .when(
          loading: () => const _Loading(),
          error: (error, _) => FinanceMessageCard.error(
            context,
            message: extractApiMessage(error),
            onRetry: () => ref.invalidate(financeAccountsProvider),
          ),
          data: (accounts) {
            final active = accounts.where((a) => a.active).toList();
            final hidden = accounts.where((a) => !a.active).toList();

            Widget row(FinanceAccount account) => FinanceListRow(
              leading: FinanceIconSquare.small(
                icon: account.type.iconName,
                color: account.active
                    ? AppColors.primary1
                    : AppColors.additional3,
              ),
              title: account.name,
              subtitle: account.active
                  ? account.type.localizedLabel(l10n)
                  : l10n.financeHiddenHint,
              trailing: _Amount(format.money(account.balance)),
              showChevron: true,
              onTap: () => context.push('/finance/accounts/${account.id}'),
            );

            return _Section(
              items: [for (final account in active) row(account)],
              empty: FinanceMessageCard(
                title: l10n.financeAccountsEmptyTitle,
                message: l10n.financeAccountsEmptyText,
              ),
              addLabel: l10n.financeAddAccount,
              onAdd: () => context.push('/finance/accounts/new'),
              hidden: [for (final account in hidden) row(account)],
            );
          },
        );
  }
}

class _BuyersSection extends ConsumerWidget {
  const _BuyersSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final format = FinanceFormat.of(context);
    // Долги — дополнительная подпись: если их не удалось загрузить,
    // список покупателей всё равно показываем.
    final debts = {
      for (final debt in ref.watch(financeDebtsProvider).valueOrNull ?? [])
        debt.counterpartyId: debt,
    };

    return ref
        .watch(financeCounterpartiesProvider)
        .when(
          loading: () => const _Loading(),
          error: (error, _) => FinanceMessageCard.error(
            context,
            message: extractApiMessage(error),
            onRetry: () => ref.invalidate(financeCounterpartiesProvider),
          ),
          data: (buyers) {
            Widget row(Counterparty buyer) {
              final debt = debts[buyer.id];
              return FinanceListRow(
                leading: _BuyerAvatar(buyer: buyer),
                title: buyer.name,
                subtitle: buyer.active
                    ? (buyer.phone ?? l10n.financeNoPhone)
                    : l10n.financeHiddenHint,
                footer: debt == null || debt.totalDebt.isZero
                    ? null
                    : FinancePill(
                        label: l10n.financeBuyerOwes(
                          format.money(debt.totalDebt),
                        ),
                        tone: debt.overdueDays > 0
                            ? FinancePillTone.overdue
                            : FinancePillTone.due,
                      ),
                showChevron: true,
                onTap: () =>
                    context.push('/finance/counterparties/${buyer.id}'),
              );
            }

            return _Section(
              items: [
                for (final buyer in buyers.where((b) => b.active)) row(buyer),
              ],
              empty: FinanceMessageCard(
                title: l10n.financeBuyersEmptyTitle,
                message: l10n.financeBuyersEmptyText,
              ),
              addLabel: l10n.financeAddCounterparty,
              onAdd: () => context.push('/finance/counterparties/new'),
              hidden: [
                for (final buyer in buyers.where((b) => !b.active)) row(buyer),
              ],
            );
          },
        );
  }
}

/// Список активных, кнопка добавления и блок «Скрытые».
class _Section extends StatelessWidget {
  const _Section({
    required this.items,
    required this.empty,
    required this.addLabel,
    required this.onAdd,
    required this.hidden,
  });

  final List<Widget> items;
  final Widget empty;
  final String addLabel;
  final VoidCallback onAdd;
  final List<Widget> hidden;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (items.isEmpty) empty else FinanceCardList(children: items),
        const SizedBox(height: 12),
        AppOutlinedButton(text: addLabel, height: 44, onPressed: onAdd),
        if (hidden.isNotEmpty) ...[
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.only(left: 2, bottom: 8),
            child: Text(
              context.l10n.financeHiddenSection.toUpperCase(),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.7,
                color: AppColors.additional3,
              ),
            ),
          ),
          Opacity(opacity: 0.6, child: FinanceCardList(children: hidden)),
        ],
      ],
    );
  }
}

class _BuyerAvatar extends StatelessWidget {
  const _BuyerAvatar({required this.buyer});

  final Counterparty buyer;

  @override
  Widget build(BuildContext context) {
    final color = buyer.active ? AppColors.primary2 : AppColors.additional3;
    return Container(
      width: 36,
      height: 36,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        buyerInitial(buyer.name),
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}

/// Буква для аватара покупателя: из «Магазин «Достык»» — «Д», а не «М».
String buyerInitial(String name) {
  final words = name
      .replaceAll(RegExp('[«»"\'“”]'), ' ')
      .split(RegExp(r'\s+'))
      .where((word) => word.isNotEmpty)
      .toList();
  const generic = {'магазин', 'кафе', 'ип', 'тоо', 'дүкен', 'дукен'};
  final meaningful = words.firstWhere(
    (word) => !generic.contains(word.toLowerCase().replaceAll(',', '')),
    orElse: () => words.isEmpty ? '?' : words.first,
  );
  return meaningful.characters.first.toUpperCase();
}

class _Amount extends StatelessWidget {
  const _Amount(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: AppColors.primary3,
      ),
    );
  }
}

class _Loading extends StatelessWidget {
  const _Loading();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 32),
      child: Center(child: CircularProgressIndicator()),
    );
  }
}
