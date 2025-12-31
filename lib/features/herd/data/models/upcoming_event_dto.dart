class UpcomingEventDto {
  final int? id;
  final String? eventType;
  final String? title;
  final String? plannedDate;
  final int? daysUntil;
  final int? priority;

  const UpcomingEventDto({
    this.id,
    this.eventType,
    this.title,
    this.plannedDate,
    this.daysUntil,
    this.priority,
  });

  factory UpcomingEventDto.fromJson(Map<String, dynamic> json) {
    int? asInt(dynamic v) {
      if (v == null) return null;
      if (v is int) return v;
      if (v is num) return v.toInt();
      return int.tryParse(v.toString());
    }

    return UpcomingEventDto(
      id: asInt(json['id']),
      eventType: json['eventType'] as String?,
      title: json['title'] as String?,
      plannedDate: json['plannedDate'] as String?,
      daysUntil: asInt(json['daysUntil']),
      priority: asInt(json['priority']),
    );
  }
}
