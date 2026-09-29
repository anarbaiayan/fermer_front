import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/core/localization/l10n_extension.dart';
import 'package:frontend/core/network/api_exceptions.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/widgets/app_primary_button.dart';
import 'package:frontend/core/widgets/app_text_field.dart';
import 'package:frontend/core/widgets/confirm_dialog.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../application/finance_providers.dart';
import '../../domain/entities/finance_date.dart';
import '../../domain/entities/finance_entities.dart';
import '../../domain/entities/finance_enums.dart';
import '../../domain/entities/finance_inputs.dart';
import '../../domain/entities/money.dart';
import '../finance_format.dart';
import '../widgets/decimal_field.dart';
import '../widgets/finance_chips.dart';
import '../widgets/finance_common.dart';
import '../widgets/finance_date_field.dart';
import '../widgets/finance_form_parts.dart';
import '../widgets/finance_page.dart';
import '../widgets/finance_segmented_control.dart';
import '../widgets/finance_sheet.dart';

/// Новая продажа или правка [saleId] (FP-502).
///
/// Отдельного `GET /sales/{id}` на бэкенде нет, поэтому список передаёт
/// продажу в [initial]; по прямой ссылке она ищется в общем списке.
/// Все продажи нужны форме и так: по ним покупатели сортируются «последние
/// сверху» и подставляются единица и цена из прошлой продажи.
class FinanceSaleFormScreen extends ConsumerWidget {
  const FinanceSaleFormScreen({super.key, this.saleId, this.initial});

  final int? saleId;
  final Sale? initial;

  static const _allSales = SaleFilter();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final title = saleId == null
        ? l10n.financeSaleNewTitle
        : l10n.financeSaleTitle;

    Widget page(Widget child) => FinancePage(title: title, children: [child]);
    const loading = Center(child: CircularProgressIndicator());

    final accounts = ref.watch(financeAccountsProvider);
    final buyers = ref.watch(financeCounterpartiesProvider);
    for (final (value, provider) in [
      (accounts, financeAccountsProvider),
      (buyers, financeCounterpartiesProvider),
    ]) {
      if (value.hasError && !value.hasValue) {
        return page(
          FinanceMessageCard.error(
            context,
            message: extractApiMessage(value.error!),
            onRetry: () => ref.invalidate(provider),
          ),
        );
      }
    }
    final history = ref.watch(financeSalesProvider(_allSales));
    final accountList = accounts.valueOrNull;
    final buyerList = buyers.valueOrNull;
    if (accountList == null || buyerList == null) return page(loading);
    if (!history.hasValue && !history.hasError) return page(loading);
    // Без истории форма работает, просто без подсказок.
    final sales = history.valueOrNull ?? const <Sale>[];

    if (saleId == null) {
      return _SaleForm(
        sale: null,
        accounts: accountList,
        buyers: buyerList,
        history: sales,
      );
    }

    var sale = initial?.id == saleId ? initial : null;
    if (sale == null) {
      if (history.hasError && !history.hasValue) {
        return page(
          FinanceMessageCard.error(
            context,
            message: extractApiMessage(history.error!),
            onRetry: () => ref.invalidate(financeSalesProvider(_allSales)),
          ),
        );
      }
      sale = sales.where((s) => s.id == saleId).firstOrNull;
      if (sale == null) {
        return page(FinanceMessageCard(title: l10n.financeSaleNotFound));
      }
    }
    return _SaleForm(
      key: ValueKey(sale.id),
      sale: sale,
      accounts: accountList,
      buyers: buyerList,
      history: sales,
    );
  }
}

class _SaleForm extends ConsumerStatefulWidget {
  const _SaleForm({
    super.key,
    required this.sale,
    required this.accounts,
    required this.buyers,
    required this.history,
  });

  final Sale? sale;
  final List<FinanceAccount> accounts;
  final List<Counterparty> buyers;
  final List<Sale> history;

  @override
  ConsumerState<_SaleForm> createState() => _SaleFormState();
}

class _SaleFormState extends ConsumerState<_SaleForm> {
  /// Сколько недавних покупателей видно чипами; остальные — в шторке.
  static const _visibleBuyers = 5;

