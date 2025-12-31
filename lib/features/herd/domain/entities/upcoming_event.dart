class UpcomingEvent {
  final int id;
  final String eventType;
  final String title;
  final DateTime? plannedDate;
  final int? daysUntil;
  final int? priority;

  const UpcomingEvent({
    required this.id,
    required this.eventType,
    required this.title,
    required this.plannedDate,
    this.daysUntil,
    this.priority,
  });
}
