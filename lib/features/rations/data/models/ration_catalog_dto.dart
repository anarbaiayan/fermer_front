class RationCatalogDto {
  final int id;
  final String name;
  final String? nameKk;
  final String type; // COARSE/JUICY/...
  final String typeDescription;
  final double pricePerKg;

  RationCatalogDto({
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

  factory RationCatalogDto.fromJson(Map<String, dynamic> json) {
    return RationCatalogDto(
      id: (json['id'] as num).toInt(),
      name: (json['name'] ?? '').toString(),
      nameKk: (json['nameKk'] as String?)?.trim(),
      type: (json['type'] ?? '').toString(),
      typeDescription: (json['typeDescription'] ?? '').toString(),
      pricePerKg: (json['pricePerKg'] as num?)?.toDouble() ?? 0,
    );
  }
}
