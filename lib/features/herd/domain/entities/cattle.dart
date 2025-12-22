import 'package:frontend/features/herd/domain/entities/bull_purpose.dart';

import 'cattle_gender.dart';

class CattleDetails {
  final String? breed;
  final String? animalGroup;
  final String? healthStatus;

  final double? lastWeight;
  final String? vaccinationInfo;

  final double? lastMilkYield;
  final DateTime? lastCalvingDate;
  final DateTime? lastInseminationDate;
  final String? pregnancyStatus;
  final bool? isDryPeriod;

  final DateTime? firstInseminationDate;
  final DateTime? expectedCalvingDate;
  final BullPurpose? bullPurpose;

  const CattleDetails({
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
  });
}

class Cattle {
  final int id;
  final String name;
  final String tagNumber;
  final CattleGender gender;
  final DateTime dateOfBirth;
  final CattleDetails? details;

  const Cattle({
    required this.id,
    required this.name,
    required this.tagNumber,
    required this.gender,
    required this.dateOfBirth,
    this.details,
  });
}
