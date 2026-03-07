import 'package:frontend/features/herd/domain/entities/bull_purpose.dart';
import 'package:frontend/features/herd/domain/entities/upcoming_event.dart';

import 'animal_category.dart';
import 'cattle_gender.dart';

class CattleDetails {
  final String? breed;
  final String? breedType;
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

  final bool? isPregnant;
  final String? reproductiveState;
  final String? productionState;
  final double? averageMilkYield7Days;
  final double? averageMilkYield30Days;

  final int? currentLactationNumber;
  final int? daysInMilk;
  final int? daysSinceCalving;

  final double? peakMilkYieldCurrentLactation;
  final double? totalMilkCurrentLactation;

  final DateTime? lastMilkYieldDate;

  final bool? isLactating;
  final bool? isFreshCow;
  final bool? isCalvingSoon;

  final List<UpcomingEvent>? upcomingEvents;

  const CattleDetails({
    this.breed,
    this.breedType,
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
}

class Cattle {
  final int id;
  final String name;
  final String tagNumber;
  final CattleGender gender;
  final DateTime dateOfBirth;
  final CattleDetails? details;

  /// Категория животного, приходящая с бэкенда.
  final AnimalCategory? category;

  /// Возраст в месяцах из бэкенда (если есть).
  final int? ageInMonths;

  /// Человекочитаемое представление возраста с бэкенда (если есть).
  final String? ageDisplay;

  const Cattle({
    required this.id,
    required this.name,
    required this.tagNumber,
    required this.gender,
    required this.dateOfBirth,
    this.details,
    this.category,
    this.ageInMonths,
    this.ageDisplay,
  });
}
