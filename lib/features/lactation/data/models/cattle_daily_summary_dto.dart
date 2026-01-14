class CattleDailySummaryDto {
  final String? date; // yyyy-MM-dd
  final double? morningLiters;
  final double? eveningLiters;
  final double? totalLiters;
  final double? totalKg;

  const CattleDailySummaryDto({
    this.date,
    this.morningLiters,
    this.eveningLiters,
    this.totalLiters,
    this.totalKg,
  });

  factory CattleDailySummaryDto.fromJson(Map<String, dynamic> json) {
    double? asDouble(dynamic v) {
      if (v == null) return null;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString());
    }

    return CattleDailySummaryDto(
      date: json['date'] as String?,
      morningLiters: asDouble(json['morningLiters']),
      eveningLiters: asDouble(json['eveningLiters']),
      totalLiters: asDouble(json['totalLiters']),
      totalKg: asDouble(json['totalKg']),
    );
  }
}
