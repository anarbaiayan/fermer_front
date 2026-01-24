import 'package:frontend/features/herd/domain/entities/animal_category.dart';
import 'package:frontend/features/herd/domain/entities/production_state.dart';

enum RationType { COARSE, JUICY, CONCENTRATED, VITAMINS_SUPPLEMENTS }

extension RationTypeX on RationType {
  String get code => name; // "COARSE" etc.

  String get titleRu {
    switch (this) {
      case RationType.COARSE:
        return 'Грубые корма';
      case RationType.JUICY:
        return 'Сочные корма';
      case RationType.CONCENTRATED:
        return 'Концентрированные корма';
      case RationType.VITAMINS_SUPPLEMENTS:
        return 'Витамины, минералы и добавки';
    }
  }

  static RationType? tryParse(String? raw) {
    if (raw == null) return null;
    for (final v in RationType.values) {
      if (v.name == raw) return v;
    }
    return null;
  }
}

class RationCatalogItem {
  final int id;
  final String name;
  final RationType? type;
  final String? typeDescription;
  final double? pricePerKg;

  const RationCatalogItem({
    required this.id,
    required this.name,
    required this.type,
    required this.typeDescription,
    required this.pricePerKg,
  });
}

class UserRationItem {
  final int id; // user-rations row id
  final RationCatalogItem ration;
  final double quantityKg;
  final bool isAvailable;
  final double totalCost;

  const UserRationItem({
    required this.id,
    required this.ration,
    required this.quantityKg,
    required this.isAvailable,
    required this.totalCost,
  });
}

class RationTemplateItem {
  final int id;
  final RationCatalogItem ration;
  final double quantityKg;
  final double percentOfTotal;
  final double itemCost;

  const RationTemplateItem({
    required this.id,
    required this.ration,
    required this.quantityKg,
    required this.percentOfTotal,
    required this.itemCost,
  });
}

class RationTemplate {
  final int id;
  final AnimalCategory animalCategory;
  final ProductionState productionState;
  final String name;
  final double totalDailyKg;
  final String? warnings;
  final bool isOptimal;
  final List<RationTemplateItem> items;
  final double totalDailyCost;

  const RationTemplate({
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
}
