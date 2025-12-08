import 'package:intl/intl.dart';
import '../../domain/entities/cattle.dart';
import '../../domain/entities/cattle_gender.dart';
import 'cattle_dto.dart';
import 'cattle_details_dto.dart';

final _dateFmt = DateFormat('yyyy-MM-dd');

Cattle cattleFromDto(CattleDto dto) {
  return Cattle(
    id: dto.id ?? 0,
    name: dto.name,
    tagNumber: dto.tagNumber,
    gender: CattleGenderX.fromApi(dto.gender),
    dateOfBirth: _dateFmt.parse(dto.dateOfBirth),
    details: dto.details == null ? null : cattleDetailsFromDto(dto.details!),
  );
}

CattleDetails cattleDetailsFromDto(CattleDetailsDto dto) {
  DateTime? parse(String? s) => s == null ? null : _dateFmt.parse(s);

  return CattleDetails(
    breed: dto.breed,
    animalGroup: dto.animalGroup,
    healthStatus: dto.healthStatus,
    lastMilkYield: dto.lastMilkYield,
    lastCalvingDate: parse(dto.lastCalvingDate),
    lastInseminationDate: parse(dto.lastInseminationDate),
    pregnancyStatus: dto.pregnancyStatus,
    isDryPeriod: dto.isDryPeriod,
  );
}

CattleDto cattleToDtoForCreate({
  required String name,
  required String tagNumber,
  required CattleGender gender,
  required DateTime dateOfBirth,
}) {
  return CattleDto(
    name: name,
    tagNumber: tagNumber,
    gender: gender.apiValue,
    dateOfBirth: _dateFmt.format(dateOfBirth),
  );
}

CattleDetailsDto detailsToDtoForUpdate(CattleDetails details) {
  String? format(DateTime? d) => d == null ? null : _dateFmt.format(d);

  return CattleDetailsDto(
    breed: details.breed,
    animalGroup: details.animalGroup,
    healthStatus: details.healthStatus,
    lastMilkYield: details.lastMilkYield,
    lastCalvingDate: format(details.lastCalvingDate),
    lastInseminationDate: format(details.lastInseminationDate),
    pregnancyStatus: details.pregnancyStatus,
    isDryPeriod: details.isDryPeriod,
  );
}
