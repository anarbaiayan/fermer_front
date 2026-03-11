import 'package:frontend/features/herd/domain/entities/animal_category.dart';
import 'package:frontend/features/herd/domain/entities/production_state.dart';

import '../../domain/entities/ration_entities.dart';

class RationCatalogItemDto {
  final int? id;
  final String? name;
  final String? nameKk;
  final String? type;
  final String? typeDescription;
  final num? pricePerKg;

  RationCatalogItemDto({
    this.id,
    this.name,
    this.nameKk,
    this.type,
    this.typeDescription,
    this.pricePerKg,
  });

  factory RationCatalogItemDto.fromJson(Map<String, dynamic> json) {
    return RationCatalogItemDto(
      id: (json['id'] as num?)?.toInt(),
      name: json['name'] as String?,
      nameKk: json['nameKk'] as String?,
      type: json['type'] as String?,
      typeDescription: json['typeDescription'] as String?,
      pricePerKg: json['pricePerKg'] as num?,
    );
  }
}

class UserRationDto {
  final int? id;
  final RationCatalogItemDto? ration;
  final num? quantityKg;
  final bool? isAvailable;
  final num? totalCost;

  UserRationDto({
    this.id,
    this.ration,
    this.quantityKg,
    this.isAvailable,
    this.totalCost,
  });

  factory UserRationDto.fromJson(Map<String, dynamic> json) {
    return UserRationDto(
      id: (json['id'] as num?)?.toInt(),
      ration: json['ration'] == null
          ? null
          : RationCatalogItemDto.fromJson(
              json['ration'] as Map<String, dynamic>,
            ),
      quantityKg: json['quantityKg'] as num?,
      isAvailable: json['isAvailable'] as bool?,
      totalCost: json['totalCost'] as num?,
    );
  }
}

class RationTemplateItemDto {
  final int? id;
  final RationCatalogItemDto? ration;
  final num? quantityKg;
  final num? percentOfTotal;
  final num? itemCost;

  RationTemplateItemDto({
    this.id,
    this.ration,
    this.quantityKg,
    this.percentOfTotal,
    this.itemCost,
  });

  factory RationTemplateItemDto.fromJson(Map<String, dynamic> json) {
    return RationTemplateItemDto(
      id: (json['id'] as num?)?.toInt(),
      ration: json['ration'] == null
          ? null
          : RationCatalogItemDto.fromJson(
              json['ration'] as Map<String, dynamic>,
            ),
      quantityKg: json['quantityKg'] as num?,
      percentOfTotal: json['percentOfTotal'] as num?,
      itemCost: json['itemCost'] as num?,
    );
  }
}

class RationTemplateDto {
  final int? id;
  final String? animalCategory;
  final String? productionState;
  final String? name;
  final num? totalDailyKg;
  final String? warnings;
  final bool? isOptimal;
  final List<RationTemplateItemDto>? items;
  final num? totalDailyCost;

  RationTemplateDto({
    this.id,
    this.animalCategory,
    this.productionState,
    this.name,
    this.totalDailyKg,
    this.warnings,
    this.isOptimal,
    this.items,
    this.totalDailyCost,
  });

  factory RationTemplateDto.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'];
    return RationTemplateDto(
      id: (json['id'] as num?)?.toInt(),
      animalCategory: json['animalCategory'] as String?,
      productionState: json['productionState'] as String?,
      name: json['name'] as String?,
      totalDailyKg: json['totalDailyKg'] as num?,
      warnings: json['warnings'] as String?,
      isOptimal: json['isOptimal'] as bool?,
      items: rawItems is List
          ? rawItems
                .whereType<Map<String, dynamic>>()
                .map(RationTemplateItemDto.fromJson)
                .toList()
          : <RationTemplateItemDto>[],
      totalDailyCost: json['totalDailyCost'] as num?,
    );
  }
}

// ---------- mappers to entities ----------

RationCatalogItem catalogFromDto(RationCatalogItemDto d) {
  return RationCatalogItem(
    id: d.id ?? 0,
    name: d.name ?? '-',
    type: RationTypeX.tryParse(d.type),
    typeDescription: d.typeDescription,
    pricePerKg: d.pricePerKg?.toDouble(),
  );
}

UserRationItem userRationFromDto(UserRationDto d) {
  final rationDto = d.ration ?? RationCatalogItemDto(id: 0, name: '-');
  return UserRationItem(
    id: d.id ?? 0,
    ration: catalogFromDto(rationDto),
    quantityKg: (d.quantityKg ?? 0).toDouble(),
    isAvailable: d.isAvailable ?? false,
    totalCost: (d.totalCost ?? 0).toDouble(),
  );
}

RationTemplateItem templateItemFromDto(RationTemplateItemDto d) {
  final rationDto = d.ration ?? RationCatalogItemDto(id: 0, name: '-');
  return RationTemplateItem(
    id: d.id ?? 0,
    ration: catalogFromDto(rationDto),
    quantityKg: (d.quantityKg ?? 0).toDouble(),
    percentOfTotal: (d.percentOfTotal ?? 0).toDouble(),
    itemCost: (d.itemCost ?? 0).toDouble(),
  );
}

RationTemplate templateFromDto(RationTemplateDto d) {
  final catRaw = d.animalCategory ?? 'HEIFER';
  final prodRaw = d.productionState;

  return RationTemplate(
    id: d.id ?? 0,
    animalCategory: AnimalCategoryX.fromApi(catRaw),
    productionState: ProductionStateX.fromApi(prodRaw),
    name: d.name ?? '-',
    totalDailyKg: (d.totalDailyKg ?? 0).toDouble(),
    warnings: d.warnings,
    isOptimal: d.isOptimal ?? false,
    items: (d.items ?? const []).map(templateItemFromDto).toList(),
    totalDailyCost: (d.totalDailyCost ?? 0).toDouble(),
  );
}
