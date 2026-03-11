class SimpleCattle {
  final int id;
  final String tagNumber;
  final String? name;

  const SimpleCattle({required this.id, required this.tagNumber, this.name});

  factory SimpleCattle.fromJson(Map<String, dynamic> json) {
    return SimpleCattle(
      id: (json['id'] as num).toInt(),
      tagNumber: (json['tagNumber'] ?? '').toString(),
      name: json['name']?.toString(),
    );
  }
}
