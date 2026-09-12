import '../../domain/entities/lactation_period_summary.dart';
import 'bulk_lactation_dto.dart';
import 'lactation_daily_summary_dto.dart';

LactationPeriodSummary lactationPeriodSummaryFromDtos(
  List<LactationDailySummaryDto> days,
  List<BulkLactationDto> bulk,
) {
  return LactationPeriodSummary(
    // The API cannot identify individual cows within bulk records.
    reportedCowCount: days.fold(0, (sum, day) => sum + day.cowCount),
    // Daily totals already include bulk milk: do not add it a second time.
    totalMilkLiters: days.fold(0, (sum, day) => sum + day.totalLiters),
    milkUsedForCalves: bulk.fold(
      0,
      (sum, item) => sum + (item.milkUsedForCalves ?? 0),
    ),
    unsuitableMilk: bulk.fold(
      0,
      (sum, item) => sum + (item.unsuitableMilk ?? 0),
    ),
    // Check records, not just the net total: valid records can mask bad ones.
    hasInvalidMilkBalance: bulk.any(
      (item) =>
          (item.commercialMilk ?? 0) < 0 ||
          (item.milkUsedForCalves ?? 0) < 0 ||
          (item.unsuitableMilk ?? 0) < 0 ||
          (item.milkUsedForCalves ?? 0) +
                  (item.unsuitableMilk ?? 0) -
                  (item.totalMilkLiters ?? 0) >
              1e-9,
    ),
  );
}