  /// Сколько своих товаров из прошлых продаж показывать чипами.
  static const _visibleCustomProducts = 6;

  late final TextEditingController _productName;
  late final TextEditingController _quantity;
  late final TextEditingController _price;
  late final TextEditingController _comment;
  final _productFocus = FocusNode();

  int? _buyerId;

  /// Выбранный чип товара; при «Другое» название вводится в поле.
  String? _product;
  bool _otherProduct = false;
  late SaleUnit _unit;
  late bool _paid;
  int? _accountId;
  late DateTime _saleDate;
  late DateTime _dueDate;

  /// Срок долга меняли руками — он больше не следует за датой продажи.
  late bool _dueEdited;

  /// Цена подставлена из прошлой продажи, а не введена: её можно заменить
  /// подсказкой для другого товара или покупателя.
  bool _priceFromHint = false;
  String? _priceHint;

  String? _buyerError;
  String? _productError;
  String? _quantityError;
  String? _priceError;
  String? _accountError;
  String? _saveError;
  bool _saving = false;

  Sale? get _sale => widget.sale;

  @override
  void initState() {
    super.initState();
    final sale = _sale;
    final today = ref.read(financeTodayProvider);
    _productName = TextEditingController();
    _quantity = TextEditingController(
      text: sale == null
          ? ''
          : const DecimalInputFormatter(
              maxIntegerDigits: 9,
              maxFractionDigits: 3,
            ).formatText(sale.quantity.toPlainString()),
    );
    _price = TextEditingController(
      text: sale == null
          ? ''
          : DecimalInputFormatter.money.formatText(
              sale.pricePerUnit.toPlainString(),
            ),
    );
    _comment = TextEditingController(text: sale?.comment ?? '');
    _buyerId = sale?.counterpartyId;
    _product = sale?.productName;
    _unit = sale?.unit ?? SaleUnit.liter;
    _paid = sale?.paid ?? true;
    _accountId = sale?.paid == true
        ? sale!.accountId
        : pickDefaultAccount(
            widget.accounts,
            ref.read(financeLastAccountProvider),
          )?.id;
    _saleDate = sale?.saleDate ?? today;
    final defaultDue = SaleInput.defaultDueDate(_saleDate);
    _dueDate = sale?.dueDate ?? defaultDue;
    _dueEdited = _dueDate != defaultDue;
  }

  @override
  void didUpdateWidget(_SaleForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Счёт создали прямо из формы — сразу выбираем его.
    _accountId ??= pickDefaultAccount(
      widget.accounts,
      ref.read(financeLastAccountProvider),
    )?.id;
  }

  @override
  void dispose() {
    _productName.dispose();
    _quantity.dispose();
    _price.dispose();
    _comment.dispose();
    _productFocus.dispose();
    super.dispose();
  }

  // ---- товар и подсказка цены ----

  String get _productText =>
      (_otherProduct ? _productName.text : _product ?? '').trim();

  /// Товары из прошлых продаж, которых нет в общем списке ни на одном
  /// языке, — свежие первыми.
  List<String> _customProducts(List<String> pastNames) {
    final lastSale = <String, DateTime>{};
    for (final sale in widget.history) {
      final key = saleProductKey(sale.productName);
      final known = lastSale[key];
      if (known == null || sale.saleDate.isAfter(known)) {
        lastSale[key] = sale.saleDate;
      }
    }
    final seen = <String>{};
    final names = <String>[
      for (final name in [?_sale?.productName, ...pastNames])
        if (SaleProduct.matching(name) == null &&
            seen.add(saleProductKey(name)))
          name.trim(),
    ];
    final current = _sale == null ? null : saleProductKey(_sale!.productName);
    names.sort((a, b) {
      // Товар этой продажи всегда виден, даже если он давний.
      if (saleProductKey(a) == current) return -1;
      if (saleProductKey(b) == current) return 1;
      final aLast = lastSale[saleProductKey(a)] ?? DateTime(0);
      final bLast = lastSale[saleProductKey(b)] ?? DateTime(0);
      return bLast.compareTo(aLast);
    });
    return names.take(_visibleCustomProducts).toList();
  }

