class RationCatalogItemDto {
  final int id;
  final String name;
  final String? nameKk;
  final String type; // COARSE/JUICY/CONCENTRATED/VITAMINS_SUPPLEMENTS
  final String typeDescription;
  final double pricePerKg;

  RationCatalogItemDto({
    required this.id,
    required this.name,
    this.nameKk,
    required this.type,
    required this.typeDescription,
    required this.pricePerKg,
  });

  String localizedName(String languageCode) {
    if (languageCode == 'kk' && (nameKk ?? '').trim().isNotEmpty) {
      return nameKk!.trim();
    }
    return name;
  }

  factory RationCatalogItemDto.fromJson(Map<String, dynamic> json) {
    return RationCatalogItemDto(
      id: (json['id'] as num).toInt(),
      name: (json['name'] ?? '').toString(),
      nameKk: (json['nameKk'] as String?)?.trim(),
      type: (json['type'] ?? '').toString(),
      typeDescription: (json['typeDescription'] ?? '').toString(),
      pricePerKg: (json['pricePerKg'] as num?)?.toDouble() ?? 0,
    );
  }
}
