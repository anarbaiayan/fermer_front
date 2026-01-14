class LactationDailySummaryDto {
  final String date; // yyyy-MM-dd
  final double totalLiters;
  final double totalKg;
  final int cowCount;
  final List<LactationDailySummaryDetailDto> details;

  const LactationDailySummaryDto({
    required this.date,
    required this.totalLiters,
    required this.totalKg,
    required this.cowCount,
    required this.details,
  });

  factory LactationDailySummaryDto.fromJson(Map<String, dynamic> json) {
    double asDouble(dynamic v) {
      if (v == null) return 0.0;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString()) ?? 0.0;
    }

    int asInt(dynamic v) {
      if (v == null) return 0;
      if (v is int) return v;
      if (v is num) return v.toInt();
      return int.tryParse(v.toString()) ?? 0;
    }

    return LactationDailySummaryDto(
      date: (json['date'] as String?) ?? '',
      totalLiters: asDouble(json['totalLiters']),
      totalKg: asDouble(json['totalKg']),
      cowCount: asInt(json['cowCount']),
      details:
          (json['details'] as List?)
              ?.whereType<Map<String, dynamic>>()
              .map(LactationDailySummaryDetailDto.fromJson)
              .toList() ??
          const [],
    );
  }
}

class LactationDailySummaryDetailDto {
  final int cattleId;
  final String cattleTagNumber;
  final String cattleName;

  final double? morningLiters;
  final double? eveningLiters;

  final double totalLiters;
  final double totalKg;

  const LactationDailySummaryDetailDto({
    required this.cattleId,
    required this.cattleTagNumber,
    required this.cattleName,
    required this.morningLiters,
    required this.eveningLiters,
    required this.totalLiters,
    required this.totalKg,
  });

  factory LactationDailySummaryDetailDto.fromJson(Map<String, dynamic> json) {
    double? asNullableDouble(dynamic v) {
      if (v == null) return null;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString());
    }

    double asDouble(dynamic v) {
      if (v == null) return 0.0;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString()) ?? 0.0;
    }

    int asInt(dynamic v) {
      if (v == null) return 0;
      if (v is int) return v;
      if (v is num) return v.toInt();
      return int.tryParse(v.toString()) ?? 0;
    }

    return LactationDailySummaryDetailDto(
      cattleId: asInt(json['cattleId']),
      cattleTagNumber: (json['cattleTagNumber'] as String?) ?? '',
      cattleName: (json['cattleName'] as String?) ?? '',
      morningLiters: asNullableDouble(json['morningLiters']),
      eveningLiters: asNullableDouble(json['eveningLiters']),
      totalLiters: asDouble(json['totalLiters']),
      totalKg: asDouble(json['totalKg']),
    );
  }
}
