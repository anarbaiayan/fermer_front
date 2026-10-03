import 'package:flutter/material.dart';
import 'package:frontend/core/localization/l10n_extension.dart';
import 'package:frontend/core/network/api_exceptions.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/widgets/app_primary_button.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../application/finance_providers.dart';
import '../../domain/entities/finance_date.dart';
import '../../domain/entities/finance_entities.dart';
import '../../domain/entities/finance_inputs.dart';
import '../../domain/entities/money.dart';
import '../finance_format.dart';
import 'finance_common.dart';
import 'finance_date_field.dart';
import 'finance_form_parts.dart';
import 'finance_page.dart';
import 'finance_sheet.dart';

/// «Получить оплату» поверх списка продаж или долгов (FP-502, FP-503).
///
/// По ТЗ продажа оплачивается целиком: фермер выбирает только счёт и дату
/// (частичной оплаты нет, вопрос В2). После оплаты показывает, сколько и
/// куда пришло. [aboveFab] — если под шторкой плавающая кнопка.
Future<void> showFinancePaySheet(
  BuildContext context, {
  required int saleId,
  required Money amount,
  required DateTime saleDate,
  required String caption,
  bool aboveFab = false,
}) async {
  final messenger = ScaffoldMessenger.of(context);
  final l10n = context.l10n;
  final format = FinanceFormat.of(context);
  final account = await showFinanceSheet<FinanceAccount>(
    context: context,
    builder: (_) => _PaySheet(
      saleId: saleId,
      amount: amount,
      saleDate: saleDate,
      caption: caption,
    ),
  );
  if (account == null) return;
  showFinanceMessage(
    messenger,
    l10n.financePaymentReceived(format.money(amount), account.name),
    aboveFab: aboveFab,
  );
}

class _PaySheet extends ConsumerStatefulWidget {
  const _PaySheet({
    required this.saleId,
    required this.amount,
    required this.saleDate,
    required this.caption,
  });

  final int saleId;
  final Money amount;
  final DateTime saleDate;
  final String caption;

  @override
  ConsumerState<_PaySheet> createState() => _PaySheetState();
}

class _PaySheetState extends ConsumerState<_PaySheet> {
  int? _accountId;
  late DateTime _date;
  String? _error;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _date = ref.read(financeTodayProvider);
  }

  Future<void> _confirm(FinanceAccount account) async {
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await ref
          .read(financeMutationsProvider)
          .paySale(
            widget.saleId,
            SalePayment(accountId: account.id, paidAt: _date),
          );
      if (mounted) Navigator.of(context).pop(account);
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.financeGetPayment,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.primary3,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          widget.caption,
          style: const TextStyle(fontSize: 13, color: AppColors.additional3),
        ),
        const SizedBox(height: 12),
        Text(
          format.money(widget.amount),
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: AppColors.primary1,
          ),
        ),
        const SizedBox(height: 18),
        _body(context, format),
      ],
    );
  }

  Widget _body(BuildContext context, FinanceFormat format) {
    final l10n = context.l10n;
    final accountsAsync = ref.watch(financeAccountsProvider);
    final accounts = accountsAsync.valueOrNull;
    if (accounts == null) {
      if (accountsAsync.hasError) {
        return FinanceMessageCard.error(
          context,
          message: extractApiMessage(accountsAsync.error!),
          onRetry: () => ref.invalidate(financeAccountsProvider),
        );
      }
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    final active = accounts.where((account) => account.active).toList();
    if (active.isEmpty) return const FinanceNoAccounts();

    final selectedId =
        _accountId ??
        pickDefaultAccount(accounts, ref.watch(financeLastAccountProvider))?.id;
    final account = active.where((a) => a.id == selectedId).firstOrNull;
    final today = ref.watch(financeTodayProvider);
    final saleDate = dateOnly(widget.saleDate);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FinanceLabeled(
          label: l10n.financePayAccountLabel,
          child: FinanceAccountChips(
            accounts: active,
            selectedId: selectedId,
            onSelected: (id) => setState(() => _accountId = id),
          ),
        ),
        const SizedBox(height: 18),
        FinanceDateField(
          label: l10n.financePayDateLabel,
          value: _date,
          // Деньги не приходят раньше продажи и позже сегодняшнего дня.
          firstDate: saleDate.isAfter(today) ? today : saleDate,
          lastDate: today,
          onChanged: (date) => setState(() => _date = date),
        ),
        const SizedBox(height: 22),
        AppPrimaryButton(
          text: l10n.financePayConfirm,
          isLoading: _saving,
          onPressed: account == null ? null : () => _confirm(account),
        ),
        if (_error != null) ...[
          const SizedBox(height: 10),
          FinanceNote(_error!, color: AppColors.error),
        ],
        if (account != null) ...[
          const SizedBox(height: 10),
          FinanceNote(
            l10n.financeBalanceWillBe(
              account.name,
              format.money(account.balance + widget.amount),
            ),
          ),
        ],
      ],
    );
  }
}
