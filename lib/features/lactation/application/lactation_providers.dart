import 'package:dio/dio.dart';
import 'package:frontend/features/lactation/data/models/bulk_lactation_dto.dart';
import 'package:frontend/features/lactation/data/models/create_bulk_lactation_dto.dart';
import 'package:frontend/features/lactation/data/models/lactation_daily_summary_dto.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import '../data/datasources/lactation_api.dart';
import '../data/models/lactation_mappers.dart';
import '../domain/entities/lactation.dart';
import '../domain/entities/lactation_period_summary.dart';
import '../domain/entities/lactation_validation.dart';
import '../data/models/lactation_period_summary_mapper.dart';

final lactationByIdProvider = FutureProvider.autoDispose.family<Lactation, int>(
  (ref, id) async {
    final api = ref.read(lactationApiProvider);
    final dto = await api.getById(id);
    return lactationFromDto(dto);
  },
);

final lactationsByCattleProvider = FutureProvider.autoDispose
    .family<List<Lactation>, int>((ref, cattleId) async {
      final api = ref.read(lactationApiProvider);
      final cancelToken = CancelToken();
      ref.onDispose(() => cancelToken.cancel());
      final records = await api.getAllByCattle(
        cattleId,
        cancelToken: cancelToken,
      );
      return records.map(lactationFromDto).toList();
    });

final lactationDailySummaryProvider =
    FutureProvider.autoDispose<LactationDailySummaryDto>((ref) async {
      final api = ref.read(lactationApiProvider);
      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final cancelToken = CancelToken();
      ref.onDispose(() => cancelToken.cancel());
      return api.getDailySummary(date: today, cancelToken: cancelToken);
    });

final createBulkLactationProvider =
    Provider<Future<BulkLactationDto> Function(CreateBulkLactationDto dto)>((
      ref,
    ) {
      return (dto) async {
        final api = ref.read(lactationApiProvider);
        final created = await api.createBulk(dto);

        _invalidateExisting(ref, [
          lactationDailySummaryProvider,
          lactationBulkListProvider,
          lactationPeriodSummaryProvider,
        ]);

        return created;
      };
    });

void _invalidateExisting(Ref ref, List<ProviderBase<Object?>> providers) {
  // Do not instantiate unrelated screens just to invalidate their caches.
  for (final provider in providers) {
    if (ref.exists(provider)) ref.invalidate(provider);
  }
}

enum LactationRangeMode { week, month, period }

class LactationRangeState {
  final LactationRangeMode mode;
  final DateTime from;
  final DateTime to;

  const LactationRangeState({
    required this.mode,
    required this.from,
    required this.to,
  });

  LactationRangeState copyWith({
    LactationRangeMode? mode,
    DateTime? from,
    DateTime? to,
  }) {
    return LactationRangeState(
      mode: mode ?? this.mode,
      from: from ?? this.from,
      to: to ?? this.to,
    );
  }
}

class LactationRangeNotifier extends StateNotifier<LactationRangeState> {
  LactationRangeNotifier() : super(_initial());

  static DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  static DateTime _startOfWeekMonday(DateTime d) {
    final x = _dateOnly(d);
    // weekday: Mon=1 ... Sun=7
    return x.subtract(Duration(days: x.weekday - DateTime.monday));
  }

  static DateTime _endOfWeekSunday(DateTime d) {
    final start = _startOfWeekMonday(d);
    return start.add(const Duration(days: 6));
  }

  static DateTime _startOfMonth(DateTime d) => DateTime(d.year, d.month, 1);

  static DateTime _endOfMonth(DateTime d) {
    // последний день месяца: первый день следующего месяца - 1 день
    final firstNext = (d.month == 12)
        ? DateTime(d.year + 1, 1, 1)
        : DateTime(d.year, d.month + 1, 1);
    return firstNext.subtract(const Duration(days: 1));
  }

  static LactationRangeState _initial() {
    final now = DateTime.now();
    final from = _startOfWeekMonday(now);
    final to = _endOfWeekSunday(now);
    return LactationRangeState(
      mode: LactationRangeMode.week,
      from: from,
      to: to,
    );
  }

  void setMode(LactationRangeMode mode) {
    final now = DateTime.now();

    if (mode == LactationRangeMode.week) {
      state = state.copyWith(
        mode: mode,
        from: _startOfWeekMonday(now),
        to: _endOfWeekSunday(now),
      );
      return;
    }

    if (mode == LactationRangeMode.month) {
      state = state.copyWith(
        mode: mode,
        from: _startOfMonth(now),
        to: _endOfMonth(now),
      );
      return;
    }

    // period - оставляем текущие from/to как есть
    state = state.copyWith(mode: mode);
  }

  void setFrom(DateTime from) {
    final fixedFrom = _dateOnly(from);
    final fixedTo = _dateOnly(state.to);

    if (fixedFrom.isAfter(fixedTo)) {
      state = state.copyWith(from: fixedTo, to: fixedFrom);
    } else {
      state = state.copyWith(from: fixedFrom);
    }
  }

  void setTo(DateTime to) {
    final fixedTo = _dateOnly(to);
    final fixedFrom = _dateOnly(state.from);

    if (fixedTo.isBefore(fixedFrom)) {
      state = state.copyWith(from: fixedTo, to: fixedFrom);
    } else {
      state = state.copyWith(to: fixedTo);
    }
  }
}

final lactationRangeProvider =
    StateNotifierProvider<LactationRangeNotifier, LactationRangeState>((ref) {
      return LactationRangeNotifier();
    });

final lactationBulkListProvider =
    FutureProvider.autoDispose<List<BulkLactationDto>>((ref) async {
      final api = ref.read(lactationApiProvider);
      final range = ref.watch(lactationRangeProvider);
      final fmt = DateFormat('yyyy-MM-dd');

      _validateRange(range);
      final cancelToken = CancelToken();
      ref.onDispose(() => cancelToken.cancel());
      return api.getAllBulk(
        cancelToken: cancelToken,
        dateFrom: fmt.format(range.from),
        dateTo: fmt.format(range.to),
      );
    });

void _validateRange(LactationRangeState range) {
  final from = DateTime.utc(range.from.year, range.from.month, range.from.day);
  final to = DateTime.utc(range.to.year, range.to.month, range.to.day);
  final days = to.difference(from).inDays + 1;
  if (days < 1 || days > maxLactationPeriodDays) {
    throw LactationValidationError.periodTooLong;
  }
}

final lactationPeriodSummaryProvider =
    FutureProvider.autoDispose<LactationPeriodSummary>((ref) async {
      final range = ref.watch(lactationRangeProvider);
      _validateRange(range);
      final api = ref.read(lactationApiProvider);
      final cancelToken = CancelToken();
      ref.onDispose(() => cancelToken.cancel());
      final results = await Future.wait<Object>([
        api.getDailySummaries(
          from: range.from,
          to: range.to,
          cancelToken: cancelToken,
        ),
        ref.watch(lactationBulkListProvider.future),
      ]);
      return lactationPeriodSummaryFromDtos(
        results[0] as List<LactationDailySummaryDto>,
        results[1] as List<BulkLactationDto>,
      );
    });
