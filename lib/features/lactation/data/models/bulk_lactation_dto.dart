class BulkLactationDto {
  final int? id;

  final String? milkingDate; // yyyy-MM-dd
  final String? milkingDateTime; // ISO
  final String? milkingTime; // MORNING/EVENING

  final int? numberOfCows;

  final double? totalMilkLiters;
  final double? totalMilkKg;

  final double? milkUsedForCalves;
  final double? unsuitableMilk;

  final double? commercialMilk;
  final double? averageMilkPerCow;

  final String? notes;
  final int? userId;

  const BulkLactationDto({
    this.id,
    this.milkingDate,
    this.milkingDateTime,
    this.milkingTime,
    this.numberOfCows,
    this.totalMilkLiters,
    this.totalMilkKg,
    this.milkUsedForCalves,
    this.unsuitableMilk,
    this.commercialMilk,
    this.averageMilkPerCow,
    this.notes,
    this.userId,
  });

  factory BulkLactationDto.fromJson(Map<String, dynamic> json) {
    int? asInt(dynamic v) {
      if (v == null) return null;
      if (v is int) return v;
      if (v is num) return v.toInt();
      return int.tryParse(v.toString());
    }

    double? asDouble(dynamic v) {
      if (v == null) return null;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString());
    }

    return BulkLactationDto(
      id: asInt(json['id']),
      milkingDate: json['milkingDate'] as String?,
      milkingDateTime: json['milkingDateTime'] as String?,
      milkingTime: json['milkingTime'] as String?,
      numberOfCows: asInt(json['numberOfCows']),
      totalMilkLiters: asDouble(json['totalMilkLiters']),
      totalMilkKg: asDouble(json['totalMilkKg']),
      milkUsedForCalves: asDouble(json['milkUsedForCalves']),
      unsuitableMilk: asDouble(json['unsuitableMilk']),
      commercialMilk: asDouble(json['commercialMilk']),
      averageMilkPerCow: asDouble(json['averageMilkPerCow']),
      notes: json['notes'] as String?,
      userId: asInt(json['userId']),
    );
  }
}
