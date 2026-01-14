class CreateBulkEventDto {
  final List<int> cattleIds;
  final String eventDate; // yyyy-MM-dd
  final String eventType;
  final String? notes;
  final Map<String, dynamic>? eventData;

  const CreateBulkEventDto({
    required this.cattleIds,
    required this.eventDate,
    required this.eventType,
    this.notes,
    this.eventData,
  });

  Map<String, dynamic> toJson() {
    return {
      'cattleIds': cattleIds,
      'eventDate': eventDate,
      'eventType': eventType,
      'notes': notes,
      'eventData': eventData,
    }..removeWhere((k, v) => v == null);
  }
}
