import 'cattle_details_dto.dart';

class CattleDto {
  final int? id;
  final String name;
  final String tagNumber;
  final String gender;
  final String dateOfBirth;

  // детали (как раньше)
  final CattleDetailsDto? details;

  // новые поля от бэка (если захочешь где-то использовать)
  final String? category;
  final int? ageInMonths;
  final String? ageDisplay;
  final bool? detailsCompleted;

  CattleDto({
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
  });

  factory CattleDto.fromJson(Map<String, dynamic> json) {
    // 1) старый вариант: details: { ... }
    CattleDetailsDto? details;
    if (json['details'] != null) {
      details = CattleDetailsDto.fromJson(
        json['details'] as Map<String, dynamic>,
      );
    } else {
      // 2) новый вариант: плоские поля на верхнем уровне
      final hasAnyDetailsField =
          json['breed'] != null ||
          json['animalGroup'] != null ||
          json['healthStatus'] != null ||
          json['lastMilkYield'] != null ||
          json['lastCalvingDate'] != null ||
          json['lastInseminationDate'] != null ||
          json['pregnancyStatus'] != null ||
          json['isDryPeriod'] != null;

      if (hasAnyDetailsField) {
        details = CattleDetailsDto(
          breed: json['breed'] as String?,
          animalGroup: json['animalGroup'] as String?,
          healthStatus: json['healthStatus'] as String?,
          lastMilkYield: (json['lastMilkYield'] as num?)?.toDouble(),
          lastCalvingDate: json['lastCalvingDate'] as String?,
          lastInseminationDate: json['lastInseminationDate'] as String?,
          pregnancyStatus: json['pregnancyStatus'] as String?,
          isDryPeriod: json['isDryPeriod'] as bool?,
        );
      }
    }

    return CattleDto(
      id: json['id'] as int?,
      name: json['name'] as String,
      tagNumber: json['tagNumber'] as String,
      gender: json['gender'] as String,
      dateOfBirth: json['dateOfBirth'] as String,
      details: details,
      category: json['category'] as String?,
      ageInMonths: json['ageInMonths'] as int?,
      ageDisplay: json['ageDisplay'] as String?,
      detailsCompleted: json['detailsCompleted'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'tagNumber': tagNumber,
      'gender': gender,
      'dateOfBirth': dateOfBirth,
      if (details != null) 'details': details!.toJson(),
    };
  }
}
