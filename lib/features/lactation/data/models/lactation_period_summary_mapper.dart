import '../../domain/entities/lactation_period_summary.dart';
import 'bulk_lactation_dto.dart';
import 'lactation_daily_summary_dto.dart';

LactationPeriodSummary lactationPeriodSummaryFromDtos(
  List<LactationDailySummaryDto> days,
  List<BulkLactationDto> bulk,
) {
  return LactationPeriodSummary(
    // Bulk-статистика фермы считается только по суточным отчётам. Контрольные
    // замеры отдельных коров — отдельный набор данных: если сложить их с
    // отчётами по ферме, молоко будет учтено дважды.
    // The API cannot identify individual cows within bulk records.
    reportedCowCount: days.fold(0, (sum, day) => sum + (day.bulkCowCount ?? 0)),
    totalMilkLiters: days.fold(0, (sum, day) => sum + (day.bulkLiters ?? 0)),
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