  void _selectProduct(String name, {SaleUnit? unit}) {
    setState(() {
      _otherProduct = false;
      _product = name;
      _productError = null;
      _applyPriceHint(setUnit: true, fallbackUnit: unit);
    });
  }

  void _selectOtherProduct() {
    if (_otherProduct) return;
    setState(() {
      _otherProduct = true;
      _product = null;
      _productName.clear();
      _productError = null;
      _dropHintedPrice();
    });
    _productFocus.requestFocus();
  }

  /// Единица и цена из прошлой продажи этого товара (решение Р4). Цену,
  /// которую фермер ввёл сам, не трогаем.
  void _applyPriceHint({bool setUnit = false, SaleUnit? fallbackUnit}) {
    final last = lastSaleOf(widget.history, _productText, _buyerId);
    if (setUnit) _unit = last?.unit ?? fallbackUnit ?? _unit;
    if (last == null) {
      _dropHintedPrice();
      return;
    }
    if (_price.text.isNotEmpty && !_priceFromHint) return;
    final l10n = context.l10n;
    final price = FinanceFormat.of(context).money(last.pricePerUnit);
    _price.text = DecimalInputFormatter.money.formatText(
      last.pricePerUnit.toPlainString(),
    );
    _priceFromHint = true;
    _priceError = null;
    _priceHint = _buyerId != null && last.counterpartyId == _buyerId
        ? l10n.financeSalePriceHintBuyer(price)
        : l10n.financeSalePriceHintLast(price);
  }

  /// Цена из подсказки относилась к прошлому выбору — убираем её.
  void _dropHintedPrice() {
    if (_priceFromHint) _price.clear();
    _priceFromHint = false;
    _priceHint = null;
  }

  // ---- покупатель ----

  void _selectBuyer(int? id) {
    setState(() {
      _buyerId = id;
      _buyerError = null;
      _applyPriceHint();
    });
  }

  Future<void> _pickBuyer(List<Counterparty> buyers) async {
    final picked = await showFinancePickerSheet<int?>(
      context: context,
      title: context.l10n.financeAllBuyers,
      options: {
        null: context.l10n.financeNoBuyer,
        for (final buyer in buyers) buyer.id: buyer.name,
      },
      selected: _buyerId,
    );
    if (picked != null && mounted) _selectBuyer(picked.$1);
  }

  Future<void> _createBuyer() async {
    final created = await context.push<Counterparty>(
      '/finance/counterparties/new',
    );
    if (created != null && mounted) _selectBuyer(created.id);
  }

  // ---- счёт и остаток ----

  /// Активные счета и счёт этой продажи, даже если он уже скрыт.
  List<FinanceAccount> get _accountChoices => [
    for (final account in widget.accounts)
      if (account.active || account.id == _sale?.accountId) account,
  ];

  FinanceAccount? _findAccount(int? id) =>
      widget.accounts.where((a) => a.id == id).firstOrNull;

  Money? get _estimatedAmount {
    final quantity = Quantity.tryParse(_quantity.text);
    final price = Money.tryParse(_price.text);
    if (quantity == null || price == null) return null;
    if (!quantity.isPositive || price.isNegative) return null;
    return quantity.times(price);
  }

  /// Что станет с остатками после сохранения (решение Р8). Долг остатки
  /// не меняет — об этом и говорим; правка оплаченной продажи сначала
  /// возвращает старую сумму.
  String? _balanceNote(FinanceFormat format, Money? amount) {
    final l10n = context.l10n;
    final sale = _sale;
    if (amount == null || !amount.isPositive) return null;
    final wasPaidTo = sale != null && sale.paid ? sale.accountId : null;

    if (!_paid) {
      final old = _findAccount(wasPaidTo);
      if (old == null) return l10n.financeSaleDebtNote;
      return l10n.financeBalanceWillBe(
        old.name,
        format.money(old.balance - sale!.amount),
      );
    }
    final account = _findAccount(_accountId);
    if (account == null) return null;
    if (wasPaidTo == account.id && sale!.amount == amount) return null;
    final base = wasPaidTo == account.id
        ? account.balance - sale!.amount
        : account.balance;
    return l10n.financeBalanceWillBe(account.name, format.money(base + amount));
  }

