class CattleEventDto {
  final int? id;
  final int? cattleId;
  final String? cattleName;
  final String? cattleTagNumber;

  final String eventType;     // "VACCINATION"
  final String eventDate;     // "2025-12-13"
  final String? title;
  final String? description;
  final String? notes;
  final String? createdAt;    // строка с бэка (может быть ISO, может нет)

  const CattleEventDto({
    this.id,
    this.cattleId,
    this.cattleName,
    this.cattleTagNumber,
    required this.eventType,
    required this.eventDate,
    this.title,
    this.description,
    this.notes,
    this.createdAt,
  });

  factory CattleEventDto.fromJson(Map<String, dynamic> json) {
    return CattleEventDto(
      id: (json['id'] as num?)?.toInt(),
      cattleId: (json['cattleId'] as num?)?.toInt(),
      cattleName: json['cattleName'] as String?,
      cattleTagNumber: json['cattleTagNumber'] as String?,
      eventType: (json['eventType'] as String?) ?? '',
      eventDate: (json['eventDate'] as String?) ?? '',
      title: json['title'] as String?,
      description: json['description'] as String?,
      notes: json['notes'] as String?,
      createdAt: json['createdAt'] as String?,
    );
  }
}
