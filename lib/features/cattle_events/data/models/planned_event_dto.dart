class PlannedEventDto {
  final int? id;
  final int? cattleId;
  final String? cattleName;
  final String? cattleTagNumber;

  final int? daysUntil;
  final String? eventType;
  final String? plannedDate; // "yyyy-MM-dd"
  final int? priority;
  final String? title;

  final PlannedEventCattleInfoDto? cattleInfo;

  const PlannedEventDto({
    this.id,
    this.cattleId,
    this.cattleName,
    this.cattleTagNumber,
    this.daysUntil,
    this.eventType,
    this.plannedDate,
    this.priority,
    this.title,
    this.cattleInfo,
  });

  factory PlannedEventDto.fromJson(Map<String, dynamic> json) {
    return PlannedEventDto(
      id: (json['id'] as num?)?.toInt(),
      daysUntil: (json['daysUntil'] as num?)?.toInt(),
      eventType: json['eventType'] as String?,
      plannedDate: json['plannedDate'] as String?,
      priority: (json['priority'] as num?)?.toInt(),
      title: json['title'] as String?,
      cattleInfo: json['cattleInfo'] == null
          ? null
          : PlannedEventCattleInfoDto.fromJson(
              json['cattleInfo'] as Map<String, dynamic>,
            ),
    );
  }
}

class PlannedEventCattleInfoDto {
  final String? category; // "COW", "HEIFER"...
  final int? cattleId;
  final String? cattleName;
  final String? cattleTagNumber;

  const PlannedEventCattleInfoDto({
    this.category,
    this.cattleId,
    this.cattleName,
    this.cattleTagNumber,
  });

  factory PlannedEventCattleInfoDto.fromJson(Map<String, dynamic> json) {
    return PlannedEventCattleInfoDto(
      category: json['category'] as String?,
      cattleId: (json['cattleId'] as num?)?.toInt(),
      cattleName: json['cattleName'] as String?,
      cattleTagNumber: json['cattleTagNumber'] as String?,
    );
  }
}
