enum LactationValidationError implements Exception {
  milk,
  cowCount,
  calvesMilk,
  unsuitableMilk,
  milkBalance,
  periodTooLong,
  incompleteData,
}

const maxLactationPeriodDays = 366;

double? parseMilkAmount(String value) =>
    double.tryParse(value.trim().replaceAll(',', '.'));

bool isValidMilkAmount(double? value, {bool allowZero = false}) =>
    value != null && value.isFinite && (allowZero ? value >= 0 : value > 0);

void validateMilkBalance({
  required double total,
  double? calves,
  double? unsuitable,
}) {
  if (!isValidMilkAmount(total)) throw LactationValidationError.milk;
  if (!isValidMilkAmount(calves ?? 0, allowZero: true)) {
    throw LactationValidationError.calvesMilk;
  }
  if (!isValidMilkAmount(unsuitable ?? 0, allowZero: true)) {
    throw LactationValidationError.unsuitableMilk;
  }
  // Tolerate floating-point rounding, not a meaningful excess of milk.
  if ((calves ?? 0) + (unsuitable ?? 0) - total > 1e-9) {
    throw LactationValidationError.milkBalance;
  }
}
