import 'ration_catalog_dto.dart';

class RationTemplateItemDto {
  final int id;
  final RationCatalogDto ration;
  final double quantityKg;
  final double percentOfTotal;
  final double itemCost;

  RationTemplateItemDto({
    required this.id,
    required this.ration,
    required this.quantityKg,
    required this.percentOfTotal,
    required this.itemCost,
  });

  factory RationTemplateItemDto.fromJson(Map<String, dynamic> json) {
    return RationTemplateItemDto(
      id: (json['id'] as num).toInt(),
      ration: RationCatalogDto.fromJson(json['ration'] as Map<String, dynamic>),
      quantityKg: (json['quantityKg'] as num?)?.toDouble() ?? 0,
      percentOfTotal: (json['percentOfTotal'] as num?)?.toDouble() ?? 0,
      itemCost: (json['itemCost'] as num?)?.toDouble() ?? 0,
    );
  }
}

class RationTemplateDto {
  final int id;
  final String animalCategory; // BULL/COW/...
  final String productionState; // LACTATING/DRY/...
  final String name;
  final double totalDailyKg;
  final String warnings;
  final bool isOptimal;
  final List<RationTemplateItemDto> items;
  final double totalDailyCost;

  RationTemplateDto({
    required this.id,
    required this.animalCategory,
    required this.productionState,
    required this.name,
    required this.totalDailyKg,
    required this.warnings,
    required this.isOptimal,
    required this.items,
    required this.totalDailyCost,
  });

  factory RationTemplateDto.fromJson(Map<String, dynamic> json) {
    final rawItems = (json['items'] as List?) ?? const [];
    return RationTemplateDto(
      id: (json['id'] as num).toInt(),
      animalCategory: (json['animalCategory'] ?? '').toString(),
      productionState: (json['productionState'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      totalDailyKg: (json['totalDailyKg'] as num?)?.toDouble() ?? 0,
      warnings: (json['warnings'] ?? '').toString(),
      isOptimal: (json['isOptimal'] as bool?) ?? false,
      items: rawItems
          .map((e) => RationTemplateItemDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalDailyCost: (json['totalDailyCost'] as num?)?.toDouble() ?? 0,
    );
  }
}
