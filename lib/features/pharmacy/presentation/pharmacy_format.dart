import 'package:frontend/features/pharmacy/domain/entities/vet_request_status.dart';
import 'package:frontend/l10n/app_localizations.dart';

/// Символ тенге.
const String kTenge = '₸';

/// Форматирует цену в тенге под дизайн: целые — без дробной части,
/// иначе до двух знаков без лишних нулей. `null` → «—».
String formatTenge(double? value) {
  if (value == null) return '—';
  if (value == value.roundToDouble()) {
    return '${value.toInt()} $kTenge';
  }
  final s = value.toStringAsFixed(2).replaceFirst(RegExp(r'0+$'), '');
  return '${s.replaceFirst(RegExp(r'\.$'), '')} $kTenge';
}

/// Дата создания заявки в формате dd.MM.yyyy.
String formatRequestDate(DateTime? date) {
  if (date == null) return '';
  final local = date.toLocal();
  final dd = local.day.toString().padLeft(2, '0');
  final mm = local.month.toString().padLeft(2, '0');
  return '$dd.$mm.${local.year}';
}

/// Локализованное название статуса заявки (не полагаемся на бэковый
/// `statusDescription`, который приходит только по-русски).
String localizedRequestStatus(AppLocalizations l10n, VetRequestStatus status) {
  switch (status) {
    case VetRequestStatus.newRequest:
      return l10n.pharmacyStatusNew;
    case VetRequestStatus.inProgress:
      return l10n.pharmacyStatusInProgress;
    case VetRequestStatus.done:
      return l10n.pharmacyStatusDone;
    case VetRequestStatus.cancelled:
      return l10n.pharmacyStatusCancelled;
    case VetRequestStatus.unknown:
      return l10n.pharmacyStatusUnknown;
  }
}
