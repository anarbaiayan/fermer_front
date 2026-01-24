class GenerateRationTemplateDto {
  final String animalCategory; // BULL/COW/...
  final String productionState; // LACTATING/DRY/...
  final double targetDailyKg;

  GenerateRationTemplateDto({
    required this.animalCategory,
    required this.productionState,
    required this.targetDailyKg,
  });

  Map<String, dynamic> toJson() => {
    'animalCategory': animalCategory,
    'productionState': productionState,
    'targetDailyKg': targetDailyKg,
  };
}