  /// Дата оплаты: у новой оплаченной продажи — день продажи; у уже
  /// оплаченной — прежняя; долг, отмеченный оплаченным при правке, —
  /// сегодня. Раньше продажи оплата не бывает.
  DateTime _paidAt() {
    final sale = _sale;
    final DateTime date;
    if (sale == null) {
      date = _saleDate;
    } else if (sale.paid && sale.paidAt != null) {
      date = sale.paidAt!;
    } else {
      date = ref.read(financeTodayProvider);
    }
    return date.isBefore(_saleDate) ? _saleDate : date;
  }

  // ---- сохранение ----

  Future<void> _save() async {
    final l10n = context.l10n;
    final product = _productText;
    final quantity = Quantity.tryParse(_quantity.text);
    final price = Money.tryParse(_price.text);
    final account = _paid ? _findAccount(_accountId) : null;
    setState(() {
      _productError = !_otherProduct && _product == null
          ? l10n.financeSaleProductError
          : product.isEmpty
          ? l10n.financeSaleProductNameError
          : null;
      _quantityError = quantity == null || !quantity.isPositive
          ? l10n.financeSaleQuantityError
          : null;
      _priceError = price == null || !price.isPositive
          ? l10n.financeSalePriceError
          : null;
      // Долг без имени не напомнить и не показать в долгах (решение Р6).
      _buyerError = !_paid && _buyerId == null
          ? l10n.financeSaleDebtBuyerError
          : null;
      // Бэкенд не принимает оплату на скрытый счёт даже при правке.
      _accountError = account != null && !account.active
          ? l10n.financeSaleHiddenAccountError
          : null;
      _saveError = null;
    });
    if (_productError != null ||
        _quantityError != null ||
        _priceError != null ||
        _buyerError != null ||
        _accountError != null ||
        (_paid && account == null)) {
      return;
    }

    final input = SaleInput(
      counterpartyId: _buyerId,
      saleDate: _saleDate,
      productName: product,
      quantity: quantity!,
      unit: _unit,
      pricePerUnit: price!,
      paid: _paid,
      accountId: account?.id,
      paidAt: _paid ? _paidAt() : null,
      dueDate: _paid ? null : _dueDate,
      comment: _comment.text,
    );
    final mutations = ref.read(financeMutationsProvider);
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _saving = true);
    try {
      final sale = _sale;
      final saved = sale == null
          ? await mutations.createSale(input)
          : await mutations.updateSale(sale.id, input);
      if (!mounted) return;
      _showInList(saved);
      closeFinancePage(context);
      showFinanceMessage(
        messenger,
        sale == null ? l10n.financeSaleSaved : l10n.financeSaleUpdated,
        aboveFab: true,
      );
    } catch (error) {
      if (mounted) setState(() => _saveError = extractApiMessage(error));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  /// Список после сохранения показывает месяц продажи и не прячет её
  /// фильтром — фермер сразу видит, что продажа на месте.
  void _showInList(Sale sale) {
    ref.read(financeMonthProvider.notifier).state = monthStart(sale.saleDate);
    final filter = ref.read(financeIncomeFilterProvider.notifier);
    if (!filter.state.matches(sale, ref.read(financeTodayProvider))) {
      filter.state = IncomeFilter.all;
    }
  }

  Future<void> _delete(Sale sale) async {
    final l10n = context.l10n;
    final format = FinanceFormat.of(context);
    final name =
        '${sale.productName}, ${format.quantity(sale.quantity)} '
        '${sale.unit.localizedLabel(l10n)}';
    final confirmed = await showConfirmDialog(
      context: context,
      title: l10n.financeSaleDeleteConfirm(name),
      confirmText: l10n.financeDeleteAction,
    );
    if (!confirmed || !mounted) return;

    final messenger = ScaffoldMessenger.of(context);
    setState(() {
      _saving = true;
      _saveError = null;
    });
    try {
      await ref.read(financeMutationsProvider).deleteSale(sale.id);
      if (!mounted) return;
      closeFinancePage(context);
      showFinanceMessage(messenger, l10n.financeSaleDeleted, aboveFab: true);
    } catch (error) {
      if (mounted) setState(() => _saveError = extractApiMessage(error));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  // ---- экран ----

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final format = FinanceFormat.of(context);
    final sale = _sale;
    final isNew = sale == null;
    final amount = _estimatedAmount;
    final note = _balanceNote(format, amount);
    final accountChoices = _accountChoices;
    final unitLabel = _unit.localizedLabel(l10n);

    return FinancePage(
      title: isNew ? l10n.financeSaleNewTitle : l10n.financeSaleTitle,
      children: [
        _buyerField(),
        _productField(),
        FinanceLabeled(
          label: l10n.financeSaleQuantityLabel,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: DecimalField(
                  label: '',
                  controller: _quantity,
                  errorText: _quantityError,
                  maxIntegerDigits: 9,
                  maxFractionDigits: 3,
                  onChanged: (_) => setState(() => _quantityError = null),
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                width: 150,
                child: FinanceSegmentedControl<SaleUnit>(
                  segments: {
                    for (final unit in SaleUnit.values)
                      unit: unit.localizedLabel(l10n),
                  },
                  selected: _unit,
                  onChanged: (unit) => setState(() => _unit = unit),
                ),
              ),
            ],
          ),
        ),
        DecimalField.money(
          label: l10n.financeSalePriceLabel(unitLabel),
          controller: _price,
          errorText: _priceError,
          helperText: _priceHint,
          onChanged: (_) => setState(() {
            _priceError = null;
            _priceFromHint = false;
            _priceHint = null;
          }),
        ),
        FinanceAmountBox(
          label: l10n.financeAmountLabel,
          caption: l10n.financeSaleAmountNote,
          amount: format.money(amount ?? Money.zero),
        ),
        FinanceLabeled(
          label: l10n.financeSalePaymentLabel,
          child: FinanceSegmentedControl<bool>(
            segments: {
              true: l10n.financeSaleStatusPaid,
              false: l10n.financeSaleStatusDebt,
            },
            selected: _paid,
            onChanged: (paid) => setState(() {
              _paid = paid;
              _buyerError = null;
              _accountError = null;
            }),
          ),
        ),
        if (_paid)
          FinanceLabeled(
            label: l10n.financePayAccountLabel,
            error: _accountError,
            child: accountChoices.isEmpty
                ? const FinanceNoAccounts()
                : FinanceAccountChips(
                    accounts: accountChoices,
                    selectedId: _accountId,
                    onSelected: (id) => setState(() {
                      _accountId = id;
                      _accountError = null;
                    }),
                  ),
          )
        else
          FinanceDateField(
            label: l10n.financeSaleDueLabel,
            value: _dueDate,
            firstDate: _saleDate,
            hint: _dueDate == SaleInput.defaultDueDate(_saleDate)
                ? l10n.financeSaleDueHint(kDefaultDebtDays)
                : null,
            onChanged: (date) => setState(() {
              _dueDate = date;
              _dueEdited = true;
            }),
          ),
        FinanceDateField(
          label: l10n.financeSaleDateLabel,
          value: _saleDate,
          lastDate: ref.watch(financeTodayProvider),
          onChanged: (date) => setState(() {
            _saleDate = date;
            // Срок по умолчанию считается от даты продажи (правило 2).
            if (!_dueEdited || _dueDate.isBefore(date)) {
              _dueDate = SaleInput.defaultDueDate(date);
              _dueEdited = false;
            }
          }),
        ),
        AppTextField(
          label: l10n.financeCommentLabel,
          labelNote: l10n.financeOptional,
          hintText: l10n.financeSaleCommentHint,
          controller: _comment,
          maxLines: 3,
          textCapitalization: TextCapitalization.sentences,
          inputFormatters: [LengthLimitingTextInputFormatter(2000)],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppPrimaryButton(
              text: isNew ? l10n.financeSaleSaveNew : l10n.financeSave,
              isLoading: _saving,
              onPressed: _paid && accountChoices.isEmpty ? null : _save,
            ),
            if (_saveError != null) ...[
              const SizedBox(height: 10),
              FinanceNote(_saveError!, color: AppColors.error),
            ],
            if (note != null) ...[
              const SizedBox(height: 10),
              FinanceNote(note),
            ],
            if (!isNew) ...[
              const SizedBox(height: 12),
              TextButton(
                onPressed: _saving ? null : () => _delete(sale),
                child: Text(
                  l10n.financeSaleDelete,
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

  /// Покупатели: недавние чипами, остальные — в шторке «Все покупатели».
  Widget _buyerField() {
    final l10n = context.l10n;
    final recent = recentCounterparties(widget.buyers, widget.history);
    final visible = recent.take(_visibleBuyers).toList();
    // Выбранный покупатель виден всегда: новый, давний или уже скрытый.
    final selected = widget.buyers.where((b) => b.id == _buyerId).firstOrNull;
    if (selected != null && !visible.any((b) => b.id == selected.id)) {
      visible.add(selected);
    }

    return FinanceLabeled(
      label: l10n.financeSaleBuyerLabel,
      note: l10n.financeSaleBuyerNote,
      error: _buyerError,
      child: FinanceChipRow(
        wrap: true,
        children: [
          for (final buyer in visible)
            FinanceChip(
              label: buyer.name,
              selected: buyer.id == _buyerId,
              onTap: () => _selectBuyer(buyer.id),
            ),
          FinanceChip(
            label: l10n.financeNoBuyer,
            selected: _buyerId == null,
            onTap: () => _selectBuyer(null),
          ),
          if (recent.length > _visibleBuyers)
            FinanceChip(
              label: l10n.financeAllBuyers,
              trailingIcon: Icons.expand_more_rounded,
              onTap: () => _pickBuyer(recent),
            ),
          FinanceChip.add(label: l10n.financeNewBuyer, onTap: _createBuyer),
        ],
      ),
    );
  }

  /// Товар: общий список, свои товары из прошлых продаж и «Другое» с
  /// подсказками по прошлым названиям (ТЗ: автоподсказка из прошлых
  /// записей). В API уходит свободный текст.
  Widget _productField() {
    final l10n = context.l10n;
    final pastNames =
        ref.watch(financeProductNamesProvider).valueOrNull ?? const [];
    final custom = _customProducts(pastNames);
    // Сохранённое «Молоко» выделяет чип «Сүт» в казахском интерфейсе.
    bool isSelected(String name) =>
        !_otherProduct &&
        _product != null &&
        saleProductKey(_product!) == saleProductKey(name);

    final typed = _productName.text.trim().toLowerCase();
    final suggestions = !_otherProduct || typed.isEmpty
        ? const <String>[]
        : pastNames
              .where((name) {
                final key = name.toLowerCase();
                return key.contains(typed) && key != typed;
              })
              .take(4)
              .toList();

    return FinanceLabeled(
      label: l10n.financeSaleProductLabel,
      error: _productError,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FinanceChipRow(
            wrap: true,
            children: [
              for (final product in SaleProduct.values)
                FinanceChip(
                  label: product.localizedLabel(l10n),
                  selected: isSelected(product.localizedLabel(l10n)),
                  onTap: () => _selectProduct(
                    product.localizedLabel(l10n),
                    unit: product.defaultUnit,
                  ),
                ),
              for (final name in custom)
                FinanceChip(
                  label: name,
                  selected: isSelected(name),
                  onTap: () => _selectProduct(name),
                ),
              FinanceChip(
                label: l10n.financeProductOther,
                selected: _otherProduct,
                onTap: _selectOtherProduct,
              ),
            ],
          ),
          if (_otherProduct) ...[
            const SizedBox(height: 10),
            AppTextField(
              label: '',
              hintText: l10n.financeSaleProductHint,
              controller: _productName,
              focusNode: _productFocus,
              textCapitalization: TextCapitalization.sentences,
              inputFormatters: [LengthLimitingTextInputFormatter(200)],
              onChanged: (_) => setState(() => _productError = null),
            ),
            if (suggestions.isNotEmpty) ...[
              const SizedBox(height: 8),
              FinanceChipRow(
                children: [
                  for (final name in suggestions)
                    FinanceChip(
                      label: name,
                      onTap: () => setState(() {
                        _productName.text = name;
                        _productError = null;
                        _applyPriceHint(setUnit: true);
                      }),
                    ),
                ],
              ),
            ],
          ],
        ],
      ),
    );
  }
}
