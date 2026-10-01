import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/core/localization/l10n_extension.dart';
import 'package:frontend/core/network/api_exceptions.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/widgets/app_primary_button.dart';
import 'package:frontend/core/widgets/app_text_field.dart';
import 'package:frontend/core/widgets/confirm_dialog.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../application/finance_providers.dart';
import '../../domain/entities/finance_entities.dart';
import '../../domain/entities/finance_enums.dart';
import '../../domain/entities/finance_inputs.dart';
import '../../domain/entities/money.dart';
import '../finance_format.dart';
import '../widgets/decimal_field.dart';
import '../widgets/finance_chips.dart';
import '../widgets/finance_common.dart';
import '../widgets/finance_page.dart';
import '../widgets/finance_segmented_control.dart';

/// Новый счёт или правка счёта [accountId]. После сохранения закрывается
/// и возвращает счёт.
class FinanceAccountFormScreen extends ConsumerWidget {
  const FinanceAccountFormScreen({super.key, this.accountId});

  final int? accountId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    if (accountId == null) return const _AccountForm(account: null);

    final accounts = ref.watch(financeAccountsProvider);
    return accounts.when(
      loading: () => FinancePage(
        title: l10n.financeAccountTitle,
        children: const [Center(child: CircularProgressIndicator())],
      ),
      error: (error, _) => FinancePage(
        title: l10n.financeAccountTitle,
        children: [
          FinanceMessageCard.error(
            context,
            message: extractApiMessage(error),
            onRetry: () => ref.invalidate(financeAccountsProvider),
          ),
        ],
      ),
      data: (list) {
        final account = list.where((a) => a.id == accountId).firstOrNull;
        if (account == null) {
          return FinancePage(
            title: l10n.financeAccountTitle,
            children: [FinanceMessageCard(title: l10n.financeAccountNotFound)],
          );
        }
        return _AccountForm(key: ValueKey(account.id), account: account);
      },
    );
  }
}

class _AccountForm extends ConsumerStatefulWidget {
  const _AccountForm({super.key, required this.account});

  final FinanceAccount? account;

  @override
  ConsumerState<_AccountForm> createState() => _AccountFormState();
}

class _AccountFormState extends ConsumerState<_AccountForm> {
  late final TextEditingController _name;
  late final TextEditingController _initial;
  late AccountType _type;
  String? _nameError;
  String? _initialError;
  String? _saveError;
  bool _saving = false;

  FinanceAccount? get _account => widget.account;

  // Быстрые названия из прототипа. «Касса» — наличные, Halyk — банк,
  // остальные — карты.
  static const _bankNames = {
    'Kaspi': AccountType.card,
    'Halyk': AccountType.bank,
    'Freedom': AccountType.card,
    'Jusan': AccountType.card,
  };

  @override
  void initState() {
    super.initState();
    final account = _account;
    _name = TextEditingController(text: account?.name ?? '');
    _initial = TextEditingController(
      text: account == null
          ? ''
          : DecimalInputFormatter.money.formatText(
              account.initialBalance.toPlainString(),
            ),
    );
    _type = account?.type ?? AccountType.cash;
  }

  @override
  void dispose() {
    _name.dispose();
    _initial.dispose();
    super.dispose();
  }

  void _pickName(String name, AccountType type) {
    _name.value = TextEditingValue(
      text: name,
      selection: TextSelection.collapsed(offset: name.length),
    );
    setState(() {
      _type = type;
      _nameError = null;
    });
  }

