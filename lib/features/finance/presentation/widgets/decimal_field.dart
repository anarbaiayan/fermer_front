import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/widgets/app_text_field.dart';

import '../finance_format.dart';

/// Ввод десятичного числа с разрядами: `1 450 000`, `12,5`.
///
/// Принимает запятую и точку, показывает запятую. Ограничивает знаки
/// до и после запятой под колонки бэкенда: `numeric(15,2)` для денег,
/// `numeric(12,3)` для количества. Курсор остаётся после той же цифры.
class DecimalInputFormatter extends TextInputFormatter {
  const DecimalInputFormatter({
    this.maxIntegerDigits = 13,
    this.maxFractionDigits = 2,
  });

  final int maxIntegerDigits;
  final int maxFractionDigits;

  /// Сумма в тенге: `numeric(15,2)`.
  static const money = DecimalInputFormatter();

  /// Текст для поля из готового числа, например при правке записи.
  String formatText(String raw) => formatEditUpdate(
    TextEditingValue.empty,
    TextEditingValue(
      text: raw,
      selection: TextSelection.collapsed(offset: raw.length),
    ),
  ).text;

  static const _groupSeparator = '\u00A0';
  static const _decimalSeparator = ',';

  static bool _isDigit(String ch) =>
      ch.codeUnitAt(0) >= 0x30 && ch.codeUnitAt(0) <= 0x39;

  static bool _isSeparator(String ch) => ch == ',' || ch == '.';

  static String _significant(String text) =>
      text.split('').where((ch) => _isDigit(ch) || _isSeparator(ch)).join();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    var raw = newValue.text;
    var caret = newValue.selection.isValid
        ? newValue.selection.extentOffset.clamp(0, raw.length)
        : raw.length;

    // Стёрли только пробел между разрядами — стираем цифру перед ним.
    if (raw.length < oldValue.text.length &&
        _significant(raw) == _significant(oldValue.text) &&
        caret > 0) {
      final before = raw.substring(0, caret);
      final index = before.lastIndexOf(RegExp(r'[0-9]'));
      if (index >= 0) {
        raw = raw.substring(0, index) + raw.substring(index + 1);
        caret = index;
      }
    }

    final integer = StringBuffer();
    final fraction = StringBuffer();
    var hasSeparator = false;
    var keptBeforeCaret = 0;
    for (var i = 0; i < raw.length; i++) {
      final ch = raw[i];
      if (_isDigit(ch)) {
        if (!hasSeparator) {
          integer.write(ch);
        } else if (fraction.length < maxFractionDigits) {
          fraction.write(ch);
        } else {
          continue;
        }
      } else if (_isSeparator(ch) && !hasSeparator && maxFractionDigits > 0) {
        hasSeparator = true;
      } else {
        continue;
      }
      if (i < caret) keptBeforeCaret++;
    }

    var digits = integer.toString();
    final stripped = digits.replaceFirst(RegExp(r'^0+(?=\d)'), '');
    keptBeforeCaret -= digits.length - stripped.length;
    digits = stripped;
    if (digits.isEmpty && hasSeparator) {
      digits = '0';
      keptBeforeCaret++;
    }
    if (digits.length > maxIntegerDigits) return oldValue;
    if (keptBeforeCaret < 0) keptBeforeCaret = 0;

    final text = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) text.write(_groupSeparator);
      text.write(digits[i]);
    }
    if (hasSeparator) text.write('$_decimalSeparator$fraction');
    final formatted = text.toString();

    var offset = 0;
    var seen = 0;
    while (offset < formatted.length && seen < keptBeforeCaret) {
      if (formatted[offset] != _groupSeparator) seen++;
      offset++;
    }
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: offset),
    );
  }
}

/// Поле числа в стиле [AppTextField] с единицей справа: `₸`, `л`.
class DecimalField extends StatelessWidget {
  const DecimalField({
    super.key,
    required this.label,
    required this.controller,
    this.hintText = '0',
    this.errorText,
    this.onChanged,
    this.suffix,
    this.maxIntegerDigits = 13,
    this.maxFractionDigits = 2,
  });

  /// Сумма в тенге: `numeric(15,2)`.
  const DecimalField.money({
    super.key,
    required this.label,
    required this.controller,
    this.hintText = '0',
    this.errorText,
    this.onChanged,
  }) : suffix = FinanceFormat.currency,
       maxIntegerDigits = 13,
       maxFractionDigits = 2;

  final String label;
  final TextEditingController controller;
  final String hintText;
  final String? errorText;
  final ValueChanged<String>? onChanged;
  final String? suffix;
  final int maxIntegerDigits;
  final int maxFractionDigits;

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      label: label,
      hintText: hintText,
      controller: controller,
      errorText: errorText,
      onChanged: onChanged,
      keyboardType: TextInputType.numberWithOptions(
        decimal: maxFractionDigits > 0,
      ),
      inputFormatters: [
        DecimalInputFormatter(
          maxIntegerDigits: maxIntegerDigits,
          maxFractionDigits: maxFractionDigits,
        ),
      ],
      suffixIcon: suffix == null
          ? null
          : Padding(
              padding: const EdgeInsets.only(right: 20),
              child: Center(
                widthFactor: 1,
                child: Text(
                  suffix!,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.additional3,
                  ),
                ),
              ),
            ),
    );
  }
}
