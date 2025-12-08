enum HealthStatus {
  healthy,
  sick,
  underTreatment,
  quarantine,
  recovering,
}

extension HealthStatusX on HealthStatus {
  String get apiValue {
    switch (this) {
      case HealthStatus.healthy:
        return 'HEALTHY';
      case HealthStatus.sick:
        return 'SICK';
      case HealthStatus.underTreatment:
        return 'UNDER_TREATMENT';
      case HealthStatus.quarantine:
        return 'QUARANTINE';
      case HealthStatus.recovering:
        return 'RECOVERING';
    }
  }

  String get display {
    switch (this) {
      case HealthStatus.healthy:
        return 'Здоров';
      case HealthStatus.sick:
        return 'Болен';
      case HealthStatus.underTreatment:
        return 'На лечении';
      case HealthStatus.quarantine:
        return 'Карантин';
      case HealthStatus.recovering:
        return 'Выздоравливает';
    }
  }

  static HealthStatus fromApi(String value) {
    switch (value) {
      case 'HEALTHY':
        return HealthStatus.healthy;
      case 'SICK':
        return HealthStatus.sick;
      case 'UNDER_TREATMENT':
        return HealthStatus.underTreatment;
      case 'QUARANTINE':
        return HealthStatus.quarantine;
      case 'RECOVERING':
      default:
        return HealthStatus.recovering;
    }
  }
}
