enum CattleGender { male, female }

extension CattleGenderX on CattleGender {
  String get apiValue {
    switch (this) {
      case CattleGender.male:
        return 'MALE';
      case CattleGender.female:
        return 'FEMALE';
    }
  }

  String get display {
    switch (this) {
      case CattleGender.male:
        return 'Мужской';
      case CattleGender.female:
        return 'Женский';
    }
  }

  static CattleGender fromApi(String value) {
    switch (value) {
      case 'MALE':
        return CattleGender.male;
      case 'FEMALE':
      default:
        return CattleGender.female;
    }
  }
}
