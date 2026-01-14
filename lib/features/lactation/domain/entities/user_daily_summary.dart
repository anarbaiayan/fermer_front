class UserDailySummary {
  final DateTime date;
  final double totalLiters;
  final double totalKg;
  final int cowCount;
  final List<UserDailyCowSummary> details;

  const UserDailySummary({
    required this.date,
    required this.totalLiters,
    required this.totalKg,
    required this.cowCount,
    required this.details,
  });
}

class UserDailyCowSummary {
  final int cattleId;
  final String cattleTagNumber;
  final String cattleName;
  final double morningLiters;
  final double eveningLiters;
  final double totalLiters;
  final double totalKg;

  const UserDailyCowSummary({
    required this.cattleId,
    required this.cattleTagNumber,
    required this.cattleName,
    required this.morningLiters,
    required this.eveningLiters,
    required this.totalLiters,
    required this.totalKg,
  });
}
