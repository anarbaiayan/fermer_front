class CattleDetailsDto {
  final String? breed;
  final String? animalGroup;
  final String? healthStatus; // "HEALTHY", "SICK" и тд

  final double? lastWeight;
  final String? vaccinationInfo;

  final double? lastMilkYield;
  final String? lastCalvingDate; // "2024-03-15"
  final String? lastInseminationDate;
  final String? pregnancyStatus; // "PREGNANT", "NOT_PREGNANT"
  final bool? isDryPeriod;

  final String? firstInseminationDate;
  final String? expectedCalvingDate;

  const CattleDetailsDto({
    this.breed,
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
  });

  factory CattleDetailsDto.fromJson(Map<String, dynamic> json) {
    return CattleDetailsDto(
      breed: json['breed'] as String?,
      animalGroup: json['animalGroup'] as String?,
      healthStatus: json['healthStatus'] as String?,

      lastWeight: (json['lastWeight'] as num?)?.toDouble(),
      vaccinationInfo: json['vaccinationInfo'] as String?,

      lastMilkYield: (json['lastMilkYield'] as num?)?.toDouble(),
      lastCalvingDate: json['lastCalvingDate'] as String?,
      lastInseminationDate: json['lastInseminationDate'] as String?,
      pregnancyStatus: json['pregnancyStatus'] as String?,
      isDryPeriod: json['isDryPeriod'] as bool?,

      firstInseminationDate: json['firstInseminationDate'] as String?,
      expectedCalvingDate: json['expectedCalvingDate'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'breed': breed,
      'animalGroup': animalGroup,
      'healthStatus': healthStatus,

      'lastWeight': lastWeight,
      'vaccinationInfo': vaccinationInfo,

      'lastMilkYield': lastMilkYield,
      'lastCalvingDate': lastCalvingDate,
      'lastInseminationDate': lastInseminationDate,
      'pregnancyStatus': pregnancyStatus,
      'isDryPeriod': isDryPeriod,

      'firstInseminationDate': firstInseminationDate,
      'expectedCalvingDate': expectedCalvingDate,
    };

    // важно: для PATCH/POST не отправляем null поля
    map.removeWhere((k, v) => v == null);
    return map;
  }
}
