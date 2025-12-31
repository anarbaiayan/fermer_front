class CattleStatisticsDto {
  final int pregnant;
  final int open;
  final int inseminated;
  final int lactating;
  final int dryPeriod;

  final int cows;
  final int heifers;
  final int calves;
  final int bulls;

  final int sick;
  final int healthy;
  final int total;

  const CattleStatisticsDto({
    required this.pregnant,
    required this.open,
    required this.inseminated,
    required this.lactating,
    required this.dryPeriod,
    required this.cows,
    required this.heifers,
    required this.calves,
    required this.bulls,
    required this.sick,
    required this.healthy,
    required this.total,
  });

  static int _asInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is num) return v.toInt();
    return int.tryParse(v.toString()) ?? 0;
  }

  factory CattleStatisticsDto.fromJson(Map<String, dynamic> json) {
    return CattleStatisticsDto(
      pregnant: _asInt(json['pregnant']),
      open: _asInt(json['open']),
      inseminated: _asInt(json['inseminated']),
      lactating: _asInt(json['lactating']),
      dryPeriod: _asInt(json['dryPeriod']),
      cows: _asInt(json['cows']),
      heifers: _asInt(json['heifers']),
      calves: _asInt(json['calves']),
      bulls: _asInt(json['bulls']),
      sick: _asInt(json['sick']),
      healthy: _asInt(json['healthy']),
      total: _asInt(json['total']),
    );
  }
}
