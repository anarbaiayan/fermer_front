class CreateCustomFeedDto {
  final String name;
  final String nameKk;
  final String type;
  final double pricePerKg;

  const CreateCustomFeedDto({
    required this.name,
    required this.nameKk,
    required this.type,
    required this.pricePerKg,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'nameKk': nameKk,
    'type': type,
    'pricePerKg': pricePerKg,
  };
}
