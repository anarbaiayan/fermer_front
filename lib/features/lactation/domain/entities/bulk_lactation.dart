import 'package:frontend/features/lactation/domain/entities/milking_time.dart';

class BulkLactation {
  final int id;
  final DateTime milkingDate;
  final DateTime? milkingDateTime;
  final MilkingTime? milkingTime;

  final int numberOfCows;
  final double totalMilkLiters;
  final double totalMilkKg;
  final double milkUsedForCalves;
  final double unsuitableMilk;
  final double commercialMilk;
  final double averageMilkPerCow;

  final String? notes;
  final int userId;

  const BulkLactation({
    required this.id,
    required this.milkingDate,
    required this.milkingDateTime,
    required this.milkingTime,
    required this.numberOfCows,
    required this.totalMilkLiters,
    required this.totalMilkKg,
    required this.milkUsedForCalves,
    required this.unsuitableMilk,
    required this.commercialMilk,
    required this.averageMilkPerCow,
    required this.notes,
    required this.userId,
  });
}
