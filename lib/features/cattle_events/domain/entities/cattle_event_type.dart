enum CattleEventType {
  vaccination,
  illnessTreatment,
  weighing,
  hoofTrimming,
  antiparasiticTreatment,
  other,

  calving,
  insemination,
  dryPeriod,
  heatPeriod,
  synchronization,

  pregnancyConfirmation,
  pregnancyNotConfirmed,

  hornProcessing,
  weaning,

  // system - оставим в парсинге, но не показываем
  systemExpectedCalving,
  systemRecommendedDryPeriod,
  systemVaccinationReminder,
  systemWeighingReminder,
  systemWeaningReminder,
  systemStatusChange,
  systemAutoCalfCreation,
}

extension CattleEventTypeX on CattleEventType {
  String get apiValue {
    switch (this) {
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
      case CattleEventType.other:
        return 'OTHER';

      case CattleEventType.calving:
        return 'CALVING';
      case CattleEventType.insemination:
        return 'INSEMINATION';
      case CattleEventType.dryPeriod:
        return 'DRY_PERIOD';
      case CattleEventType.heatPeriod:
        return 'HEAT_PERIOD';
      case CattleEventType.synchronization:
        return 'SYNCHRONIZATION';

      case CattleEventType.pregnancyConfirmation:
        return 'PREGNANCY_CONFIRMATION';
      case CattleEventType.pregnancyNotConfirmed:
        return 'PREGNANCY_NOT_CONFIRMED';

      case CattleEventType.hornProcessing:
        return 'HORN_PROCESSING';
      case CattleEventType.weaning:
        return 'WEANING';

      case CattleEventType.systemExpectedCalving:
        return 'SYSTEM_EXPECTED_CALVING';
      case CattleEventType.systemRecommendedDryPeriod:
        return 'SYSTEM_RECOMMENDED_DRY_PERIOD';
      case CattleEventType.systemVaccinationReminder:
        return 'SYSTEM_VACCINATION_REMINDER';
      case CattleEventType.systemWeighingReminder:
        return 'SYSTEM_WEIGHING_REMINDER';
      case CattleEventType.systemWeaningReminder:
        return 'SYSTEM_WEANING_REMINDER';
      case CattleEventType.systemStatusChange:
        return 'SYSTEM_STATUS_CHANGE';
      case CattleEventType.systemAutoCalfCreation:
        return 'SYSTEM_AUTO_CALF_CREATION';
    }
  }

  String get display {
    switch (this) {
      case CattleEventType.vaccination:
        return 'Вакцинация';
      case CattleEventType.illnessTreatment:
        return 'Болезнь/Лечение';
      case CattleEventType.weighing:
        return 'Взвешивание';
      case CattleEventType.hoofTrimming:
        return 'Расчистка копыт';
      case CattleEventType.antiparasiticTreatment:
        return 'Противопаразитное лечение';
      case CattleEventType.other:
        return 'Другое';

      case CattleEventType.calving:
        return 'Отёл';
      case CattleEventType.insemination:
        return 'Осеменение/ИО';
      case CattleEventType.dryPeriod:
        return 'Сухостой';
      case CattleEventType.heatPeriod:
        return 'Период охоты';
      case CattleEventType.synchronization:
        return 'Синхронизация';

      case CattleEventType.pregnancyConfirmation:
        return 'Подтверждение стельности';
      case CattleEventType.pregnancyNotConfirmed:
        return 'Беременность не подтверждена';

      case CattleEventType.hornProcessing:
        return 'Обработка рога';
      case CattleEventType.weaning:
        return 'Отъём';

      case CattleEventType.systemExpectedCalving:
        return 'Предполагаемая дата отёла';
      case CattleEventType.systemRecommendedDryPeriod:
        return 'Рекомендованный сухостой';
      case CattleEventType.systemVaccinationReminder:
        return 'Напоминание о вакцинации';
      case CattleEventType.systemWeighingReminder:
        return 'Напоминание о взвешивании';
      case CattleEventType.systemWeaningReminder:
        return 'Рекомендованный отъём';
      case CattleEventType.systemStatusChange:
        return 'Смена статуса';
      case CattleEventType.systemAutoCalfCreation:
        return 'Создание телёнка';
    }
  }

  bool get isSystem => apiValue.startsWith('SYSTEM_');

  static CattleEventType? fromApi(String raw) {
    switch (raw) {
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
      case 'OTHER':
        return CattleEventType.other;

      case 'CALVING':
        return CattleEventType.calving;
      case 'INSEMINATION':
        return CattleEventType.insemination;
      case 'DRY_PERIOD':
        return CattleEventType.dryPeriod;
      case 'HEAT_PERIOD':
        return CattleEventType.heatPeriod;
      case 'SYNCHRONIZATION':
        return CattleEventType.synchronization;

      case 'PREGNANCY_CONFIRMATION':
        return CattleEventType.pregnancyConfirmation;
      case 'PREGNANCY_NOT_CONFIRMED':
        return CattleEventType.pregnancyNotConfirmed;

      case 'HORN_PROCESSING':
        return CattleEventType.hornProcessing;
      case 'WEANING':
        return CattleEventType.weaning;

      case 'SYSTEM_EXPECTED_CALVING':
        return CattleEventType.systemExpectedCalving;
      case 'SYSTEM_RECOMMENDED_DRY_PERIOD':
        return CattleEventType.systemRecommendedDryPeriod;
      case 'SYSTEM_VACCINATION_REMINDER':
        return CattleEventType.systemVaccinationReminder;
      case 'SYSTEM_WEIGHING_REMINDER':
        return CattleEventType.systemWeighingReminder;
      case 'SYSTEM_WEANING_REMINDER':
        return CattleEventType.systemWeaningReminder;
      case 'SYSTEM_STATUS_CHANGE':
        return CattleEventType.systemStatusChange;
      case 'SYSTEM_AUTO_CALF_CREATION':
        return CattleEventType.systemAutoCalfCreation;

      default:
        return null;
    }
  }
}
