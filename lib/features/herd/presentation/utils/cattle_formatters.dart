import 'package:frontend/l10n/app_localizations.dart';

String formatAge(int months, AppLocalizations l10n) {
  if (months < 12) return l10n.ageMonthsCompact(months);
  final years = months ~/ 12;
  final remMonths = months % 12;
  if (remMonths == 0) return l10n.ageYearsCompact(years);
  return l10n.ageYearsMonthsCompact(years, remMonths);
}

String? mapHealthStatus(String? raw, AppLocalizations l10n) {
  if (raw == null) return null;
  switch (raw) {
    case 'HEALTHY':
      return l10n.healthHealthy;
    case 'SICK':
      return l10n.healthSick;
    case 'UNDER_TREATMENT':
      return l10n.healthUnderTreatment;
    case 'QUARANTINE':
      return l10n.healthQuarantine;
    case 'RECOVERING':
      return l10n.healthRecovering;
    default:
      return null;
  }
}