  Future<void> _save() async {
    final l10n = context.l10n;
    final name = _name.text.trim();
    final initial = Money.tryParse(_initial.text);
    setState(() {
      _nameError = name.isEmpty ? l10n.financeAccountNameError : null;
      _initialError = initial == null ? l10n.financeAccountInitialError : null;
      _saveError = null;
    });
    if (_nameError != null || initial == null) return;

    final input = AccountInput(
      name: name,
      type: _type,
      initialBalance: initial,
    );
    final mutations = ref.read(financeMutationsProvider);
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _saving = true);
    try {
      final account = _account;
      final saved = account == null
          ? await mutations.createAccount(input)
          : await mutations.updateAccount(account.id, input);
      if (!mounted) return;
      closeFinancePage(context, saved);
      showFinanceMessage(
        messenger,
        account == null
            ? l10n.financeAccountCreated(saved.name)
            : l10n.financeAccountSaved,
      );
    } catch (error) {
      if (mounted) setState(() => _saveError = extractApiMessage(error));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _hide(FinanceAccount account) async {
    final l10n = context.l10n;
    final confirmed = await showConfirmDialog(
      context: context,
      title: l10n.financeAccountHideConfirm(account.name),
      confirmText: l10n.financeHideAction,
    );
    if (!confirmed || !mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    setState(() {
      _saving = true;
      _saveError = null;
    });
    try {
      await ref.read(financeMutationsProvider).deactivateAccount(account.id);
      if (!mounted) return;
      closeFinancePage(context);
      showFinanceMessage(messenger, l10n.financeAccountHidden);
    } catch (error) {
      if (mounted) setState(() => _saveError = extractApiMessage(error));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  /// Правка начального остатка сдвигает текущий на ту же разницу.
  String? _balancePreview(FinanceFormat format) {
    final account = _account;
    final initial = Money.tryParse(_initial.text);
    if (account == null || initial == null) return null;
    if (initial == account.initialBalance) return null;
    final balance = account.balance + (initial - account.initialBalance);
    final name = _name.text.trim().isEmpty ? account.name : _name.text.trim();
    return context.l10n.financeBalanceWillBe(name, format.money(balance));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final format = FinanceFormat.of(context);
    final account = _account;
    final isNew = account == null;
    final preview = _balancePreview(format);
    final quickNames = {
      l10n.financeCashboxName: AccountType.cash,
      ..._bankNames,
    };

    return FinancePage(
      title: isNew ? l10n.financeAccountNewTitle : account.name,
      children: [
        if (!isNew)
          FinanceAmountBox(
            label: l10n.financeAccountBalanceNow,
            amount: format.money(account.balance),
          ),
        if (!isNew && !account.active)
          FinanceCallout(text: l10n.financeAccountHideNote),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppTextField(
              label: l10n.financeNameLabel,
              hintText: l10n.financeCashboxName,
              controller: _name,
              errorText: _nameError,
              textCapitalization: TextCapitalization.sentences,
              inputFormatters: [LengthLimitingTextInputFormatter(100)],
              onChanged: (_) => setState(() => _nameError = null),
            ),
            if (isNew) ...[
              const SizedBox(height: 10),
              FinanceChipRow(
                children: [
                  for (final entry in quickNames.entries)
                    FinanceChip(
                      label: entry.key,
                      selected: _name.text.trim() == entry.key,
                      onTap: () => _pickName(entry.key, entry.value),
                    ),
                ],
              ),
            ],
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.financeAccountTypeLabel,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.primary3,
              ),
            ),
            const SizedBox(height: 8),
            FinanceSegmentedControl<AccountType>(
              segments: {
                for (final type in AccountType.values)
                  type: type.localizedLabel(l10n),
              },
              selected: _type,
              onChanged: (type) => setState(() => _type = type),
            ),
          ],
        ),
        DecimalField.money(
          label: isNew
              ? l10n.financeAccountInitialNewLabel
              : l10n.financeAccountInitialEditLabel,
          hintText: l10n.financeOnboardingAmountHint,
          controller: _initial,
          errorText: _initialError,
          onChanged: (_) => setState(() => _initialError = null),
        ),
        if (isNew)
          FinanceCallout(
            text: l10n.financeAccountInitialCallout,
            tone: FinanceCalloutTone.info,
          ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppPrimaryButton(
              text: isNew ? l10n.financeAccountCreate : l10n.financeSave,
              isLoading: _saving,
              onPressed: _save,
            ),
            if (_saveError != null) ...[
              const SizedBox(height: 10),
              FinanceNote(_saveError!, color: AppColors.error),
            ],
            if (preview != null) ...[
              const SizedBox(height: 10),
              FinanceNote(preview),
            ],
            if (!isNew && account.active) ...[
              const SizedBox(height: 12),
              TextButton(
                onPressed: _saving ? null : () => _hide(account),
                child: Text(
                  l10n.financeAccountHide,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary3,
                  ),
                ),
              ),
              FinanceNote(l10n.financeAccountHideNote),
            ],
          ],
        ),
      ],
    );
  }
}
