class RationCatalogDto {
  final int id;
  final String name;
  final String type; // COARSE/JUICY/...
  final String typeDescription;
  final double pricePerKg;

  RationCatalogDto({
    required this.id,
    required this.name,
    required this.type,
    required this.typeDescription,
    required this.pricePerKg,
  });

  factory RationCatalogDto.fromJson(Map<String, dynamic> json) {
    return RationCatalogDto(
      id: (json['id'] as num).toInt(),
      name: (json['name'] ?? '').toString(),
      type: (json['type'] ?? '').toString(),
      typeDescription: (json['typeDescription'] ?? '').toString(),
      pricePerKg: (json['pricePerKg'] as num?)?.toDouble() ?? 0,
    );
  }
}
