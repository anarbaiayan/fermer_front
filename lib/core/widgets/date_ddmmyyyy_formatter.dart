import 'package:flutter/services.dart';

class DateDdMmYyyyInputFormatter extends TextInputFormatter {
  const DateDdMmYyyyInputFormatter();

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    final clipped = digits.length > 8 ? digits.substring(0, 8) : digits;

    final b = StringBuffer();
    for (int i = 0; i < clipped.length; i++) {
      b.write(clipped[i]);
      if (i == 1 || i == 3) {
        if (i != clipped.length - 1) b.write('.');
      }
    }

    final formatted = b.toString();

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
      composing: TextRange.empty,
    );
  }
}
