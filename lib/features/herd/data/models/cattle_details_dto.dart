class CattleDetailsDto {
  final String? breed;
  final String? animalGroup;
  final String? healthStatus;       // "HEALTHY", "SICK" и тд
  final double? lastMilkYield;
  final String? lastCalvingDate;    // "2024-03-15"
  final String? lastInseminationDate;
  final String? pregnancyStatus;    // "PREGNANT", "NOT_PREGNANT"
  final bool? isDryPeriod;

  CattleDetailsDto({
    this.breed,
    this.animalGroup,
    this.healthStatus,
    this.lastMilkYield,
    this.lastCalvingDate,
    this.lastInseminationDate,
    this.pregnancyStatus,
    this.isDryPeriod,
  });

  factory CattleDetailsDto.fromJson(Map<String, dynamic> json) {
    return CattleDetailsDto(
      breed: json['breed'] as String?,
      animalGroup: json['animalGroup'] as String?,
      healthStatus: json['healthStatus'] as String?,
      lastMilkYield: (json['lastMilkYield'] as num?)?.toDouble(),
      lastCalvingDate: json['lastCalvingDate'] as String?,
      lastInseminationDate: json['lastInseminationDate'] as String?,
      pregnancyStatus: json['pregnancyStatus'] as String?,
      isDryPeriod: json['isDryPeriod'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'breed': breed,
      'animalGroup': animalGroup,
      'healthStatus': healthStatus,
      'lastMilkYield': lastMilkYield,
      'lastCalvingDate': lastCalvingDate,
      'lastInseminationDate': lastInseminationDate,
      'pregnancyStatus': pregnancyStatus,
      'isDryPeriod': isDryPeriod,
    };
  }
}
