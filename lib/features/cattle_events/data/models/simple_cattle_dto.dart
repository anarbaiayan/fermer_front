class SimpleCattleDto {
  final int id;
  final String tagNumber;
  final String? name;

  const SimpleCattleDto({required this.id, required this.tagNumber, this.name});

  factory SimpleCattleDto.fromJson(Map<String, dynamic> json) {
    return SimpleCattleDto(
      id: (json['id'] as num).toInt(),
      tagNumber: (json['tagNumber'] ?? '').toString(),
      name: json['name']?.toString(),
    );
  }
}
