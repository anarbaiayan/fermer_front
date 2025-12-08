enum PregnancyStatus {
  pregnant,
  notPregnant,
  unknown,
}

extension PregnancyStatusX on PregnancyStatus {
  String get apiValue {
    switch (this) {
      case PregnancyStatus.pregnant:
        return 'PREGNANT';
      case PregnancyStatus.notPregnant:
        return 'NOT_PREGNANT';
      case PregnancyStatus.unknown:
        return 'UNKNOWN';
    }
  }

  String get display {
    switch (this) {
      case PregnancyStatus.pregnant:
        return 'Беременна';
      case PregnancyStatus.notPregnant:
        return 'Не беременна';
      case PregnancyStatus.unknown:
        return 'Неизвестно';
    }
  }

  static PregnancyStatus fromApi(String value) {
    switch (value) {
      case 'PREGNANT':
        return PregnancyStatus.pregnant;
      case 'NOT_PREGNANT':
        return PregnancyStatus.notPregnant;
      case 'UNKNOWN':
      default:
        return PregnancyStatus.unknown;
    }
  }
}
