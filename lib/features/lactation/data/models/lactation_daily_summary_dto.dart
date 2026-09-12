class LactationDailySummaryDto {
  final String date; // yyyy-MM-dd
  final double totalLiters;
  final double totalKg;
  final int cowCount;
  final double? individualLiters;
  final double? bulkLiters;
  final int? bulkCowCount;
  final double? commercialMilk;
  final double? milkUsedForCalves;
  final double? unsuitableMilk;
  final List<LactationDailySummaryDetailDto> details;

  const LactationDailySummaryDto({
    required this.date,
    required this.totalLiters,
    required this.totalKg,
    required this.cowCount,
    required this.details,
    this.individualLiters,
    this.bulkLiters,
    this.bulkCowCount,
    this.commercialMilk,
    this.milkUsedForCalves,
    this.unsuitableMilk,
  });

  factory LactationDailySummaryDto.fromJson(Map<String, dynamic> json) {
    double asDouble(dynamic v) {
      if (v == null) throw const FormatException('Missing milk amount');
      if (v is num && v.isFinite) return v.toDouble();
      final parsed = double.tryParse(v.toString());
      if (parsed == null || !parsed.isFinite) {
        throw const FormatException('Invalid milk amount');
      }
      return parsed;
    }

    int asInt(dynamic v) {
      if (v == null) throw const FormatException('Missing integer');
      if (v is int) return v;
      if (v is num && v.isFinite && v == v.toInt()) return v.toInt();
      final parsed = int.tryParse(v.toString());
      if (parsed == null) throw const FormatException('Invalid integer');
      return parsed;
    }

    return LactationDailySummaryDto(
      date: (json['date'] as String?) ?? '',
      totalLiters: asDouble(json['totalLiters']),
      totalKg: asDouble(json['totalKg']),
      cowCount: asInt(json['cowCount']),
      individualLiters: json['individualLiters'] == null
          ? null
          : asDouble(json['individualLiters']),
      bulkLiters: json['bulkLiters'] == null
          ? null
          : asDouble(json['bulkLiters']),
      bulkCowCount: json['bulkCowCount'] == null
          ? null
          : asInt(json['bulkCowCount']),
      commercialMilk: json['commercialMilk'] == null
          ? null
          : asDouble(json['commercialMilk']),
      milkUsedForCalves: json['milkUsedForCalves'] == null
          ? null
          : asDouble(json['milkUsedForCalves']),
      unsuitableMilk: json['unsuitableMilk'] == null
          ? null
          : asDouble(json['unsuitableMilk']),
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
      if (v is num && v.isFinite) return v.toDouble();
      final parsed = double.tryParse(v.toString());
      if (parsed == null || !parsed.isFinite) {
        throw const FormatException('Invalid milk amount');
      }
      return parsed;
    }

    double asDouble(dynamic v) {
      if (v == null) throw const FormatException('Missing milk amount');
      if (v is num && v.isFinite) return v.toDouble();
      final parsed = double.tryParse(v.toString());
      if (parsed == null || !parsed.isFinite) {
        throw const FormatException('Invalid milk amount');
      }
      return parsed;
    }

    int asInt(dynamic v) {
      if (v == null) throw const FormatException('Missing integer');
      if (v is int) return v;
      if (v is num && v.isFinite && v == v.toInt()) return v.toInt();
      final parsed = int.tryParse(v.toString());
      if (parsed == null) throw const FormatException('Invalid integer');
      return parsed;
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
