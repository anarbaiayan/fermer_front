enum ProductionState { lactating, dry, fattening, breeding, unknown }

extension ProductionStateX on ProductionState {
  String get apiValue {
    switch (this) {
      case ProductionState.lactating:
        return 'LACTATING';
      case ProductionState.dry:
        return 'DRY';
      case ProductionState.fattening:
        return 'FATTENING';
      case ProductionState.breeding:
        return 'BREEDING';
      case ProductionState.unknown:
        return 'UNKNOWN';
    }
  }

  String get display {
    switch (this) {
      case ProductionState.lactating:
        return 'Лактация';
      case ProductionState.dry:
        return 'Сухостой';
      case ProductionState.fattening:
        return 'На откорме';
      case ProductionState.breeding:
        return 'Племенное использование';
      case ProductionState.unknown:
        return 'Неизвестно';
    }
  }

  static ProductionState fromApi(String? raw) {
    switch (raw) {
      case 'LACTATING':
        return ProductionState.lactating;
      case 'DRY':
        return ProductionState.dry;
      case 'FATTENING':
        return ProductionState.fattening;
      case 'BREEDING':
        return ProductionState.breeding;
      case 'UNKNOWN':
      default:
        return ProductionState.unknown;
    }
  }
}
