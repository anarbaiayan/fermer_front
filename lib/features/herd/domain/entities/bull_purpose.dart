enum BullPurpose {
  breeding,
  fattening,
}

extension BullPurposeX on BullPurpose {
  String get apiValue {
    switch (this) {
      case BullPurpose.breeding:
        return 'BREEDING';
      case BullPurpose.fattening:
        return 'FATTENING';
    }
  }

  String get display {
    switch (this) {
      case BullPurpose.breeding:
        return 'Племенной';
      case BullPurpose.fattening:
        return 'На откорме';
    }
  }

  static BullPurpose fromApi(String value) {
    switch (value) {
      case 'BREEDING':
        return BullPurpose.breeding;
      case 'FATTENING':
      default:
        return BullPurpose.fattening;
    }
  }
}
