import 'package:flutter/foundation.dart';

// Даты операций в «Финансах» — календарные дни без времени, как LocalDate
// на бэкенде. Храним их полночью UTC: разница двух таких дат всегда целое
// число суток, без сдвигов из-за часового пояса устройства.

/// Календарный день [moment] по часам устройства.
DateTime dateOnly(DateTime moment) =>
    DateTime.utc(moment.year, moment.month, moment.day);

DateTime addDays(DateTime day, int days) =>
    DateTime.utc(day.year, day.month, day.day + days);

/// Число суток от [from] до [to]; отрицательное, если [to] раньше.
int daysBetween(DateTime from, DateTime to) =>
    dateOnly(to).difference(dateOnly(from)).inDays;

DateTime monthStart(DateTime day) => DateTime.utc(day.year, day.month);

DateTime addMonths(DateTime month, int months) =>
    DateTime.utc(month.year, month.month + months);

/// `2026-09-19` — формат LocalDate в API.
String formatApiDate(DateTime day) {
  final d = dateOnly(day);
  final mm = d.month.toString().padLeft(2, '0');
  final dd = d.day.toString().padLeft(2, '0');
  return '${d.year.toString().padLeft(4, '0')}-$mm-$dd';
}

DateTime parseApiDate(String value) {
  final parts = value.trim().split('-');
  if (parts.length != 3) throw FormatException('Invalid date: $value');
  return DateTime.utc(
    int.parse(parts[0]),
    int.parse(parts[1]),
    int.parse(parts[2]),
  );
}

DateTime? parseApiDateOrNull(Object? value) {
  if (value == null) return null;
  final text = value.toString().trim();
  return text.isEmpty ? null : parseApiDate(text);
}

/// Период отчёта или сводки, обе границы включительно.
@immutable
class FinancePeriod {
  FinancePeriod(DateTime from, DateTime to)
    : from = dateOnly(from),
      to = dateOnly(to);

  /// Календарный месяц, в который попадает [day].
  factory FinancePeriod.month(DateTime day) => FinancePeriod(
    DateTime.utc(day.year, day.month),
    DateTime.utc(day.year, day.month + 1, 0),
  );

  final DateTime from;
  final DateTime to;

  bool contains(DateTime day) {
    final d = dateOnly(day);
    return !d.isBefore(from) && !d.isAfter(to);
  }

  @override
  bool operator ==(Object other) =>
      other is FinancePeriod && other.from == from && other.to == to;

  @override
  int get hashCode => Object.hash(from, to);

  @override
  String toString() =>
      'FinancePeriod(${formatApiDate(from)}..${formatApiDate(to)})';
}
