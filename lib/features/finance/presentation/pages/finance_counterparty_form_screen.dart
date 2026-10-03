import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/core/localization/l10n_extension.dart';
import 'package:frontend/core/network/api_exceptions.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/widgets/app_primary_button.dart';
import 'package:frontend/core/widgets/app_text_field.dart';
import 'package:frontend/core/widgets/confirm_dialog.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

import '../../application/finance_providers.dart';
import '../../domain/entities/finance_entities.dart';
import '../../domain/entities/finance_inputs.dart';
import '../finance_phone.dart';
import '../widgets/finance_common.dart';
import '../widgets/finance_page.dart';

/// Новый покупатель или правка [counterpartyId]. После сохранения
/// закрывается и возвращает покупателя — форма продажи сразу его выберет.
class FinanceCounterpartyFormScreen extends ConsumerWidget {
  const FinanceCounterpartyFormScreen({super.key, this.counterpartyId});

  final int? counterpartyId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    if (counterpartyId == null) return const _CounterpartyForm(buyer: null);

    final buyers = ref.watch(financeCounterpartiesProvider);
    return buyers.when(
      loading: () => FinancePage(
        title: l10n.financeCounterpartyTitle,
        children: const [Center(child: CircularProgressIndicator())],
      ),
      error: (error, _) => FinancePage(
        title: l10n.financeCounterpartyTitle,
        children: [
          FinanceMessageCard.error(
            context,
            message: extractApiMessage(error),
            onRetry: () => ref.invalidate(financeCounterpartiesProvider),
          ),
        ],
      ),
      data: (list) {
        final buyer = list.where((c) => c.id == counterpartyId).firstOrNull;
        if (buyer == null) {
          return FinancePage(
            title: l10n.financeCounterpartyTitle,
            children: [
              FinanceMessageCard(title: l10n.financeCounterpartyNotFound),
            ],
          );
        }
        return _CounterpartyForm(key: ValueKey(buyer.id), buyer: buyer);
      },
    );
  }
}

class _CounterpartyForm extends ConsumerStatefulWidget {
  const _CounterpartyForm({super.key, required this.buyer});

  final Counterparty? buyer;

  @override
  ConsumerState<_CounterpartyForm> createState() => _CounterpartyFormState();
}

class _CounterpartyFormState extends ConsumerState<_CounterpartyForm> {
  late final TextEditingController _name;
  late final TextEditingController _phone;
  late final MaskTextInputFormatter _phoneMask;
  String? _nameError;
  String? _phoneError;
  String? _saveError;
  bool _saving = false;

  Counterparty? get _buyer => widget.buyer;

  @override
  void initState() {
    super.initState();
    final phone = _buyer?.phone;
    _name = TextEditingController(text: _buyer?.name ?? '');
    _phone = TextEditingController(
      text: phone == null ? '' : FinancePhone.format(phone),
    );
    _phoneMask = FinancePhone.formatter(initial: phone);
  }

  @override
  void dispose() {
    _name.dispose();
    _phone.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final l10n = context.l10n;
    final name = _name.text.trim();
    final phone = FinancePhone.fromInput(_phone.text);
    setState(() {
      _nameError = name.isEmpty ? l10n.financeCounterpartyNameError : null;
      _phoneError = phone == '' ? l10n.financePhoneError : null;
      _saveError = null;
    });
    if (_nameError != null || _phoneError != null) return;

    final input = CounterpartyInput(name: name, phone: phone);
    final mutations = ref.read(financeMutationsProvider);
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _saving = true);
    try {
      final buyer = _buyer;
      final saved = buyer == null
          ? await mutations.createCounterparty(input)
          : await mutations.updateCounterparty(buyer.id, input);
      if (!mounted) return;
      closeFinancePage(context, saved);
      showFinanceMessage(
        messenger,
        buyer == null
            ? l10n.financeCounterpartyCreated
            : l10n.financeCounterpartySaved,
      );
    } catch (error) {
      if (mounted) setState(() => _saveError = extractApiMessage(error));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _hide(Counterparty buyer) async {
    final l10n = context.l10n;
    final confirmed = await showConfirmDialog(
      context: context,
      title: l10n.financeCounterpartyHideConfirm(buyer.name),
      confirmText: l10n.financeHideAction,
    );
    if (!confirmed || !mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    setState(() {
      _saving = true;
      _saveError = null;
    });
    try {
      await ref.read(financeMutationsProvider).deactivateCounterparty(buyer.id);
      if (!mounted) return;
      closeFinancePage(context);
      showFinanceMessage(messenger, l10n.financeCounterpartyHidden);
    } catch (error) {
      if (mounted) setState(() => _saveError = extractApiMessage(error));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final buyer = _buyer;
    final isNew = buyer == null;

    return FinancePage(
      title: isNew
          ? l10n.financeCounterpartyNewTitle
          : l10n.financeCounterpartyTitle,
      children: [
        if (!isNew && !buyer.active)
          FinanceCallout(text: l10n.financeCounterpartyHideNote),
        AppTextField(
          label: l10n.financeNameLabel,
          hintText: l10n.financeCounterpartyNameHint,
          controller: _name,
          errorText: _nameError,
          textCapitalization: TextCapitalization.sentences,
          inputFormatters: [LengthLimitingTextInputFormatter(200)],
          onChanged: (_) => setState(() => _nameError = null),
        ),
        AppTextField(
          label: l10n.financePhoneLabel,
          labelNote: l10n.financeOptional,
          hintText: l10n.financePhoneHint,
          helperText: l10n.financePhoneHelper,
          controller: _phone,
          errorText: _phoneError,
          keyboardType: TextInputType.phone,
          inputFormatters: [_phoneMask],
          onChanged: (_) => setState(() => _phoneError = null),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppPrimaryButton(
              text: isNew ? l10n.financeCounterpartyAdd : l10n.financeSave,
              isLoading: _saving,
              onPressed: _save,
            ),
            if (_saveError != null) ...[
              const SizedBox(height: 10),
              FinanceNote(_saveError!, color: AppColors.error),
            ],
            if (!isNew && buyer.active) ...[
              const SizedBox(height: 12),
              TextButton(
                onPressed: _saving ? null : () => _hide(buyer),
                child: Text(
                  l10n.financeCounterpartyHide,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary3,
                  ),
                ),
              ),
              FinanceNote(l10n.financeCounterpartyHideNote),
            ],
          ],
        ),
      ],
    );
  }
}
