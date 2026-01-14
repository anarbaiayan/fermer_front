import 'package:frontend/features/lactation/data/models/bulk_lactation_dto.dart';
import 'package:frontend/features/lactation/data/models/create_bulk_lactation_dto.dart';
import 'package:frontend/features/lactation/data/models/lactation_daily_summary_dto.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import '../data/datasources/lactation_api.dart';
import '../data/models/create_lactation_dto.dart';
import '../data/models/lactation_mappers.dart';
import '../domain/entities/lactation.dart';

final lactationByIdProvider = FutureProvider.family<Lactation, int>((
  ref,
  id,
) async {
  final api = ref.read(lactationApiProvider);
  final dto = await api.getById(id);
  return lactationFromDto(dto);
});

final lactationsByCattleProvider = FutureProvider.family<List<Lactation>, int>((
  ref,
  cattleId,
) async {
  final api = ref.read(lactationApiProvider);
  final page = await api.getByCattle(cattleId: cattleId, page: 0, size: 50);
  return page.content.map(lactationFromDto).toList();
});

final createLactationProvider =
    Provider<Future<Lactation> Function(CreateLactationDto dto)>((ref) {
      return (dto) async {
        final api = ref.read(lactationApiProvider);
        final created = await api.create(dto);
        final entity = lactationFromDto(created);

        // обновляем списки, где эта корова
        ref.invalidate(lactationsByCattleProvider(entity.cattleId));
        return entity;
      };
    });

final lactationDailySummaryProvider =
    FutureProvider.autoDispose<LactationDailySummaryDto>((ref) async {
      final api = ref.read(lactationApiProvider);
      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      return api.getDailySummary(date: today);
    });

final createBulkLactationProvider =
    Provider<Future<BulkLactationDto> Function(CreateBulkLactationDto dto)>((
      ref,
    ) {
      return (dto) async {
        final api = ref.read(lactationApiProvider);
        final created = await api.createBulk(dto);

        // Обновим сводку на странице "Лактация"
        ref.invalidate(lactationDailySummaryProvider);

        return created;
      };
    });

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

      // берем побольше size, чтобы хватило для сумм по периоду
      final page = await api.getBulk(
        page: 0,
        size: 200,
        dateFrom: fmt.format(range.from),
        dateTo: fmt.format(range.to),
      );

      return page.content;
    });

class LactationBulkSummary {
  final int cowsTotal;
  final double totalMilkLiters;
  final double milkUsedForCalves;
  final double unsuitableMilk;

  const LactationBulkSummary({
    required this.cowsTotal,
    required this.totalMilkLiters,
    required this.milkUsedForCalves,
    required this.unsuitableMilk,
  });
}

final lactationBulkSummaryProvider = Provider.autoDispose<LactationBulkSummary>(
  (ref) {
    final listAsync = ref.watch(lactationBulkListProvider);

    return listAsync.maybeWhen(
      data: (list) {
        int cows = 0;
        double liters = 0;
        double calves = 0;
        double bad = 0;

        for (final x in list) {
          cows += (x.numberOfCows ?? 0);
          liters += (x.totalMilkLiters ?? 0);
          calves += (x.milkUsedForCalves ?? 0);
          bad += (x.unsuitableMilk ?? 0);
        }

        return LactationBulkSummary(
          cowsTotal: cows,
          totalMilkLiters: liters,
          milkUsedForCalves: calves,
          unsuitableMilk: bad,
        );
      },
      orElse: () => const LactationBulkSummary(
        cowsTotal: 0,
        totalMilkLiters: 0,
        milkUsedForCalves: 0,
        unsuitableMilk: 0,
      ),
    );
  },
);
