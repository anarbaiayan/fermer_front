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

  // NEW milk/lactation fields (read-only from GET /api/details/{cattleId})
  final double? averageMilkYield7Days;
  final double? averageMilkYield30Days;

  final int? currentLactationNumber;
  final int? daysInMilk;
  final int? daysSinceCalving;

  final double? peakMilkYieldCurrentLactation;
  final double? totalMilkCurrentLactation;

  final String? lastMilkYieldDate;

  final bool? isLactating;
  final bool? isFreshCow;
  final bool? isCalvingSoon;

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
    this.averageMilkYield7Days,
    this.averageMilkYield30Days,
    this.currentLactationNumber,
    this.daysInMilk,
    this.daysSinceCalving,
    this.peakMilkYieldCurrentLactation,
    this.totalMilkCurrentLactation,
    this.lastMilkYieldDate,
    this.isLactating,
    this.isFreshCow,
    this.isCalvingSoon,
  });

  factory CattleDetailsDto.fromJson(Map<String, dynamic> json) {
    int? asInt(dynamic v) {
      if (v == null) return null;
      if (v is int) return v;
      if (v is num) return v.toInt();
      return int.tryParse(v.toString());
    }

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
      averageMilkYield7Days: (json['averageMilkYield7Days'] as num?)
          ?.toDouble(),
      averageMilkYield30Days: (json['averageMilkYield30Days'] as num?)
          ?.toDouble(),
      currentLactationNumber: asInt(json['currentLactationNumber']),
      daysInMilk: asInt(json['daysInMilk']),
      daysSinceCalving: asInt(json['daysSinceCalving']),
      peakMilkYieldCurrentLactation:
          (json['peakMilkYieldCurrentLactation'] as num?)?.toDouble(),
      totalMilkCurrentLactation: (json['totalMilkCurrentLactation'] as num?)
          ?.toDouble(),
      lastMilkYieldDate: json['lastMilkYieldDate'] as String?,
      isLactating: json['isLactating'] as bool?,
      isFreshCow: json['isFreshCow'] as bool?,
      isCalvingSoon: json['isCalvingSoon'] as bool?,
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
      // 'averageMilkYield7Days': averageMilkYield7Days,
      // 'averageMilkYield30Days': averageMilkYield30Days,
      // 'currentLactationNumber': currentLactationNumber,
      // 'daysInMilk': daysInMilk,
      // 'daysSinceCalving': daysSinceCalving,
      // 'peakMilkYieldCurrentLactation': peakMilkYieldCurrentLactation,
      // 'totalMilkCurrentLactation': totalMilkCurrentLactation,
      // 'lastMilkYieldDate': lastMilkYieldDate,
      // 'isLactating': isLactating,
      // 'isFreshCow': isFreshCow,
      // 'isCalvingSoon': isCalvingSoon,
    };

    map.removeWhere((k, v) => v == null);
    return map;
  }
}
