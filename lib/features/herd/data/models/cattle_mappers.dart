import 'package:frontend/features/herd/data/models/upcoming_event_dto.dart';
import 'package:frontend/features/herd/domain/entities/animal_category.dart';
import 'package:frontend/features/herd/domain/entities/bull_purpose.dart';
import 'package:frontend/features/herd/domain/entities/cattle.dart';
import 'package:frontend/features/herd/domain/entities/cattle_gender.dart';
import 'package:frontend/features/herd/domain/entities/upcoming_event.dart';
import 'package:intl/intl.dart';
import 'cattle_dto.dart';
import 'cattle_details_dto.dart';

final _dateFmt = DateFormat('yyyy-MM-dd');

Cattle cattleFromDto(CattleDto dto) {
  final detailsDto =
      dto.details ??
      CattleDetailsDto(
        breed: dto.breed,
        breedType: dto.breedType,
        animalGroup: dto.animalGroup,
        healthStatus: dto.healthStatus,
        lastWeight: dto.lastWeight,
        vaccinationInfo: dto.vaccinationInfo,
        lastMilkYield: dto.lastMilkYield,
        lastCalvingDate: dto.lastCalvingDate,
        lastInseminationDate: dto.lastInseminationDate,
        pregnancyStatus: dto.pregnancyStatus,
        isDryPeriod: dto.isDryPeriod,
        firstInseminationDate: dto.firstInseminationDate,
        expectedCalvingDate: dto.expectedCalvingDate,
        bullPurpose: dto.bullPurpose,
      );

  // если вообще ничего нет - тогда null
  final hasAny =
      detailsDto.breed != null ||
      detailsDto.animalGroup != null ||
      detailsDto.healthStatus != null ||
      detailsDto.lastWeight != null ||
      detailsDto.vaccinationInfo != null ||
      detailsDto.lastMilkYield != null ||
      detailsDto.lastCalvingDate != null ||
      detailsDto.lastInseminationDate != null ||
      detailsDto.pregnancyStatus != null ||
      detailsDto.isDryPeriod != null ||
      detailsDto.firstInseminationDate != null ||
      detailsDto.expectedCalvingDate != null ||
      detailsDto.bullPurpose != null;

  return Cattle(
    id: dto.id ?? 0,
    name: dto.name,
    tagNumber: dto.tagNumber,
    gender: CattleGenderX.fromApi(dto.gender),
    dateOfBirth: _dateFmt.parse(dto.dateOfBirth),
    details: hasAny ? cattleDetailsFromDto(detailsDto) : null,
    category: dto.category == null
        ? null
        : AnimalCategoryX.fromApi(dto.category!),
    ageInMonths: dto.ageInMonths,
    ageDisplay: dto.ageDisplay,
  );
}

CattleDetails cattleDetailsFromDto(CattleDetailsDto dto) {
  List<UpcomingEvent>? mapUpcoming(List<UpcomingEventDto>? list) {
    if (list == null || list.isEmpty) return null;

    DateTime? tryParseDate(String? s) {
      final v = s?.trim();
      if (v == null || v.isEmpty) return null;
      try {
        return _dateFmt.parse(v);
      } catch (_) {
        try {
          return DateTime.parse(v);
        } catch (_) {
          return null;
        }
      }
    }

    return list
        .map(
          (e) => UpcomingEvent(
            id: e.id ?? 0,
            eventType: e.eventType ?? 'UNKNOWN',
            title: (e.title == null || e.title!.trim().isEmpty)
                ? (e.eventType ?? 'Событие')
                : e.title!.trim(),
            plannedDate: tryParseDate(e.plannedDate),
            daysUntil: e.daysUntil,
            priority: e.priority,
          ),
        )
        .toList();
  }

  DateTime? tryParseDate(String? s) {
    final v = s?.trim();
    if (v == null || v.isEmpty) return null;
    try {
      return _dateFmt.parse(v);
    } catch (_) {
      try {
        return DateTime.parse(v);
      } catch (_) {
        return null;
      }
    }
  }

  return CattleDetails(
    breed: dto.breed,
    breedType: dto.breedType,
    animalGroup: dto.animalGroup,
    healthStatus: dto.healthStatus,

    lastWeight: dto.lastWeight,
    vaccinationInfo: dto.vaccinationInfo,

    lastMilkYield: dto.lastMilkYield,
    lastCalvingDate: tryParseDate(dto.lastCalvingDate),
    lastInseminationDate: tryParseDate(dto.lastInseminationDate),
    pregnancyStatus: dto.pregnancyStatus,
    isDryPeriod: dto.isDryPeriod,

    firstInseminationDate: tryParseDate(dto.firstInseminationDate),
    expectedCalvingDate: tryParseDate(dto.expectedCalvingDate),
    bullPurpose: dto.bullPurpose == null
        ? null
        : BullPurposeX.fromApi(dto.bullPurpose!),
    isPregnant: dto.isPregnant,
    reproductiveState: dto.reproductiveState,
    productionState: dto.productionState,
    averageMilkYield7Days: dto.averageMilkYield7Days,
    averageMilkYield30Days: dto.averageMilkYield30Days,
    currentLactationNumber: dto.currentLactationNumber,
    daysInMilk: dto.daysInMilk,
    daysSinceCalving: dto.daysSinceCalving,
    peakMilkYieldCurrentLactation: dto.peakMilkYieldCurrentLactation,
    totalMilkCurrentLactation: dto.totalMilkCurrentLactation,
    lastMilkYieldDate: tryParseDate(dto.lastMilkYieldDate),
    isLactating: dto.isLactating,
    isFreshCow: dto.isFreshCow,
    isCalvingSoon: dto.isCalvingSoon,
    upcomingEvents: mapUpcoming(dto.upcomingEvents),
  );
}

/// Теперь create умеет принимать details (как требует POST /api/cattle)
CattleDto cattleToDtoForCreate({
  required String name,
  required String tagNumber,
  required CattleGender gender,
  required DateTime dateOfBirth,
  CattleDetailsDto? details,
}) {
  return CattleDto(
    name: name,
    tagNumber: tagNumber,
    gender: gender.apiValue,
    dateOfBirth: _dateFmt.format(dateOfBirth),
    details: details, // <- ключевое
  );
}

CattleDetailsDto detailsToDtoForUpdate(CattleDetails details) {
  String? format(DateTime? d) => d == null ? null : _dateFmt.format(d);

  return CattleDetailsDto(
    breed: details.breed,
    breedType: details.breedType,
    animalGroup: details.animalGroup,
    healthStatus: details.healthStatus,

    lastWeight: details.lastWeight,
    vaccinationInfo: details.vaccinationInfo,

    lastMilkYield: details.lastMilkYield,
    lastCalvingDate: format(details.lastCalvingDate),
    lastInseminationDate: format(details.lastInseminationDate),
    pregnancyStatus: details.pregnancyStatus,
    isDryPeriod: details.isDryPeriod,

    firstInseminationDate: format(details.firstInseminationDate),
    expectedCalvingDate: format(details.expectedCalvingDate),
    bullPurpose: details.bullPurpose?.apiValue,
  );
}
