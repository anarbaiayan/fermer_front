class CreateBulkLactationDto {
  final String milkingDate; // yyyy-MM-dd
  final String? milkingDateTime; // ISO
  final String? milkingTime; // MORNING/EVENING

  final int numberOfCows;
  final double totalMilkLiters;

  final double? milkUsedForCalves;
  final double? unsuitableMilk;

  final String? notes;

  const CreateBulkLactationDto({
    required this.milkingDate,
    this.milkingDateTime,
    this.milkingTime,
    required this.numberOfCows,
    required this.totalMilkLiters,
    this.milkUsedForCalves,
    this.unsuitableMilk,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'milkingDate': milkingDate,
      'milkingDateTime': milkingDateTime,
      'milkingTime': milkingTime,
      'numberOfCows': numberOfCows,
      'totalMilkLiters': totalMilkLiters,
      'milkUsedForCalves': milkUsedForCalves,
      'unsuitableMilk': unsuitableMilk,
      'notes': notes,
    };

    map.removeWhere((k, v) => v == null);
    return map;
  }
}
