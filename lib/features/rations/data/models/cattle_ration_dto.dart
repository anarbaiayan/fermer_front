class CattleRationItemDto {
  final int feedId;
  final String feedName;
  final String feedType;
  final double minKg;
  final double maxKg;
  final double pricePerKg;
  final String? note;

  const CattleRationItemDto({
    required this.feedId,
    required this.feedName,
    required this.feedType,
    required this.minKg,
    required this.maxKg,
    required this.pricePerKg,
    this.note,
  });

  factory CattleRationItemDto.fromJson(Map<String, dynamic> json) {
    return CattleRationItemDto(
      feedId: (json['feedId'] as num).toInt(),
      feedName: (json['feedName'] ?? '').toString(),
      feedType: (json['feedType'] ?? '').toString(),
      minKg: (json['minKg'] as num?)?.toDouble() ?? 0,
      maxKg: (json['maxKg'] as num?)?.toDouble() ?? 0,
      pricePerKg: (json['pricePerKg'] as num?)?.toDouble() ?? 0,
      note: json['note'] as String?,
    );
  }
}

class CattleRationDto {
  final int id;
  final int cattleId;
  final String? tagNumber;
  final String? name;
  final String? animalCategory;
  final String? productionState;
  final String? breedType;
  final double currentWeight;
  final double totalDailyKg;
  final String? warnings;
  final bool isOptimal;
  final String? recommendations;
  final bool aiGenerated;
  final List<CattleRationItemDto> items;

  const CattleRationDto({
    required this.id,
    required this.cattleId,
    this.tagNumber,
    this.name,
    this.animalCategory,
    this.productionState,
    this.breedType,
    required this.currentWeight,
    required this.totalDailyKg,
    this.warnings,
    required this.isOptimal,
    this.recommendations,
    required this.aiGenerated,
    required this.items,
  });

  factory CattleRationDto.fromJson(Map<String, dynamic> json) {
    final rawItems = (json['items'] as List?) ?? const [];
    return CattleRationDto(
      id: (json['id'] as num).toInt(),
      cattleId: (json['cattleId'] as num).toInt(),
      tagNumber: json['tagNumber'] as String?,
      name: json['name'] as String?,
      animalCategory: json['animalCategory'] as String?,
      productionState: json['productionState'] as String?,
      breedType: json['breedType'] as String?,
      currentWeight: (json['currentWeight'] as num?)?.toDouble() ?? 0,
      totalDailyKg: (json['totalDailyKg'] as num?)?.toDouble() ?? 0,
      warnings: json['warnings'] as String?,
      isOptimal: (json['isOptimal'] as bool?) ?? false,
      recommendations: json['recommendations'] as String?,
      aiGenerated: (json['aiGenerated'] as bool?) ?? false,
      items: rawItems
          .map((e) => CattleRationItemDto.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
