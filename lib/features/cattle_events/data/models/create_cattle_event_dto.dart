class CreateCattleEventDto {
  final String eventDate; // "yyyy-MM-dd"
  final String eventType; // "CALVING", "VACCINATION", ...
  final String? notes;
  final Map<String, dynamic>? eventData; // зависит от типа события

  const CreateCattleEventDto({
    required this.eventDate,
    required this.eventType,
    this.notes,
    this.eventData,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'eventDate': eventDate,
      'eventType': eventType,
      'notes': notes,
      'eventData': eventData,
    };
    map.removeWhere((k, v) => v == null);
    return map;
  }
}
