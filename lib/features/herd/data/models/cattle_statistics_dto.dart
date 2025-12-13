class CattleStatisticsDto {
  final int lactating;
  final int dryPeriod;
  final int open;
  final int inseminated;

  final int cows;
  final int heifers;
  final int calves;
  final int bulls;
  final int fattening;
  final int derived;

  final int total;

  const CattleStatisticsDto({
    required this.lactating,
    required this.dryPeriod,
    required this.open,
    required this.inseminated,
    required this.cows,
    required this.heifers,
    required this.calves,
    required this.bulls,
    required this.fattening,
    required this.derived,
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
      lactating: _asInt(json['lactating']),
      dryPeriod: _asInt(json['dryPeriod']),
      open: _asInt(json['open']),
      inseminated: _asInt(json['inseminated']),
      cows: _asInt(json['cows']),
      heifers: _asInt(json['heifers']),
      calves: _asInt(json['calves']),
      bulls: _asInt(json['bulls']),
      fattening: _asInt(json['fattening']),
      derived: _asInt(json['derived']),
      total: _asInt(json['total']),
    );
  }
}
