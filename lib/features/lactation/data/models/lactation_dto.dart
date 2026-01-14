class LactationDto {
  final int? id;
  final int? cattleId;
  final String? cattleTagNumber;
  final String? cattleName;

  final String? milkingDate;
  final String? milkingDateTime;
  final String? milkingTime;

  final double? milkLiters;
  final double? milkKg;
  final String? notes;

  final String? createdAt;
  final String? updatedAt;

  const LactationDto({
    this.id,
    this.cattleId,
    this.cattleTagNumber,
    this.cattleName,
    this.milkingDate,
    this.milkingDateTime,
    this.milkingTime,
    this.milkLiters,
    this.milkKg,
    this.notes,
    this.createdAt,
    this.updatedAt,
  });

  factory LactationDto.fromJson(Map<String, dynamic> json) {
    double? asDouble(dynamic v) {
      if (v == null) return null;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString());
    }

    int? asInt(dynamic v) {
      if (v == null) return null;
      if (v is int) return v;
      if (v is num) return v.toInt();
      return int.tryParse(v.toString());
    }

    return LactationDto(
      id: asInt(json['id']),
      cattleId: asInt(json['cattleId']),
      cattleTagNumber: json['cattleTagNumber'] as String?,
      cattleName: json['cattleName'] as String?,
      milkingDate: json['milkingDate'] as String?,
      milkingDateTime: json['milkingDateTime'] as String?,
      milkingTime: json['milkingTime'] as String?,
      milkLiters: asDouble(json['milkLiters']),
      milkKg: asDouble(json['milkKg']),
      notes: json['notes'] as String?,
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
    );
  }
}
