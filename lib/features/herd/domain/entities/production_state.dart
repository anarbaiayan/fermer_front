enum ProductionState {
  lactating,
  dryPhase1,
  dryPhase2,
  fattening,
  breeding,
  unknown,
}

extension ProductionStateX on ProductionState {
  String get apiValue {
    switch (this) {
      case ProductionState.lactating:
        return 'LACTATING';
      case ProductionState.dryPhase1:
        return 'DRY_PHASE_1';
      case ProductionState.dryPhase2:
        return 'DRY_PHASE_2';
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
      case ProductionState.dryPhase1:
        return 'Сухостой (фаза 1)';
      case ProductionState.dryPhase2:
        return 'Сухостой (фаза 2)';
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
      case 'DRY_PHASE_1':
      case 'DRY':
        return ProductionState.dryPhase1;
      case 'DRY_PHASE_2':
        return ProductionState.dryPhase2;
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
