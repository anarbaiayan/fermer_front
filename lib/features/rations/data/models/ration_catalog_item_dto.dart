class RationCatalogItemDto {
  final int id;
  final String name;
  final String type; // COARSE/JUICY/CONCENTRATED/VITAMINS_SUPPLEMENTS
  final String typeDescription;
  final double pricePerKg;

  RationCatalogItemDto({
    required this.id,
    required this.name,
    required this.type,
    required this.typeDescription,
    required this.pricePerKg,
  });

  factory RationCatalogItemDto.fromJson(Map<String, dynamic> json) {
    return RationCatalogItemDto(
      id: (json['id'] as num).toInt(),
      name: (json['name'] ?? '').toString(),
      type: (json['type'] ?? '').toString(),
      typeDescription: (json['typeDescription'] ?? '').toString(),
      pricePerKg: (json['pricePerKg'] as num?)?.toDouble() ?? 0,
    );
  }
}
