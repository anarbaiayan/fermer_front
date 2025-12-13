class CattleEvent {
  final int id;
  final int cattleId;
  final String eventType; // "VACCINATION", "CALVING", ...
  final DateTime eventDate;
  final String? title;
  final String? description;
  final String? notes;
  final DateTime? createdAt;

  const CattleEvent({
    required this.id,
    required this.cattleId,
    required this.eventType,
    required this.eventDate,
    this.title,
    this.description,
    this.notes,
    this.createdAt,
  });
}
