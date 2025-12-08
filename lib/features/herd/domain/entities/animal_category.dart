enum AnimalCategory {
  bull,     // BULL
  calf,     // CALF
  cow,      // COW
  heifer,   // HEIFER
}

extension AnimalCategoryX on AnimalCategory {
  String get apiValue {
    switch (this) {
      case AnimalCategory.bull:
        return 'BULL';
      case AnimalCategory.calf:
        return 'CALF';
      case AnimalCategory.cow:
        return 'COW';
      case AnimalCategory.heifer:
        return 'HEIFER';
    }
  }

  String get display {
    switch (this) {
      case AnimalCategory.bull:
        return 'Бык';
      case AnimalCategory.calf:
        return 'Теленок';
      case AnimalCategory.cow:
        return 'Корова';
      case AnimalCategory.heifer:
        return 'Телка';
    }
  }

  static AnimalCategory fromApi(String value) {
    switch (value) {
      case 'BULL':
        return AnimalCategory.bull;
      case 'CALF':
        return AnimalCategory.calf;
      case 'COW':
        return AnimalCategory.cow;
      case 'HEIFER':
      default:
        return AnimalCategory.heifer;
    }
  }
}
