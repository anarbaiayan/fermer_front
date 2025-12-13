import 'package:frontend/features/herd/domain/entities/cattle_gender.dart';
import 'package:frontend/features/herd/domain/entities/health_status.dart';

class CattleEditData {
  final int id;
  final String name;
  final String tagNumber;
  final CattleGender gender;
  final DateTime dateOfBirth;

  // details
  final String? breed;
  final String? animalGroup;
  final HealthStatus? healthStatus;

  final double? lastWeight;
  final String? vaccinationInfo;

  final double? lastMilkYield;
  final DateTime? lastCalvingDate;
  final DateTime? lastInseminationDate;
  final String? pregnancyStatus;
  final bool? isDryPeriod;

  final DateTime? firstInseminationDate;
  final DateTime? expectedCalvingDate;

  const CattleEditData({
    required this.id,
    required this.name,
    required this.tagNumber,
    required this.gender,
    required this.dateOfBirth,
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
  });
}
