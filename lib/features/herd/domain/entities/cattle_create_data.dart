import 'package:frontend/features/herd/domain/entities/cattle_gender.dart';

class CattleCreateData {
  final String name;
  final String tagNumber;
  final CattleGender gender;
  final DateTime dateOfBirth;

  const CattleCreateData({
    required this.name,
    required this.tagNumber,
    required this.gender,
    required this.dateOfBirth,
  });
}
