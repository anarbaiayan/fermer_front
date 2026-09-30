import 'package:flutter/material.dart';
import 'package:frontend/core/localization/l10n_extension.dart';
import 'package:frontend/core/network/api_exceptions.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/widgets/app_primary_button.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../application/finance_providers.dart';
import '../../domain/entities/finance_entities.dart';
import '../../domain/entities/finance_enums.dart';
import '../../domain/entities/finance_inputs.dart';
import '../../domain/entities/money.dart';
import '../finance_format.dart';
import '../finance_styles.dart';
import 'decimal_field.dart';
import 'finance_chips.dart';
import 'finance_common.dart';
import 'finance_page.dart';

/// Первый вход в «Финансы»: пока нет ни одного счёта, раздел просит
/// реальные остатки в кассе и на карте. Без начального остатка баланс
/// неверен с первого дня (ТЗ, раздел 5).
///
/// Пустое поле — такого счёта нет, `0` — счёт есть, но пустой. Счета,
/// добавленные через «Другой счёт», показываются здесь же.
class FinanceOnboarding extends ConsumerStatefulWidget {
  const FinanceOnboarding({
    super.key,
    required this.createdAccounts,
    required this.onDone,
  });

  /// Счета, уже созданные во время первого входа.
  final List<FinanceAccount> createdAccounts;
  final VoidCallback onDone;

  @override
  ConsumerState<FinanceOnboarding> createState() => _FinanceOnboardingState();
}

class _FinanceOnboardingState extends ConsumerState<FinanceOnboarding> {
  final _cash = TextEditingController();
  final _card = TextEditingController();

  /// Карточки, чей счёт уже создан: при повторе после ошибки не дублируем.
  final _created = <TextEditingController>{};
  String? _error;
  bool _saving = false;

  @override
  void dispose() {
    _cash.dispose();
    _card.dispose();
    super.dispose();
  }

  Future<void> _start() async {
    final l10n = context.l10n;
    final drafts = [
      (_cash, l10n.financeCashboxName, AccountType.cash),
      (_card, 'Kaspi', AccountType.card),
    ].where((d) => !_created.contains(d.$1) && d.$1.text.trim().isNotEmpty);

    if (drafts.isEmpty && _created.isEmpty && widget.createdAccounts.isEmpty) {
      setState(() => _error = l10n.financeOnboardingEmptyError);
      return;
    }

    final mutations = ref.read(financeMutationsProvider);
    final messenger = ScaffoldMessenger.of(context);
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      for (final (controller, name, type) in drafts.toList()) {
        await mutations.createAccount(
          AccountInput(
            name: name,
            type: type,
            initialBalance: Money.tryParse(controller.text) ?? Money.zero,
          ),
        );
        _created.add(controller);
      }
      if (!mounted) return;
      showFinanceMessage(messenger, l10n.financeOnboardingDone);
      widget.onDone();
    } catch (error) {
      if (mounted) setState(() => _error = extractApiMessage(error));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final format = FinanceFormat.of(context);

    return FinanceKeyboardDismiss(
      child: ListView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
        children: [
          const Center(
            child: FinanceIconSquare.large(
              icon: 'money_plain',
              color: AppColors.primary1,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            l10n.financeOnboardingTitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.primary3,
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 300),
              child: Text(
                l10n.financeOnboardingText,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  height: 1.4,
                  color: AppColors.additional3,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          for (final (controller, name, type) in [
            (_cash, l10n.financeCashboxName, AccountType.cash),
            (_card, 'Kaspi', AccountType.card),
          ]) ...[
            _AccountCard(
              name: name,
              type: type,
              controller: controller,
              enabled: !_created.contains(controller),
              onChanged: () => setState(() => _error = null),
            ),
            const SizedBox(height: 12),
          ],
          if (widget.createdAccounts.isNotEmpty) ...[
            FinanceCardList(
              children: [
                for (final account in widget.createdAccounts)
                  FinanceListRow(
                    leading: FinanceIconSquare.small(
                      icon: account.type.iconName,
                      color: AppColors.primary1,
                    ),
                    title: account.name,
                    subtitle: account.type.localizedLabel(l10n),
                    trailing: Text(
                      format.money(account.balance),
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary3,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
          ],
          Align(
            alignment: Alignment.centerLeft,
            child: FinanceChip.add(
              label: l10n.financeOnboardingOtherAccount,
              onTap: _saving
                  ? null
                  : () => context.push('/finance/accounts/new'),
            ),
          ),
          const SizedBox(height: 22),
          if (_error != null) ...[
            FinanceNote(_error!, color: AppColors.error),
            const SizedBox(height: 12),
          ],
          AppPrimaryButton(
            text: l10n.financeOnboardingStart,
            isLoading: _saving,
            onPressed: _start,
          ),
          const SizedBox(height: 10),
          FinanceNote(l10n.financeOnboardingLater),
        ],
      ),
    );
  }
}

class _AccountCard extends StatelessWidget {
  const _AccountCard({
    required this.name,
    required this.type,
    required this.controller,
    required this.enabled,
    required this.onChanged,
  });

  final String name;
  final AccountType type;
  final TextEditingController controller;
  final bool enabled;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return FinanceCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              FinanceIconSquare(icon: type.iconName, color: AppColors.primary1),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary3,
                      ),
                    ),
                    Text(
                      type.localizedLabel(l10n),
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.additional3,
                      ),
                    ),
                  ],
                ),
              ),
              if (!enabled)
                const Icon(
                  Icons.check_circle_rounded,
                  color: FinanceColors.paidText,
                ),
            ],
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              l10n.financeOnboardingAmountLabel,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.additional3,
              ),
            ),
          ),
          IgnorePointer(
            ignoring: !enabled,
            child: DecimalField.money(
              label: '',
              hintText: l10n.financeOnboardingAmountHint,
              controller: controller,
              onChanged: (_) => onChanged(),
            ),
          ),
        ],
      ),
    );
  }
}
