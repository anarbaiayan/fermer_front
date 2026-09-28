import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/finance/domain/entities/finance_date.dart';
import 'package:frontend/features/finance/domain/entities/finance_entities.dart';
import 'package:frontend/features/finance/domain/entities/finance_enums.dart';
import 'package:frontend/features/finance/domain/entities/money.dart';
import 'package:frontend/features/finance/presentation/finance_format.dart';
import 'package:frontend/features/finance/presentation/widgets/decimal_field.dart';
import 'package:intl/date_symbol_data_local.dart';

final nbsp = String.fromCharCode(0x00A0);
final minus = String.fromCharCode(0x2212);

Money tenge(int value) => Money.tenge(value);

Sale sale({bool paid = false, DateTime? dueDate, int tengeAmount = 1000}) =>
    Sale(
      id: 1,
      saleDate: DateTime.utc(2026, 9, 1),
      productName: 'Молоко',
      quantity: const Quantity.whole(1),
      unit: SaleUnit.liter,
      pricePerUnit: tenge(tengeAmount),
      amount: tenge(tengeAmount),
      paid: paid,
      dueDate: dueDate,
    );

void main() {
  setUpAll(() async {
    await initializeDateFormatting('ru');
    await initializeDateFormatting('kk');
  });

  group('Money parsing', () {
    test('reads user input with groups, comma and dot', () {
      expect(Money.tryParse('1${nbsp}450${nbsp}000'), tenge(1450000));
      expect(Money.tryParse('245 000'), tenge(245000));
      expect(Money.tryParse('12,5'), const Money.tiyn(1250));
      expect(Money.tryParse('12.34'), const Money.tiyn(1234));
      expect(Money.tryParse(',5'), const Money.tiyn(50));
      expect(Money.tryParse('-5'), tenge(-5));
      expect(Money.tryParse('${minus}5'), tenge(-5));
    });

    test('rejects empty and garbage input', () {
      expect(Money.tryParse(''), isNull);
      expect(Money.tryParse('  '), isNull);
      expect(Money.tryParse('abc'), isNull);
      expect(Money.tryParse('1,2,3'), isNull);
      expect(Money.tryParse(','), isNull);
    });

    test('rounds extra fraction digits half up', () {
      expect(Money.tryParse('1,005'), const Money.tiyn(101));
      expect(Money.tryParse('1,004'), const Money.tiyn(100));
      expect(Money.tryParse('-1,005'), const Money.tiyn(-101));
    });
  });

  group('Money JSON', () {
    test('reads BigDecimal as int, double or string without drift', () {
      expect(Money.fromJson(145000), tenge(145000));
      expect(Money.fromJson(145000.0), tenge(145000));
      expect(Money.fromJson(145000.55), const Money.tiyn(14500055));
      expect(Money.fromJson(0.1), const Money.tiyn(10));
      expect(Money.fromJson('245000.50'), const Money.tiyn(24500050));
      expect(Money.fromJsonOrNull(null), isNull);
      expect(() => Money.fromJson(true), throwsFormatException);
    });

    test('writes whole tenge as int and the rest as exact decimals', () {
      expect(tenge(145000).toJson(), 145000);
      expect(const Money.tiyn(550).toJson(), 5.5);
      expect(const Money.tiyn(14500055).toJson().toString(), '145000.55');
      expect(const Quantity.milli(12500).toJson(), 12.5);
      expect(const Quantity.whole(120).toJson(), 120);
    });

    test('plain string drops trailing zeros', () {
      expect(tenge(245000).toPlainString(), '245000');
      expect(const Money.tiyn(24500050).toPlainString(), '245000.5');
      expect(
        const Money.tiyn(-105).toPlainString(decimalSeparator: ','),
        '-1,05',
      );
    });
  });

  group('sale amount', () {
    test('quantity × price, as on the backend', () {
      expect(const Quantity.whole(120).times(tenge(250)), tenge(30000));
      expect(Quantity.tryParse('12,5')!.times(tenge(2200)), tenge(27500));
      expect(Quantity.tryParse('0,375')!.times(tenge(1)), const Money.tiyn(38));
    });

    test('rounds to tiyn half up', () {
      // 2,5 × 0,01 = 0,025 → 0,03
      expect(
        Quantity.tryParse('2,5')!.times(Money.tryParse('0,01')!),
        const Money.tiyn(3),
      );
      // 0,333 × 0,10 = 0,0333 → 0,03
      expect(
        Quantity.tryParse('0,333')!.times(Money.tryParse('0,1')!),
        const Money.tiyn(3),
      );
      // 1,5 × 0,03 = 0,045 → 0,05
      expect(
        Quantity.tryParse('1,5')!.times(Money.tryParse('0,03')!),
        const Money.tiyn(5),
      );
    });

    test('zero price gives zero amount', () {
      expect(const Quantity.whole(10).times(Money.zero), Money.zero);
    });

    test('large amounts stay exact', () {
      expect(
        // 999 999,999 × 9 999 999 = 9 999 998 990 000,001
        Quantity.tryParse('999999,999')!.times(tenge(9999999)),
        tenge(9999998990000),
      );
    });
  });

  group('overdue', () {
    final today = DateTime.utc(2026, 9, 19);

    test('a debt is not overdue on its due date', () {
      final dueToday = sale(dueDate: today);
      expect(dueToday.isOverdueOn(today), isFalse);
      expect(dueToday.statusOn(today), SaleStatus.due);
      expect(dueToday.overdueDaysOn(today), 0);
    });

    test('becomes overdue the next day', () {
      final dueYesterday = sale(dueDate: DateTime.utc(2026, 9, 18));
      expect(dueYesterday.isOverdueOn(today), isTrue);
      expect(dueYesterday.statusOn(today), SaleStatus.overdue);
      expect(dueYesterday.overdueDaysOn(today), 1);
      expect(sale(dueDate: DateTime.utc(2026, 9, 13)).overdueDaysOn(today), 6);
    });

    test('uses the calendar day, not the time of day', () {
      final due = sale(dueDate: DateTime.utc(2026, 9, 18));
      expect(due.isOverdueOn(DateTime(2026, 9, 18, 23, 59)), isFalse);
      expect(due.isOverdueOn(DateTime(2026, 9, 19, 0, 1)), isTrue);
    });

    test('paid and undated sales are never overdue', () {
      expect(
        sale(paid: true, dueDate: DateTime.utc(2026, 9, 1)).isOverdueOn(today),
        isFalse,
      );
      expect(sale().isOverdueOn(today), isFalse);
    });
  });

  group('dates', () {
    test('month period covers the whole month', () {
      final period = FinancePeriod.month(DateTime.utc(2026, 2, 17));
      expect(period.from, DateTime.utc(2026, 2, 1));
      expect(period.to, DateTime.utc(2026, 2, 28));
      expect(period.contains(DateTime.utc(2026, 2, 28)), isTrue);
      expect(period.contains(DateTime.utc(2026, 3, 1)), isFalse);
    });

    test('API format round-trips', () {
      expect(formatApiDate(DateTime.utc(2026, 9, 3)), '2026-09-03');
      expect(parseApiDate('2026-09-03'), DateTime.utc(2026, 9, 3));
      expect(addDays(DateTime.utc(2026, 9, 20), 14), DateTime.utc(2026, 10, 4));
      expect(addMonths(DateTime.utc(2026, 1), -1), DateTime.utc(2025, 12));
    });
  });

  group('FinanceFormat', () {
    test('money in ru and kk', () {
      for (final locale in ['ru', 'kk']) {
        final format = FinanceFormat(locale);
        expect(format.money(tenge(145000)), '145${nbsp}000$nbsp₸');
        expect(format.money(tenge(-45000)), '${minus}45${nbsp}000$nbsp₸');
        expect(format.money(const Money.tiyn(125050)), '1${nbsp}250,50$nbsp₸');
        expect(format.money(Money.zero), '0$nbsp₸');
      }
    });

    test('signed money for profit', () {
      final format = FinanceFormat('ru');
      expect(format.signedMoney(tenge(830000)), '+${nbsp}830${nbsp}000$nbsp₸');
      expect(
        format.signedMoney(tenge(-12000)),
        '$minus${nbsp}12${nbsp}000$nbsp₸',
      );
    });

    test('quantity trims zeros', () {
      final format = FinanceFormat('ru');
      expect(format.quantity(const Quantity.whole(1200)), '1${nbsp}200');
      expect(format.quantity(const Quantity.milli(12500)), '12,5');
      expect(format.quantity(const Quantity.milli(375)), '0,375');
    });

    test('dates and month titles', () {
      final ru = FinanceFormat('ru');
      final day = DateTime.utc(2026, 9, 19);
      expect(ru.date(day), '19.09.2026');
      expect(ru.dayMonth(day), '19.09');
      expect(ru.month(day), 'Сентябрь 2026');
      expect(ru.dayTitle(day), '19 сентября');
      expect(FinanceFormat('kk').month(day), 'Қыркүйек 2026');
    });
  });

  group('DecimalInputFormatter', () {
    const money = DecimalInputFormatter();

    TextEditingValue type(
      String text, {
      DecimalInputFormatter formatter = money,
      TextEditingValue old = TextEditingValue.empty,
    }) => formatter.formatEditUpdate(
      old,
      TextEditingValue(
        text: text,
        selection: TextSelection.collapsed(offset: text.length),
      ),
    );

    test('groups thousands and keeps the caret at the end', () {
      final value = type('1234567');
      expect(value.text, '1${nbsp}234${nbsp}567');
      expect(value.selection.baseOffset, value.text.length);
    });

    test('normalizes separators, zeros and fraction length', () {
      expect(type('12.5').text, '12,5');
      expect(type(',5').text, '0,5');
      expect(type('0012').text, '12');
      expect(type('12,345').text, '12,34');
      expect(type('1,2,3').text, '1,23');
      expect(type('12a').text, '12');
      expect(
        type(
          '1,2345',
          formatter: const DecimalInputFormatter(maxFractionDigits: 3),
        ).text,
        '1,234',
      );
    });

    test('no separator when fractions are not allowed', () {
      expect(
        type(
          '12,5',
          formatter: const DecimalInputFormatter(maxFractionDigits: 0),
        ).text,
        '125',
      );
    });

    test('rejects more integer digits than the column holds', () {
      const formatter = DecimalInputFormatter(maxIntegerDigits: 3);
      final old = type('999', formatter: formatter);
      expect(type('9999', formatter: formatter, old: old), old);
    });

    test('keeps the caret after the same digit when editing the middle', () {
      // «1 234», вставили 5 после единицы: «15 234», курсор после 5.
      final old = TextEditingValue(text: '1${nbsp}234');
      final value = money.formatEditUpdate(
        old,
        TextEditingValue(
          text: '15${nbsp}234',
          selection: const TextSelection.collapsed(offset: 2),
        ),
      );
      expect(value.text, '15${nbsp}234');
      expect(value.selection.baseOffset, 2);
    });

    test('backspace over a group space deletes the digit before it', () {
      final old = TextEditingValue(
        text: '1${nbsp}234',
        selection: const TextSelection.collapsed(offset: 2),
      );
      final value = money.formatEditUpdate(
        old,
        const TextEditingValue(
          text: '1234',
          selection: TextSelection.collapsed(offset: 1),
        ),
      );
      expect(value.text, '234');
      expect(value.selection.baseOffset, 0);
    });
  });
}
