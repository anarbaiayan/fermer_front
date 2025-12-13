import 'cattle_details_dto.dart';

class CattleDto {
  final int? id;
  final String name;
  final String tagNumber;
  final String gender;
  final String dateOfBirth;

  // детали (может быть либо details:{}, либо плоские поля)
  final CattleDetailsDto? details;

  // базовые поля от бэка
  final String? category;
  final int? ageInMonths;
  final String? ageDisplay;
  final bool? detailsCompleted;

  // дополнительные поля из swagger response (optional, чтобы не ломать)
  final String? cattleState;
  final double? currentWeight;
  final String? lastWeighedDate;
  final String? dryPeriodStartDate;
  final String? illnessDescription;
  final String? treatmentStartDate;
  final String? treatmentEndDate;
  final int? daysUntilCalving;
  final int? daysPregnant;
  final int? daysAfterCalving;
  final String? weaningDate;

  const CattleDto({
    this.id,
    required this.name,
    required this.tagNumber,
    required this.gender,
    required this.dateOfBirth,
    this.details,
    this.category,
    this.ageInMonths,
    this.ageDisplay,
    this.detailsCompleted,
    this.cattleState,
    this.currentWeight,
    this.lastWeighedDate,
    this.dryPeriodStartDate,
    this.illnessDescription,
    this.treatmentStartDate,
    this.treatmentEndDate,
    this.daysUntilCalving,
    this.daysPregnant,
    this.daysAfterCalving,
    this.weaningDate,
  });

  factory CattleDto.fromJson(Map<String, dynamic> json) {
    CattleDetailsDto? details;

    // 1) вариант: details: { ... }
    if (json['details'] != null) {
      details = CattleDetailsDto.fromJson(json['details'] as Map<String, dynamic>);
    } else {
      // 2) вариант: плоские детали на верхнем уровне
      final hasAnyDetailsField =
          json['breed'] != null ||
          json['animalGroup'] != null ||
          json['healthStatus'] != null ||
          json['lastWeight'] != null ||
          json['vaccinationInfo'] != null ||
          json['lastMilkYield'] != null ||
          json['lastCalvingDate'] != null ||
          json['lastInseminationDate'] != null ||
          json['pregnancyStatus'] != null ||
          json['isDryPeriod'] != null ||
          json['firstInseminationDate'] != null ||
          json['expectedCalvingDate'] != null;

      if (hasAnyDetailsField) {
        details = CattleDetailsDto(
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
        );
      }
    }

    int? asInt(dynamic v) {
      if (v == null) return null;
      if (v is int) return v;
      if (v is num) return v.toInt();
      return int.tryParse(v.toString());
    }

    return CattleDto(
      id: asInt(json['id']),
      name: json['name'] as String,
      tagNumber: json['tagNumber'] as String,
      gender: json['gender'] as String,
      dateOfBirth: json['dateOfBirth'] as String,
      details: details,
      category: json['category'] as String?,
      ageInMonths: asInt(json['ageInMonths']),
      ageDisplay: json['ageDisplay'] as String?,
      detailsCompleted: json['detailsCompleted'] as bool?,

      cattleState: json['cattleState'] as String?,
      currentWeight: (json['currentWeight'] as num?)?.toDouble(),
      lastWeighedDate: json['lastWeighedDate'] as String?,
      dryPeriodStartDate: json['dryPeriodStartDate'] as String?,
      illnessDescription: json['illnessDescription'] as String?,
      treatmentStartDate: json['treatmentStartDate'] as String?,
      treatmentEndDate: json['treatmentEndDate'] as String?,
      daysUntilCalving: asInt(json['daysUntilCalving']),
      daysPregnant: asInt(json['daysPregnant']),
      daysAfterCalving: asInt(json['daysAfterCalving']),
      weaningDate: json['weaningDate'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      if (id != null) 'id': id,
      'name': name,
      'tagNumber': tagNumber,
      'gender': gender,
      'dateOfBirth': dateOfBirth,
      if (details != null) 'details': details!.toJson(),
    };

    // на всякий: если вдруг details пустой, лучше не слать
    if (map['details'] is Map && (map['details'] as Map).isEmpty) {
      map.remove('details');
    }

    return map;
  }
}
