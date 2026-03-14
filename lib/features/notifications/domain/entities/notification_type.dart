enum NotificationType {
  pregnancyCheck,
  heatCheck,
  startDryPeriod,
  expectedCalving,
  vaccinationDue,
  weighingDue,
  calvingSoon,
  overdueCalving,
  treatmentEnd,
  stateChanged,
  reminder,
  info,
  unknown,
}

extension NotificationTypeX on NotificationType {
  static NotificationType fromApi(String? raw) {
    switch ((raw ?? '').toUpperCase()) {
      case 'PREGNANCY_CHECK':
        return NotificationType.pregnancyCheck;
      case 'HEAT_CHECK':
        return NotificationType.heatCheck;
      case 'START_DRY_PERIOD':
        return NotificationType.startDryPeriod;
      case 'EXPECTED_CALVING':
        return NotificationType.expectedCalving;
      case 'VACCINATION_DUE':
        return NotificationType.vaccinationDue;
      case 'WEIGHING_DUE':
        return NotificationType.weighingDue;
      case 'CALVING_SOON':
        return NotificationType.calvingSoon;
      case 'OVERDUE_CALVING':
        return NotificationType.overdueCalving;
      case 'TREATMENT_END':
        return NotificationType.treatmentEnd;
      case 'STATE_CHANGED':
        return NotificationType.stateChanged;
      case 'REMINDER':
        return NotificationType.reminder;
      case 'INFO':
        return NotificationType.info;
      default:
        return NotificationType.unknown;
    }
  }
}
