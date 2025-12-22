import 'package:frontend/features/herd/domain/entities/bull_purpose.dart';
import 'package:frontend/features/herd/domain/entities/cattle.dart';
import 'package:frontend/features/herd/domain/entities/cattle_gender.dart';
import 'package:intl/intl.dart';
import 'cattle_dto.dart';
import 'cattle_details_dto.dart';

final _dateFmt = DateFormat('yyyy-MM-dd');

Cattle cattleFromDto(CattleDto dto) {
  final detailsDto =
      dto.details ??
      CattleDetailsDto(
        breed: dto.breed,
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
  );
}

CattleDetails cattleDetailsFromDto(CattleDetailsDto dto) {
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
