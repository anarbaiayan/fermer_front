import '../../domain/entities/lactation_validation.dart';

class CreateLactationDto {
  final int cattleId;
  final String milkingDate; // yyyy-MM-dd
  final String milkingDateTime; // ISO
  final String milkingTime; // MORNING/EVENING
  final double milkLiters;
  final String? notes;

  const CreateLactationDto({
    required this.cattleId,
    required this.milkingDate,
    required this.milkingDateTime,
    required this.milkingTime,
    required this.milkLiters,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    if (!isValidMilkAmount(milkLiters)) throw LactationValidationError.milk;
    final map = <String, dynamic>{
      'cattleId': cattleId,
      'milkingDate': milkingDate,
      'milkingDateTime': milkingDateTime,
      'milkingTime': milkingTime,
      'milkLiters': milkLiters,
      'notes': notes,
    };
    map.removeWhere((k, v) => v == null);
    return map;
  }
}
