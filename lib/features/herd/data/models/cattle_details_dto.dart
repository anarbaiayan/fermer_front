import 'package:frontend/features/herd/data/models/upcoming_event_dto.dart';

class CattleDetailsDto {
  final String? breed;
  final String? animalGroup;
  final String? healthStatus;

  final double? lastWeight;
  final String? vaccinationInfo;

  final double? lastMilkYield;
  final String? lastCalvingDate;
  final String? lastInseminationDate;
  final String? pregnancyStatus;
  final bool? isDryPeriod;

  final String? firstInseminationDate;
  final String? expectedCalvingDate;

  final String? bullPurpose;

  // было раньше, но бэк просит пока не отправлять
  final String? cattleCurrentState;

  // NEW - только для чтения из GET /details
  final bool? isPregnant;
  final String? reproductiveState;
  final String? productionState;

  final List<UpcomingEventDto>? upcomingEvents;

  const CattleDetailsDto({
    this.breed,
    this.animalGroup,
    this.healthStatus,
    this.lastWeight,
    this.vaccinationInfo,
    this.lastMilkYield,
    this.lastCalvingDate,
    this.lastInseminationDate,
    this.pregnancyStatus,
    this.isDryPeriod,
    this.firstInseminationDate,
    this.expectedCalvingDate,
    this.bullPurpose,
    this.cattleCurrentState,
    this.isPregnant,
    this.reproductiveState,
    this.productionState,
    this.upcomingEvents,
  });

  factory CattleDetailsDto.fromJson(Map<String, dynamic> json) {
    return CattleDetailsDto(
      breed: json['breed'] as String?,
      animalGroup: json['animalGroup'] as String?,
      healthStatus: json['healthStatus'] as String?,
      lastWeight: (json['lastWeight'] as num?)?.toDouble(),
      vaccinationInfo: json['vaccinationInfo'] as String?,
      lastMilkYield: (json['lastMilkYield'] as num?)?.toDouble(),
      lastCalvingDate: json['lastCalvingDate'] as String?,
      lastInseminationDate: json['lastInseminationDate'] as String?,
      pregnancyStatus: json['pregnancyStatus'] as String?,
      isDryPeriod: json['isDryPeriod'] as bool?,
      firstInseminationDate: json['firstInseminationDate'] as String?,
      expectedCalvingDate: json['expectedCalvingDate'] as String?,
      bullPurpose: json['bullPurpose'] as String?,

      cattleCurrentState: json['cattleCurrentState'] as String?,
      isPregnant: json['isPregnant'] as bool?,
      reproductiveState: json['reproductiveState'] as String?,
      productionState: json['productionState'] as String?,
      upcomingEvents: (json['upcomingEvents'] as List?)
          ?.whereType<Map<String, dynamic>>()
          .map(UpcomingEventDto.fromJson)
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'breed': breed,
      'animalGroup': animalGroup,
      'healthStatus': healthStatus,
      'lastWeight': lastWeight,
      'vaccinationInfo': vaccinationInfo,
      'lastMilkYield': lastMilkYield,
      'lastCalvingDate': lastCalvingDate,
      'lastInseminationDate': lastInseminationDate,
      'pregnancyStatus': pregnancyStatus,
      'isDryPeriod': isDryPeriod,
      'firstInseminationDate': firstInseminationDate,
      'expectedCalvingDate': expectedCalvingDate,
      'bullPurpose': bullPurpose,

      // ВАЖНО: пока не отправляем state, как просит бэк
      // 'cattleCurrentState': cattleCurrentState,

      // ВАЖНО: эти поля только read-only из GET /details
      // 'isPregnant': isPregnant,
      // 'reproductiveState': reproductiveState,
      // 'productionState': productionState,
    };

    map.removeWhere((k, v) => v == null);
    return map;
  }
}
