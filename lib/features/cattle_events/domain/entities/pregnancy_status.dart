enum PregnancyStatus {
  pregnant,
  notPregnant,
  abortion,
  unconfirmed,
}

extension PregnancyStatusX on PregnancyStatus {
  String get apiValue {
    switch (this) {
      case PregnancyStatus.pregnant:
        return 'PREGNANT';
      case PregnancyStatus.notPregnant:
        return 'NOT_PREGNANT';
      case PregnancyStatus.abortion:
        return 'ABORTION';
      case PregnancyStatus.unconfirmed:
        return 'UNCONFIRMED';
    }
  }

  String get display {
    switch (this) {
      case PregnancyStatus.pregnant:
        return 'Стельная';
      case PregnancyStatus.notPregnant:
        return 'Не стельная';
      case PregnancyStatus.abortion:
        return 'Аборт/выкидыш';
      case PregnancyStatus.unconfirmed:
        return 'Результат не подтвержден';
    }
  }
}
