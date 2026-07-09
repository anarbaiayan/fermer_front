/// Статус заявки на препарат. `unknown` — safe fallback на случай, если бэк
/// добавит новый статус, о котором фронт ещё не знает.
///
/// Локализуется на фронте (см. l10n `pharmacyStatus*`), а не через
/// `statusDescription` из ответа, который приходит только по-русски.
enum VetRequestStatus {
  newRequest('NEW'),
  inProgress('IN_PROGRESS'),
  done('DONE'),
  cancelled('CANCELLED'),
  unknown('UNKNOWN');

  final String raw;
  const VetRequestStatus(this.raw);

  static VetRequestStatus fromRaw(String? value) {
    if (value == null) return VetRequestStatus.unknown;
    final upper = value.trim().toUpperCase();
    for (final status in VetRequestStatus.values) {
      if (status.raw == upper) return status;
    }
    return VetRequestStatus.unknown;
  }
}
