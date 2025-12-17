enum CattleEventType {
  calving,
  insemination,
  mating,
  synchronization,
  dryPeriod,
  heatPeriod,
  pregnancyConfirmation,
  vaccination,
  illnessTreatment,
  weighing,
  hoofTrimming,
  antiparasiticTreatment,
  weaning,
  other,
}

extension CattleEventTypeX on CattleEventType {
  String get apiValue {
    switch (this) {
      case CattleEventType.calving:
        return 'CALVING';
      case CattleEventType.insemination:
        return 'INSEMINATION';
      case CattleEventType.mating:
        return 'MATING';
      case CattleEventType.synchronization:
        return 'SYNCHRONIZATION';
      case CattleEventType.dryPeriod:
        return 'DRY_PERIOD';
      case CattleEventType.heatPeriod:
        return 'HEAT_PERIOD';
      case CattleEventType.pregnancyConfirmation:
        return 'PREGNANCY_CONFIRMATION';
      case CattleEventType.vaccination:
        return 'VACCINATION';
      case CattleEventType.illnessTreatment:
        return 'ILLNESS_TREATMENT';
      case CattleEventType.weighing:
        return 'WEIGHING';
      case CattleEventType.hoofTrimming:
        return 'HOOF_TRIMMING';
      case CattleEventType.antiparasiticTreatment:
        return 'ANTIPARASITIC_TREATMENT';
      case CattleEventType.weaning:
        return 'WEANING';
      case CattleEventType.other:
        return 'OTHER';
    }
  }

  String get display {
    switch (this) {
      case CattleEventType.calving:
        return 'Отёл';
      case CattleEventType.insemination:
        return 'Осеменение';
      case CattleEventType.mating:
        return 'Случка(покрытие самки)';
      case CattleEventType.synchronization:
        return 'Синхронизация';
      case CattleEventType.dryPeriod:
        return 'Сухостой';
      case CattleEventType.heatPeriod:
        return 'Период жара(охота)';
      case CattleEventType.pregnancyConfirmation:
        return 'Подтверждение стельности';
      case CattleEventType.vaccination:
        return 'Вакцинация';
      case CattleEventType.illnessTreatment:
        return 'Болезнь/лечение';
      case CattleEventType.weighing:
        return 'Взвешивание';
      case CattleEventType.hoofTrimming:
        return 'Расчистка копыт';
      case CattleEventType.antiparasiticTreatment:
        return 'Антипаразитарная обработка';
      case CattleEventType.weaning:
        return 'Отъем';
      case CattleEventType.other:
        return 'Другое';
    }
  }

  static CattleEventType? fromApi(String raw) {
    switch (raw) {
      case 'CALVING':
        return CattleEventType.calving;
      case 'INSEMINATION':
        return CattleEventType.insemination;
      case 'MATING':
        return CattleEventType.mating;
      case 'SYNCHRONIZATION':
        return CattleEventType.synchronization;
      case 'DRY_PERIOD':
        return CattleEventType.dryPeriod;
      case 'HEAT_PERIOD':
        return CattleEventType.heatPeriod;
      case 'PREGNANCY_CONFIRMATION':
        return CattleEventType.pregnancyConfirmation;
      case 'VACCINATION':
        return CattleEventType.vaccination;
      case 'ILLNESS_TREATMENT':
        return CattleEventType.illnessTreatment;
      case 'WEIGHING':
        return CattleEventType.weighing;
      case 'HOOF_TRIMMING':
        return CattleEventType.hoofTrimming;
      case 'ANTIPARASITIC_TREATMENT':
        return CattleEventType.antiparasiticTreatment;
      case 'WEANING':
        return CattleEventType.weaning;
      case 'OTHER':
        return CattleEventType.other;
      default:
        return null;
    }
  }
}

String displayEventType(String raw) {
  final t = CattleEventTypeX.fromApi(raw);
  return t?.display ?? raw;
}
