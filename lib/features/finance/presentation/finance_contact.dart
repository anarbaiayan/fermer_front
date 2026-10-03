import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import 'finance_phone.dart';

/// Открывает ссылку во внешнем приложении. `false` — открыть не удалось.
/// В тестах подменяется, чтобы проверить адрес.
final financeUrlLauncherProvider = Provider<Future<bool> Function(Uri)>(
  (ref) => (uri) async {
    try {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      return false;
    }
  },
);

/// Звонок и напоминание в WhatsApp покупателю с долгом (FP-503): деньги
/// нужно вернуть, а не только увидеть.
class FinanceContact {
  const FinanceContact(this._launch);

  final Future<bool> Function(Uri) _launch;

  Future<bool> call(String phone) async {
    final digits = FinancePhone.international(phone);
    if (digits == null) return false;
    return _launch(Uri(scheme: 'tel', path: '+$digits'));
  }

  /// Сначала приложение WhatsApp, если его нет — веб-версия.
  Future<bool> whatsApp(String phone, String text) async {
    final digits = FinancePhone.international(phone);
    if (digits == null) return false;
    final encoded = Uri.encodeComponent(text);
    return await _launch(
          Uri.parse('whatsapp://send?phone=$digits&text=$encoded'),
        ) ||
        await _launch(Uri.parse('https://wa.me/$digits?text=$encoded'));
  }
}
