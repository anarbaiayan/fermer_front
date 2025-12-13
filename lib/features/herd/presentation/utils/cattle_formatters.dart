String formatAge(int months) {
  if (months < 12) {
    return '$months месяцев';
  }
  final years = months ~/ 12;
  final remMonths = months % 12;

  String yearsPart;
  if (years == 1) {
    yearsPart = '1 год';
  } else if (years >= 2 && years <= 4) {
    yearsPart = '$years года';
  } else {
    yearsPart = '$years лет';
  }

  if (remMonths == 0) return yearsPart;
  return '$yearsPart $remMonths месяцев';
}

String? mapHealthStatus(String? raw) {
  if (raw == null) return null;
  switch (raw) {
    case 'HEALTHY':
      return 'Здоров';
    case 'SICK':
      return 'Болен';
    case 'UNDER_TREATMENT':
      return 'На лечении';
    case 'QUARANTINE':
      return 'Карантин';
    case 'RECOVERING':
      return 'Выздоравливает';
    default:
      return null;
  }
}
