import 'package:frontend/l10n/app_localizations.dart';

/// Тип счёта (`AccountType` на бэкенде).
enum AccountType {
  cash('CASH'),
  card('CARD'),
  bank('BANK');

  const AccountType(this.apiValue);

  final String apiValue;

  /// Неизвестное значение читаем как наличные: тип влияет только на иконку.
  static AccountType fromApi(Object? value) => values.firstWhere(
    (type) => type.apiValue == value?.toString().toUpperCase(),
    orElse: () => AccountType.cash,
  );

  String localizedLabel(AppLocalizations l10n) => switch (this) {
    AccountType.cash => l10n.financeAccountTypeCash,
    AccountType.card => l10n.financeAccountTypeCard,
    AccountType.bank => l10n.financeAccountTypeBank,
  };
}

/// Категория расхода. По ТЗ — фиксированный список в коде, не справочник.
enum ExpenseCategory {
  feed('FEED'),
  veterinary('VETERINARY'),
  salary('SALARY'),
  fuel('FUEL'),
  rent('RENT'),
  equipment('EQUIPMENT'),
  other('OTHER');

  const ExpenseCategory(this.apiValue);

  final String apiValue;

  /// Неизвестная категория попадает в «Прочее», а не теряется из сумм.
  static ExpenseCategory fromApi(Object? value) => values.firstWhere(
    (category) => category.apiValue == value?.toString().toUpperCase(),
    orElse: () => ExpenseCategory.other,
  );

  String localizedLabel(AppLocalizations l10n) => switch (this) {
    ExpenseCategory.feed => l10n.financeCategoryFeed,
    ExpenseCategory.veterinary => l10n.financeCategoryVeterinary,
    ExpenseCategory.salary => l10n.financeCategorySalary,
    ExpenseCategory.fuel => l10n.financeCategoryFuel,
    ExpenseCategory.rent => l10n.financeCategoryRent,
    ExpenseCategory.equipment => l10n.financeCategoryEquipment,
    ExpenseCategory.other => l10n.financeCategoryOther,
  };
}

/// Единица продажи (`SaleUnit` на бэкенде).
enum SaleUnit {
  liter('L'),
  kilogram('KG'),
  piece('PCS');

  const SaleUnit(this.apiValue);

  final String apiValue;

  static SaleUnit fromApi(Object? value) => values.firstWhere(
    (unit) => unit.apiValue == value?.toString().toUpperCase(),
    orElse: () => SaleUnit.piece,
  );

  String localizedLabel(AppLocalizations l10n) => switch (this) {
    SaleUnit.liter => l10n.financeUnitLiter,
    SaleUnit.kilogram => l10n.financeUnitKg,
    SaleUnit.piece => l10n.financeUnitPiece,
  };
}

/// Типы PDF-отчёта из ТЗ (`GET /api/finance/report/pdf?type=`).
enum FinanceReportType {
  full('FULL'),
  income('INCOME'),
  expense('EXPENSE'),
  debts('DEBTS');

  const FinanceReportType(this.apiValue);

  final String apiValue;
}

/// Товар для быстрого выбора в форме продажи.
///
/// В API уходит свободный текст `productName`, поэтому название берётся
/// из локализации: фермер видит и сохраняет его на своём языке. Единица
/// подставляется в форму, но её можно поменять.
enum SaleProduct {
  kurt(SaleUnit.kilogram),
  butter(SaleUnit.kilogram),
  sourCream(SaleUnit.kilogram),
  milk(SaleUnit.liter),
  kefir(SaleUnit.liter),
  cottageCheese(SaleUnit.kilogram),
  ghee(SaleUnit.kilogram),
  cheese(SaleUnit.kilogram);

  const SaleProduct(this.defaultUnit);

  final SaleUnit defaultUnit;

  String localizedLabel(AppLocalizations l10n) => switch (this) {
    SaleProduct.kurt => l10n.financeProductKurt,
    SaleProduct.butter => l10n.financeProductButter,
    SaleProduct.sourCream => l10n.financeProductSourCream,
    SaleProduct.milk => l10n.financeProductMilk,
    SaleProduct.kefir => l10n.financeProductKefir,
    SaleProduct.cottageCheese => l10n.financeProductCottageCheese,
    SaleProduct.ghee => l10n.financeProductGhee,
    SaleProduct.cheese => l10n.financeProductCheese,
  };

  /// Товар из списка по сохранённому названию, без учёта регистра.
  /// `null` — название введено вручную («Другое»).
  static SaleProduct? matching(String name, AppLocalizations l10n) {
    final key = name.trim().toLowerCase();
    for (final product in values) {
      if (product.localizedLabel(l10n).toLowerCase() == key) return product;
    }
    return null;
  }
}
