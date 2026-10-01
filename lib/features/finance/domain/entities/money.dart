import 'package:flutter/foundation.dart';

/// Сумма в тенге. Хранится целыми тиынами (1 ₸ = 100 тиын).
///
/// Бэкенд держит деньги в `numeric(15,2)`. Здесь та же точность без
/// арифметики на double, чтобы суммы не расходились с сервером на тиын.
@immutable
class Money implements Comparable<Money> {
  const Money.tiyn(this.tiyn);
  const Money.tenge(int tenge) : tiyn = tenge * 100;

  static const zero = Money.tiyn(0);

  final int tiyn;

  /// Разбирает ввод пользователя: `245 000`, `245000,5`, `12.34`.
  /// Пустая строка или мусор дают `null`.
  static Money? tryParse(String input) {
    final value = parseScaled(input, _scale);
    return value == null ? null : Money.tiyn(value);
  }

  /// Число из JSON бэкенда (BigDecimal приходит числом, реже строкой).
  static Money fromJson(Object? value) {
    final tiyn = scaledFromJson(value, _scale);
    if (tiyn == null) throw FormatException('Invalid money value: $value');
    return Money.tiyn(tiyn);
  }

  static Money? fromJsonOrNull(Object? value) =>
      value == null ? null : Money.fromJson(value);

  static Money sum(Iterable<Money> values) =>
      values.fold(zero, (total, value) => total + value);

  Object toJson() => scaledToJson(tiyn, _scale);

  /// Число без разделителей групп: `245000`, `245000.5`.
  String toPlainString({String decimalSeparator = '.'}) =>
      scaledToPlain(tiyn, _scale, decimalSeparator);

  bool get isZero => tiyn == 0;
  bool get isNegative => tiyn < 0;
  bool get isPositive => tiyn > 0;

  Money abs() => Money.tiyn(tiyn.abs());

  Money operator +(Money other) => Money.tiyn(tiyn + other.tiyn);
  Money operator -(Money other) => Money.tiyn(tiyn - other.tiyn);
  Money operator -() => Money.tiyn(-tiyn);

  bool operator <(Money other) => tiyn < other.tiyn;
  bool operator >(Money other) => tiyn > other.tiyn;

  @override
  int compareTo(Money other) => tiyn.compareTo(other.tiyn);

  @override
  bool operator ==(Object other) => other is Money && other.tiyn == tiyn;

  @override
  int get hashCode => tiyn.hashCode;

  @override
  String toString() => 'Money(${toPlainString()})';

  static const _scale = 2;
}

/// Количество товара в продаже. Бэкенд держит `numeric(12,3)`, поэтому
/// храним тысячные доли: 12,5 л — это 12 500.
@immutable
class Quantity implements Comparable<Quantity> {
  const Quantity.milli(this.milli);
  const Quantity.whole(int units) : milli = units * 1000;

  static const zero = Quantity.milli(0);

  final int milli;

  static Quantity? tryParse(String input) {
    final value = parseScaled(input, _scale);
    return value == null ? null : Quantity.milli(value);
  }

  static Quantity fromJson(Object? value) {
    final milli = scaledFromJson(value, _scale);
    if (milli == null) throw FormatException('Invalid quantity value: $value');
    return Quantity.milli(milli);
  }

  Object toJson() => scaledToJson(milli, _scale);

  String toPlainString({String decimalSeparator = '.'}) =>
      scaledToPlain(milli, _scale, decimalSeparator);

  bool get isPositive => milli > 0;

  /// Сумма продажи: количество × цена, округление до тиына вверх от
  /// половины (HALF_UP), как `setScale(2, HALF_UP)` на бэкенде.
  Money times(Money price) {
    final product = BigInt.from(milli) * BigInt.from(price.tiyn);
    final divisor = BigInt.from(1000);
    final half = BigInt.from(500);
    final rounded = product.isNegative
        ? -((-product + half) ~/ divisor)
        : (product + half) ~/ divisor;
    return Money.tiyn(rounded.toInt());
  }

  @override
  int compareTo(Quantity other) => milli.compareTo(other.milli);

  @override
  bool operator ==(Object other) => other is Quantity && other.milli == milli;

  @override
  int get hashCode => milli.hashCode;

  @override
  String toString() => 'Quantity(${toPlainString()})';

  static const _scale = 3;
}

const _maxDigits = 15;

int _pow10(int scale) {
  var factor = 1;
  for (var i = 0; i < scale; i++) {
    factor *= 10;
  }
  return factor;
}

/// Разбирает десятичную строку в целое, умноженное на 10^[scale].
/// Пробелы (включая неразрывные) игнорируются, разделитель — точка или
/// запятая. Лишние знаки после запятой округляются вверх от половины.
@visibleForTesting
int? parseScaled(String input, int scale) {
  var text = input.replaceAll(RegExp(r'\s'), '');
  var negative = false;
  if (text.startsWith('-') || text.startsWith('\u2212')) {
    negative = true;
    text = text.substring(1);
  } else if (text.startsWith('+')) {
    text = text.substring(1);
  }

  final match = RegExp(r'^(\d*)(?:[.,](\d*))?$').firstMatch(text);
  if (match == null) return null;
  final whole = match.group(1)!;
  final fraction = match.group(2) ?? '';
  if (whole.isEmpty && fraction.isEmpty) return null;
  if (whole.length > _maxDigits) return null;

  final factor = _pow10(scale);
  var value = (whole.isEmpty ? 0 : int.parse(whole)) * factor;
  if (scale > 0) {
    final kept = fraction.length > scale
        ? fraction.substring(0, scale)
        : fraction.padRight(scale, '0');
    value += int.parse(kept);
  }
  if (fraction.length > scale && fraction.codeUnitAt(scale) >= 0x35) {
    value += 1;
  }
  return negative ? -value : value;
}

@visibleForTesting
int? scaledFromJson(Object? value, int scale) {
  if (value is int) return value * _pow10(scale);
  if (value is double) {
    final text = value.toString();
    // Экспоненту double даёт только на очень больших или малых числах,
    // которых в деньгах фермы не бывает.
    if (text.contains(RegExp('[eE]'))) return (value * _pow10(scale)).round();
    return parseScaled(text, scale);
  }
  if (value is String) return parseScaled(value, scale);
  return null;
}

/// Значение для JSON. Целые уходят как int. Дробные — как double: это
/// только транспорт, `jsonEncode` печатает кратчайшее точное представление
/// (`145000.55`), и Jackson читает его в BigDecimal без потерь.
@visibleForTesting
Object scaledToJson(int scaled, int scale) {
  final factor = _pow10(scale);
  return scaled % factor == 0 ? scaled ~/ factor : scaled / factor;
}

@visibleForTesting
String scaledToPlain(int scaled, int scale, String decimalSeparator) {
  final factor = _pow10(scale);
  final sign = scaled < 0 ? '-' : '';
  final abs = scaled.abs();
  final whole = abs ~/ factor;
  final fraction = (abs % factor)
      .toString()
      .padLeft(scale, '0')
      .replaceFirst(RegExp(r'0+$'), '');
  return fraction.isEmpty
      ? '$sign$whole'
      : '$sign$whole$decimalSeparator$fraction';
}
