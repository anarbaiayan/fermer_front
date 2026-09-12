class LactationPeriodSummary {
  final int reportedCowCount;
  final double totalMilkLiters;
  final double milkUsedForCalves;
  final double unsuitableMilk;
  final bool hasInvalidMilkBalance;

  const LactationPeriodSummary({
    required this.reportedCowCount,
    required this.totalMilkLiters,
    required this.milkUsedForCalves,
    required this.unsuitableMilk,
    required this.hasInvalidMilkBalance,
  });
}
