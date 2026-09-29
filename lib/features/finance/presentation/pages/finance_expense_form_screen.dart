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
import '../../domain/entities/finance_date.dart';
import '../../domain/entities/finance_entities.dart';
import '../../domain/entities/finance_enums.dart';
import '../../domain/entities/finance_inputs.dart';
import '../../domain/entities/money.dart';
import '../finance_format.dart';
import '../widgets/decimal_field.dart';
import '../widgets/expense_category_tiles.dart';
import '../widgets/finance_common.dart';
import '../widgets/finance_date_field.dart';
import '../widgets/finance_form_parts.dart';
import '../widgets/finance_page.dart';

/// Новый расход или правка [expenseId].
///
/// Отдельного `GET /expenses/{id}` на бэкенде нет, поэтому список передаёт
/// расход в [initial]; по прямой ссылке он ищется в общем списке.
class FinanceExpenseFormScreen extends ConsumerWidget {
  const FinanceExpenseFormScreen({super.key, this.expenseId, this.initial});

  final int? expenseId;
  final Expense? initial;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final title = expenseId == null
        ? l10n.financeExpenseNewTitle
        : l10n.financeExpenseTitle;

    Widget page(Widget child) => FinancePage(title: title, children: [child]);
    const loading = Center(child: CircularProgressIndicator());

    final accounts = ref.watch(financeAccountsProvider);
    if (accounts.hasError && !accounts.hasValue) {
      return page(
        FinanceMessageCard.error(
          context,
          message: extractApiMessage(accounts.error!),
          onRetry: () => ref.invalidate(financeAccountsProvider),
        ),
      );
    }
    final accountList = accounts.valueOrNull;
    if (accountList == null) return page(loading);

    if (expenseId == null) {
      return _ExpenseForm(expense: null, accounts: accountList);
    }

    var expense = initial?.id == expenseId ? initial : null;
    if (expense == null) {
      const all = ExpenseFilter();
      final expenses = ref.watch(financeExpensesProvider(all));
      if (expenses.hasError && !expenses.hasValue) {
        return page(
          FinanceMessageCard.error(
            context,
            message: extractApiMessage(expenses.error!),
            onRetry: () => ref.invalidate(financeExpensesProvider(all)),
          ),
        );
      }
      final list = expenses.valueOrNull;
      if (list == null) return page(loading);
      expense = list.where((e) => e.id == expenseId).firstOrNull;
      if (expense == null) {
        return page(FinanceMessageCard(title: l10n.financeExpenseNotFound));
      }
    }
    return _ExpenseForm(
      key: ValueKey(expense.id),
      expense: expense,
      accounts: accountList,
    );
  }
}

class _ExpenseForm extends ConsumerStatefulWidget {
  const _ExpenseForm({
    super.key,
    required this.expense,
    required this.accounts,
  });

  final Expense? expense;
  final List<FinanceAccount> accounts;

  @override
  ConsumerState<_ExpenseForm> createState() => _ExpenseFormState();
}

class _ExpenseFormState extends ConsumerState<_ExpenseForm> {
  late final TextEditingController _name;
  late final TextEditingController _amount;
  late final TextEditingController _comment;
  ExpenseCategory? _category;
  int? _accountId;
  late DateTime _date;

  String? _categoryError;
  String? _nameError;
  String? _amountError;
  String? _saveError;
  bool _saving = false;

  Expense? get _expense => widget.expense;

  @override
  void initState() {
    super.initState();
    final expense = _expense;
    _name = TextEditingController(text: expense?.name ?? '');
    _amount = TextEditingController(
      text: expense == null
          ? ''
          : DecimalInputFormatter.money.formatText(
              expense.amount.toPlainString(),
            ),
    );
    _comment = TextEditingController(text: expense?.comment ?? '');
    _category = expense?.category;
    _date = expense?.expenseDate ?? ref.read(financeTodayProvider);
    _accountId =
        expense?.accountId ??
        pickDefaultAccount(
          widget.accounts,
          ref.read(financeLastAccountProvider),
        )?.id;
  }

  @override
  void didUpdateWidget(_ExpenseForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Счёт создали прямо из формы — сразу выбираем его.
    _accountId ??= pickDefaultAccount(
      widget.accounts,
      ref.read(financeLastAccountProvider),
    )?.id;
  }

  @override
  void dispose() {
    _name.dispose();
    _amount.dispose();
    _comment.dispose();
    super.dispose();
  }

  /// Активные счета и счёт этой записи, даже если он уже скрыт.
  List<FinanceAccount> get _choices => [
    for (final account in widget.accounts)
      if (account.active || account.id == _expense?.accountId) account,
  ];

  FinanceAccount? get _account =>
      widget.accounts.where((a) => a.id == _accountId).firstOrNull;

  /// Каким станет остаток выбранного счёта после сохранения.
  String? _balancePreview(FinanceFormat format) {
    final account = _account;
    final amount = Money.tryParse(_amount.text);
    if (account == null || amount == null || !amount.isPositive) return null;
    final expense = _expense;
    // Ничего, что влияет на остаток, не поменяли — и писать нечего.
    if (expense != null &&
        expense.amount == amount &&
        expense.accountId == account.id) {
      return null;
    }
    // При правке старая сумма уже вычтена из остатка этого счёта.
    final base = expense != null && expense.accountId == account.id
        ? account.balance + expense.amount
        : account.balance;
    return context.l10n.financeBalanceWillBe(
      account.name,
      format.money(base - amount),
    );
  }

