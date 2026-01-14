enum MilkingTime { morning, evening }

extension MilkingTimeX on MilkingTime {
  String get apiValue => this == MilkingTime.morning ? 'MORNING' : 'EVENING';

  static MilkingTime? fromApi(String? v) {
    switch (v) {
      case 'MORNING':
        return MilkingTime.morning;
      case 'EVENING':
        return MilkingTime.evening;
      default:
        return null;
    }
  }

  String get display => this == MilkingTime.morning ? 'Утро' : 'Вечер';
}
