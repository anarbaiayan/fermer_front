import 'cattle_gender.dart';

class CattleDetails {
  final String? breed;
  final String? animalGroup;
  final String? healthStatus;
  final double? lastMilkYield;
  final DateTime? lastCalvingDate;
  final DateTime? lastInseminationDate;
  final String? pregnancyStatus;
  final bool? isDryPeriod;

  const CattleDetails({
    this.breed,
    this.animalGroup,
    this.healthStatus,
    this.lastMilkYield,
    this.lastCalvingDate,
    this.lastInseminationDate,
    this.pregnancyStatus,
    this.isDryPeriod,
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
