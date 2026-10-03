import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

import '../domain/entities/money.dart';

/// Форматы «Финансов» для текущего языка: `145 000 ₸`, `12,5`, `19.09.2026`.
///
/// Числа форматируются из целых тиынов и тысячных долей, без double.
/// Разряды разделяет неразрывный пробел, поэтому сумма не рвётся на строки.
class FinanceFormat {
  FinanceFormat(this.locale)
    : _groups = NumberFormat('#,##0', locale),
      _decimalSeparator = NumberFormat.decimalPattern(
        locale,
      ).symbols.DECIMAL_SEP;

  factory FinanceFormat.of(BuildContext context) =>
      FinanceFormat(Localizations.localeOf(context).languageCode);

  static const currency = '₸';

  /// Типографский минус: у расходов и отрицательной прибыли.
  static const minus = '\u2212';
  static const _nbsp = '\u00A0';

  final String locale;
  final NumberFormat _groups;
  final String _decimalSeparator;

  /// `145 000 ₸`, `−45 000 ₸`, `1 250,50 ₸`.
  String money(Money value) =>
      '${value.isNegative ? minus : ''}${amount(value.abs())}$_nbsp$currency';

  /// Со знаком всегда: `+ 830 000 ₸`, `− 12 000 ₸` — для прибыли.
  String signedMoney(Money value) =>
      '${value.isNegative ? minus : '+'}$_nbsp${money(value.abs())}';

  /// Сумма без знака валюты. Тиыны показываются, только если они есть,
  /// и всегда двумя знаками.
  String amount(Money value) {
    final tiyn = value.tiyn.abs();
    final sign = value.isNegative ? minus : '';
    final whole = _groups.format(tiyn ~/ 100);
    final fraction = tiyn % 100;
    if (fraction == 0) return '$sign$whole';
    return '$sign$whole$_decimalSeparator${fraction.toString().padLeft(2, '0')}';
  }

  /// `120`, `12,5`, `0,375`.
  String quantity(Quantity value) {
    final milli = value.milli.abs();
    final sign = value.milli < 0 ? minus : '';
    final whole = _groups.format(milli ~/ 1000);
    final fraction = (milli % 1000)
        .toString()
        .padLeft(3, '0')
        .replaceFirst(RegExp(r'0+$'), '');
    return fraction.isEmpty
        ? '$sign$whole'
        : '$sign$whole$_decimalSeparator$fraction';
  }

  /// `19.09.2026`.
  String date(DateTime day) => DateFormat('dd.MM.yyyy').format(day);

  /// `19.09` — в списках и статусах.
  String dayMonth(DateTime day) => DateFormat('dd.MM').format(day);

  /// `Сентябрь 2026` — заголовок переключателя месяцев.
  String month(DateTime month) =>
      _capitalize(DateFormat('LLLL y', locale).format(month));

  /// `сентябрь` — месяц без года внутри фразы: «Прибыль за сентябрь».
  String monthName(DateTime month) => DateFormat('LLLL', locale).format(month);

  /// `19 сентября` — заголовок дня в списке операций.
  String dayTitle(DateTime day) => DateFormat('d MMMM', locale).format(day);

  /// `19 сентября, чт`.
  String dayTitleWithWeekday(DateTime day) =>
      '${dayTitle(day)}, ${DateFormat('E', locale).format(day)}';

  static String _capitalize(String text) =>
      text.isEmpty ? text : text[0].toUpperCase() + text.substring(1);
}