  Future<void> _save() async {
    final l10n = context.l10n;
    final name = _name.text.trim();
    final amount = Money.tryParse(_amount.text);
    final category = _category;
    final accountId = _accountId;
    setState(() {
      _categoryError = category == null
          ? l10n.financeExpenseCategoryError
          : null;
      _nameError = name.isEmpty ? l10n.financeExpenseNameError : null;
      _amountError = amount == null || !amount.isPositive
          ? l10n.financeAmountError
          : null;
      _saveError = null;
    });
    if (category == null ||
        accountId == null ||
        _nameError != null ||
        _amountError != null) {
      return;
    }

    final input = ExpenseInput(
      category: category,
      name: name,
      amount: amount!,
      expenseDate: _date,
      accountId: accountId,
      comment: _comment.text,
      cattleId: _expense?.cattleId,
    );
    final mutations = ref.read(financeMutationsProvider);
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _saving = true);
    try {
      final expense = _expense;
      if (expense == null) {
        await mutations.createExpense(input);
      } else {
        await mutations.updateExpense(expense.id, input);
      }
      if (!mounted) return;
      _showInList(input);
      closeFinancePage(context);
      showFinanceMessage(
        messenger,
        expense == null ? l10n.financeExpenseSaved : l10n.financeExpenseUpdated,
        aboveFab: true,
      );
    } catch (error) {
      if (mounted) setState(() => _saveError = extractApiMessage(error));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  /// Список после сохранения показывает месяц записи и не прячет её
  /// фильтром — фермер сразу видит, что расход на месте.
  void _showInList(ExpenseInput input) {
    ref.read(financeMonthProvider.notifier).state = monthStart(
      input.expenseDate,
    );
    final category = ref.read(financeExpenseCategoryFilterProvider.notifier);
    if (category.state != null && category.state != input.category) {
      category.state = null;
    }
    final account = ref.read(financeExpenseAccountFilterProvider.notifier);
    if (account.state != null && account.state != input.accountId) {
      account.state = null;
    }
  }

  Future<void> _delete(Expense expense) async {
    final l10n = context.l10n;
    final confirmed = await showConfirmDialog(
      context: context,
      title: l10n.financeExpenseDeleteConfirm(expense.name),
      confirmText: l10n.financeDeleteAction,
    );
    if (!confirmed || !mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    setState(() {
      _saving = true;
      _saveError = null;
    });
    try {
      await ref.read(financeMutationsProvider).deleteExpense(expense.id);
      if (!mounted) return;
      closeFinancePage(context);
      showFinanceMessage(messenger, l10n.financeExpenseDeleted, aboveFab: true);
    } catch (error) {
      if (mounted) setState(() => _saveError = extractApiMessage(error));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final format = FinanceFormat.of(context);
    final expense = _expense;
    final isNew = expense == null;
    final choices = _choices;
    final preview = _balancePreview(format);

    return FinancePage(
      title: isNew ? l10n.financeExpenseNewTitle : l10n.financeExpenseTitle,
      children: [
        FinanceLabeled(
          label: l10n.financeExpenseCategoryLabel,
          error: _categoryError,
          child: ExpenseCategoryTiles(
            selected: _category,
            onChanged: (category) => setState(() {
              _category = category;
              _categoryError = null;
            }),
          ),
        ),
        AppTextField(
          label: l10n.financeExpenseNameLabel,
          hintText: _category == ExpenseCategory.feed
              ? l10n.financeExpenseNameHintFeed
              : l10n.financeExpenseNameHint,
          controller: _name,
          errorText: _nameError,
          textCapitalization: TextCapitalization.sentences,
          inputFormatters: [LengthLimitingTextInputFormatter(200)],
          onChanged: (_) => setState(() => _nameError = null),
        ),
        DecimalField.money(
          label: l10n.financeAmountLabel,
          controller: _amount,
          errorText: _amountError,
          onChanged: (_) => setState(() => _amountError = null),
        ),
        FinanceLabeled(
          label: l10n.financeExpenseAccountLabel,
          child: choices.isEmpty
              ? const FinanceNoAccounts()
              : FinanceAccountChips(
                  accounts: choices,
                  selectedId: _accountId,
                  onSelected: (id) => setState(() => _accountId = id),
                ),
        ),
        FinanceDateField(
          label: l10n.financeDateLabel,
          value: _date,
          lastDate: ref.watch(financeTodayProvider),
          onChanged: (date) => setState(() => _date = date),
        ),
        AppTextField(
          label: l10n.financeCommentLabel,
          labelNote: l10n.financeOptional,
          hintText: l10n.financeExpenseCommentHint,
          controller: _comment,
          maxLines: 3,
          textCapitalization: TextCapitalization.sentences,
          inputFormatters: [LengthLimitingTextInputFormatter(2000)],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppPrimaryButton(
              text: isNew ? l10n.financeExpenseSaveNew : l10n.financeSave,
              isLoading: _saving,
              onPressed: _accountId == null ? null : _save,
            ),
            if (_saveError != null) ...[
              const SizedBox(height: 10),
              FinanceNote(_saveError!, color: AppColors.error),
            ],
            if (preview != null) ...[
              const SizedBox(height: 10),
              FinanceNote(preview),
            ],
            if (!isNew) ...[
              const SizedBox(height: 12),
              TextButton(
                onPressed: _saving ? null : () => _delete(expense),
                child: Text(
                  l10n.financeExpenseDelete,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.error,
                  ),
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}
