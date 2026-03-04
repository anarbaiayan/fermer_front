enum BreedType { DAIRY, MEAT, MIXED, LOCAL }

extension BreedTypeX on BreedType {
  String get apiValue => name; // "DAIRY", "MEAT", etc.

  String get displayName {
    switch (this) {
      case BreedType.DAIRY:
        return 'Молочная';
      case BreedType.MEAT:
        return 'Мясная';
      case BreedType.MIXED:
        return 'Комбинированная';
      case BreedType.LOCAL:
        return 'Местная';
    }
  }

  static BreedType? tryParse(String? raw) {
    if (raw == null) return null;
    for (final v in BreedType.values) {
      if (v.name == raw) return v;
    }
    return null;
  }
}
