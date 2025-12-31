enum ReproductiveState {
  open,
  inseminated,
  pregnant,
  dryPeriod,
  calvingSoon,
  freshCow,
}

extension ReproductiveStateX on ReproductiveState {
  String get apiValue {
    switch (this) {
      case ReproductiveState.open:
        return 'OPEN';
      case ReproductiveState.inseminated:
        return 'INSEMINATED';
      case ReproductiveState.pregnant:
        return 'PREGNANT';
      case ReproductiveState.dryPeriod:
        return 'DRY_PERIOD';
      case ReproductiveState.calvingSoon:
        return 'CALVING_SOON';
      case ReproductiveState.freshCow:
        return 'FRESH_COW';
    }
  }

  String get display {
    switch (this) {
      case ReproductiveState.open:
        return 'Не осеменена';
      case ReproductiveState.inseminated:
        return 'Осеменена';
      case ReproductiveState.pregnant:
        return 'Беременна';
      case ReproductiveState.dryPeriod:
        return 'Сухостой';
      case ReproductiveState.calvingSoon:
        return 'Скоро отёл';
      case ReproductiveState.freshCow:
        return 'Свежая корова';
    }
  }
}
