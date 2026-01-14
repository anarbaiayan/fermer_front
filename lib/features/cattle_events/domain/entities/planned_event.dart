class PlannedEvent {
  final int id;
  final int cattleId;
  final String cattleName;
  final String cattleTagNumber;

  final int daysUntil;
  final String eventType;
  final DateTime plannedDate;

  final int priority;
  final String title;
  final String? cattleCategory;

  const PlannedEvent({
    required this.id,
    required this.cattleId,
    required this.cattleName,
    required this.cattleTagNumber,
    required this.daysUntil,
    required this.eventType,
    required this.plannedDate,
    required this.priority,
    required this.title,
    this.cattleCategory,
  });
}
