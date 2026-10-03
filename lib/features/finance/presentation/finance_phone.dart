import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

/// Телефон покупателя: `+7 (777) 777-77-77`. В таком виде он и хранится
/// (18 символов при лимите бэкенда 20), чтобы в списке выглядел одинаково.
abstract final class FinancePhone {
  static const mask = '+7 (###) ###-##-##';

  /// Маска для поля. [initial] — сохранённый номер в любом формате.
  static MaskTextInputFormatter formatter({String? initial}) =>
      MaskTextInputFormatter(
        mask: mask,
        filter: {'#': RegExp('[0-9]')},
        initialText: initial == null ? null : format(initial),
      );

  /// Номер в формате маски. Номер не из Казахстана или с другим числом
  /// цифр возвращается как был.
  static String format(String phone) {
    final national = _national(phone);
    if (national == null) return phone;
    return MaskTextInputFormatter(
      mask: mask,
      filter: {'#': RegExp('[0-9]')},
    ).maskText(national);
  }

  /// Результат поля ввода: `null` — номер не указан, `''` — введён не
  /// полностью, иначе номер в формате маски.
  static String? fromInput(String text) {
    final digits = text.replaceAll(RegExp(r'\D'), '');
    // В маске уже стоит «+7», одна цифра — это пустое поле.
    if (digits.length <= 1) return null;
    return digits.length == 11 ? text.trim() : '';
  }

  /// Цифры с кодом страны для звонка и WhatsApp: `77012345678`. Номер не
  /// из Казахстана — как ввели, только цифры; `null` — цифр нет.
  static String? international(String phone) {
    final national = _national(phone);
    if (national != null) return '7$national';
    final digits = phone.replaceAll(RegExp(r'\D'), '');
    return digits.isEmpty ? null : digits;
  }

  /// Десять цифр номера без кода страны.
  static String? _national(String phone) {
    final digits = phone.replaceAll(RegExp(r'\D'), '');
    if (digits.length == 10) return digits;
    if (digits.length == 11 && (digits[0] == '7' || digits[0] == '8')) {
      return digits.substring(1);
    }
    return null;
  }
}
