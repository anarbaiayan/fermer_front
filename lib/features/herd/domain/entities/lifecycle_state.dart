enum LifecycleState { suckling, weaned, growing, mature, sold, culled, unknown }

extension LifecycleStateX on LifecycleState {
  String get apiValue {
    switch (this) {
      case LifecycleState.suckling:
        return 'SUCKLING';
      case LifecycleState.weaned:
        return 'WEANED';
      case LifecycleState.growing:
        return 'GROWING';
      case LifecycleState.mature:
        return 'MATURE';
      case LifecycleState.sold:
        return 'SOLD';
      case LifecycleState.culled:
        return 'CULLED';
      case LifecycleState.unknown:
        return 'UNKNOWN';
    }
  }

  String get display {
    switch (this) {
      case LifecycleState.suckling:
        return 'На подсосе';
      case LifecycleState.weaned:
        return 'Отнят';
      case LifecycleState.growing:
        return 'Растет';
      case LifecycleState.mature:
        return 'Взрослое';
      case LifecycleState.sold:
        return 'Продано';
      case LifecycleState.culled:
        return 'Выбраковано';
      case LifecycleState.unknown:
        return 'Неизвестно';
    }
  }

  static LifecycleState fromApi(String? raw) {
    switch (raw) {
      case 'SUCKLING':
        return LifecycleState.suckling;
      case 'WEANED':
        return LifecycleState.weaned;
      case 'GROWING':
        return LifecycleState.growing;
      case 'MATURE':
        return LifecycleState.mature;
      case 'SOLD':
        return LifecycleState.sold;
      case 'CULLED':
        return LifecycleState.culled;
      case 'UNKNOWN':
      default:
        return LifecycleState.unknown;
    }
  }
}
