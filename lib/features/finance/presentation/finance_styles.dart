import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_colors.dart';

import '../domain/entities/finance_enums.dart';

/// Цвета «Финансов» поверх общей палитры приложения. Красный — только для
/// просрочек: расходы показываются тёмным со знаком минус.
abstract final class FinanceColors {
  /// Светло-зелёная подложка выбранного и итоговых блоков.
  static const softGreen = Color(0xFFE7EFE9);

  /// Заливка полей и сегментного переключателя.
  static const fieldFill = Color(0xFFEFEFEF);

  static const paidBackground = Color(0xFFE3F2E7);
  static const paidText = Color(0xFF2E7D46);
  static const dueBackground = Color(0xFFF6ECE5);
  static const dueText = Color(0xFF8C4B2B);
  static const overdueBackground = Color(0xFFFDE7E7);
  static const overdueText = Color(0xFFC62828);

  /// Карточка долгов на сводке и главной.
  static const debtCardBackground = Color(0xFFFFF9F8);
  static const debtCardBorder = Color(0xFFF3C9C4);

  /// Полоска расходов на сводке.
  static const expenseBar = Color(0xFFC9A48E);

  static const blue = Color(0xFF4A78C1);
}

/// Иконка из `assets/icons` и цвет плитки категории расхода.
///
/// Иконки топлива, аренды, оборудования и «прочего» — временные из прототипа,
/// до отрисовки дизайнером.
extension ExpenseCategoryStyle on ExpenseCategory {
  String get iconName => switch (this) {
    ExpenseCategory.feed => 'diet1',
    ExpenseCategory.veterinary => 'medicine',
    ExpenseCategory.salary => 'user',
    ExpenseCategory.fuel => 'fuel',
    ExpenseCategory.rent => 'key',
    ExpenseCategory.equipment => 'wrench',
    ExpenseCategory.other => 'box',
  };

  Color get color => switch (this) {
    ExpenseCategory.feed => AppColors.primary2,
    ExpenseCategory.veterinary => AppColors.accent,
    ExpenseCategory.salary => FinanceColors.blue,
    ExpenseCategory.fuel => const Color(0xFFC98A2B),
    ExpenseCategory.rent => const Color(0xFF8A6B4E),
    ExpenseCategory.equipment => const Color(0xFF5D7B88),
    ExpenseCategory.other => const Color(0xFF8E949A),
  };
}

/// Иконки счетов — временные из прототипа.
extension AccountTypeStyle on AccountType {
  String get iconName => switch (this) {
    AccountType.cash => 'cash',
    AccountType.card => 'card',
    AccountType.bank => 'bank',
  };
}
