import 'package:frontend/features/lactation/domain/entities/milking_time.dart';

class Lactation {
  final int id;
  final int cattleId;
  final String cattleTagNumber;
  final String cattleName;

  final DateTime milkingDate;
  final DateTime? milkingDateTime;
  final MilkingTime? milkingTime;

  final double milkLiters;
  final double milkKg; // с бэка
  final String? notes;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Lactation({
    required this.id,
    required this.cattleId,
    required this.cattleTagNumber,
    required this.cattleName,
    required this.milkingDate,
    required this.milkingDateTime,
    required this.milkingTime,
    required this.milkLiters,
    required this.milkKg,
    required this.notes,
    required this.createdAt,
    required this.updatedAt,
  });
}
