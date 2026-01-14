import 'package:intl/intl.dart';
import '../../domain/entities/lactation.dart';
import '../../domain/entities/milking_time.dart';
import 'lactation_dto.dart';

final _dateFmt = DateFormat('yyyy-MM-dd');

DateTime _parseYmd(String? s) {
  if (s == null) return DateTime.fromMillisecondsSinceEpoch(0);
  try {
    return _dateFmt.parseStrict(s);
  } catch (_) {
    return DateTime.fromMillisecondsSinceEpoch(0);
  }
}

DateTime? _tryParse(String? s) => s == null ? null : DateTime.tryParse(s);

Lactation lactationFromDto(LactationDto d) {
  return Lactation(
    id: d.id ?? 0,
    cattleId: d.cattleId ?? 0,
    cattleTagNumber: d.cattleTagNumber ?? '',
    cattleName: d.cattleName ?? '',
    milkingDate: _parseYmd(d.milkingDate),
    milkingDateTime: _tryParse(d.milkingDateTime),
    milkingTime: MilkingTimeX.fromApi(d.milkingTime),
    milkLiters: d.milkLiters ?? 0,
    milkKg: d.milkKg ?? 0,
    notes: d.notes,
    createdAt: _tryParse(d.createdAt),
    updatedAt: _tryParse(d.updatedAt),
  );
}

/// локальный расчет (для UI до отправки), бэк все равно посчитает сам
double milkKgFromLiters(double liters) => liters * 1.03;
