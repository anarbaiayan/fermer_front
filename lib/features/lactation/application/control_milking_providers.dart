import 'package:dio/dio.dart';
import 'package:frontend/features/herd/application/herd_providers.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import '../data/datasources/lactation_api.dart';
import '../data/datasources/milking_candidates_api.dart';
import '../data/models/create_lactation_dto.dart';
import '../data/models/milking_candidate_dto.dart';
import '../domain/entities/control_milking.dart';
import '../domain/entities/milking_candidate.dart';
import '../domain/entities/milking_time.dart';
import 'lactation_providers.dart';

final _apiDate = DateFormat('yyyy-MM-dd');
final _apiDateTime = DateFormat("yyyy-MM-dd'T'HH:mm:ss");

/// Сколько записей отправляем параллельно. Бэкенд не умеет создавать замеры
/// пачкой, поэтому шлём по одной, но не открываем 100 соединений сразу.
const _saveConcurrency = 4;

/// Все коровы пользователя — источник списка на шаге 1.
///
/// Грузится одним запросом на весь датасет: поиск и фильтры должны работать по
/// всему стаду, а не по подгруженной странице.
final milkingCandidatesProvider =
    FutureProvider.autoDispose<List<MilkingCandidate>>((ref) async {
      final api = ref.read(milkingCandidatesApiProvider);
      final cancelToken = CancelToken();
      ref.onDispose(cancelToken.cancel);
      final dtos = await api.getCows(cancelToken: cancelToken);
      return dtos.map(milkingCandidateFromDto).toList();
    });

typedef FindControlMilkingDuplicates =
    Future<Set<int>> Function({
      required DateTime date,
      required MilkingTime milkingTime,
      required Set<int> cattleIds,
    });

/// Ищет коров, у которых на эту дату и время доения уже есть индивидуальный
/// замер.
///
/// Одна сводка за дату содержит утренние и вечерние литры по всем коровам
/// пользователя, поэтому дубликаты находим одним запросом, а не запросом на
/// каждое животное.
final findControlMilkingDuplicatesProvider =
    Provider<FindControlMilkingDuplicates>((ref) {
      return ({required date, required milkingTime, required cattleIds}) async {
        if (cattleIds.isEmpty) return {};

        final api = ref.read(lactationApiProvider);
        final summary = await api.getDailySummary(date: _apiDate.format(date));

        return {
          for (final detail in summary.details)
            if (cattleIds.contains(detail.cattleId) &&
                (milkingTime == MilkingTime.morning
                    ? detail.morningLiters != null
                    : detail.eveningLiters != null))
              detail.cattleId,
        };
      };
    });

class ControlMilkingDraftNotifier extends StateNotifier<ControlMilkingDraft> {
  ControlMilkingDraftNotifier() : super(ControlMilkingDraft.initial());

  /// Новый замер: вызывается при входе в сценарий из bottom sheet.
  void startNew() => state = ControlMilkingDraft.initial();

  void setDate(DateTime date) {
    state = state.copyWith(date: DateTime(date.year, date.month, date.day));
  }

  void setMilkingTime(MilkingTime time) =>
      state = state.copyWith(milkingTime: time);

  void select(int cattleId) {
    if (state.selectedIds.contains(cattleId)) return;
    state = state.copyWith(selectedIds: {...state.selectedIds, cattleId});
  }

  /// Снятие выбора убирает и введённое значение: корова больше не участвует
  /// в замере, хранить её литры незачем.
  void unselect(int cattleId) {
    if (!state.selectedIds.contains(cattleId)) return;
    state = state.copyWith(
      selectedIds: {...state.selectedIds}..remove(cattleId),
      values: {...state.values}..remove(cattleId),
    );
  }

  void selectAll(Iterable<int> cattleIds) {
    state = state.copyWith(selectedIds: {...state.selectedIds, ...cattleIds});
  }

  void unselectAll(Iterable<int> cattleIds) {
    final ids = cattleIds.toSet();
    if (ids.isEmpty) return;
    state = state.copyWith(
      selectedIds: {...state.selectedIds}..removeAll(ids),
      values: {...state.values}..removeWhere((key, _) => ids.contains(key)),
    );
  }

  /// Перенос введённых литров со второго шага в черновик.
  void setValues(Map<int, String> values) {
    final cleaned = <int, String>{};
    for (final entry in values.entries) {
      final text = entry.value.trim();
      // Пустую строку не храним: "не заполнено" — это отсутствие ключа.
      if (text.isEmpty || !state.selectedIds.contains(entry.key)) continue;
      cleaned[entry.key] = text;
    }
    state = state.copyWith(values: cleaned);
  }
}

final controlMilkingDraftProvider =
    StateNotifierProvider<ControlMilkingDraftNotifier, ControlMilkingDraft>(
      (ref) => ControlMilkingDraftNotifier(),
    );

typedef SaveControlMilking =
    Future<ControlMilkingSaveResult> Function({
      required DateTime date,
      required MilkingTime milkingTime,
      required List<ControlMilkingEntry> entries,
      required Set<int> duplicateCattleIds,
      required ControlMilkingDuplicateAction duplicateAction,
    });

/// Сохраняет контрольный надой: создаёт новые записи и, если пользователь
/// подтвердил перезапись, обновляет существующие.
final saveControlMilkingProvider = Provider<SaveControlMilking>((ref) {
  return ({
    required date,
    required milkingTime,
    required entries,
    required duplicateCattleIds,
    required duplicateAction,
  }) async {
    final api = ref.read(lactationApiProvider);
    final dateText = _apiDate.format(date);
    final timeText = _apiDateTime.format(
      _defaultDateTimeFor(date, milkingTime),
    );

    final pending = <ControlMilkingEntry>[];
    final keptExisting = <int>[];
    for (final entry in entries) {
      final isDuplicate = duplicateCattleIds.contains(entry.cattleId);
      if (isDuplicate &&
          duplicateAction == ControlMilkingDuplicateAction.keepExisting) {
        keptExisting.add(entry.cattleId);
        continue;
      }
      pending.add(entry);
    }

    final failures = <int, Object>{};
    final savedIds = <int>[];
    var savedLiters = 0.0;

    Future<void> submit(ControlMilkingEntry entry) async {
      try {
        if (duplicateCattleIds.contains(entry.cattleId)) {
          final existing = await api.findByCattleDateAndTime(
            cattleId: entry.cattleId,
            milkingDate: dateText,
            milkingTime: milkingTime.apiValue,
          );
          final existingId = existing?.id;
          if (existingId != null) {
            await api.update(
              id: existingId,
              body: {
                'milkingDate': dateText,
                'milkingDateTime': timeText,
                'milkingTime': milkingTime.apiValue,
                'milkLiters': entry.liters,
              },
            );
            savedIds.add(entry.cattleId);
            savedLiters += entry.liters;
            return;
          }
        }

        await api.create(
          CreateLactationDto(
            cattleId: entry.cattleId,
            milkingDate: dateText,
            milkingDateTime: timeText,
            milkingTime: milkingTime.apiValue,
            milkLiters: entry.liters,
          ),
        );
        savedIds.add(entry.cattleId);
        savedLiters += entry.liters;
      } catch (error) {
        failures[entry.cattleId] = error;
      }
    }

    for (var offset = 0; offset < pending.length; offset += _saveConcurrency) {
      await Future.wait(
        pending.skip(offset).take(_saveConcurrency).map(submit),
      );
    }

    if (savedIds.isNotEmpty) {
      _invalidateAfterSave(ref, savedIds: savedIds);
    }

    return ControlMilkingSaveResult(
      date: date,
      milkingTime: milkingTime,
      savedCount: savedIds.length,
      keptExistingCount: keptExisting.length,
      savedLiters: savedLiters,
      processedCattleIds: {...savedIds, ...keptExisting},
      failures: failures,
    );
  };
});

/// Время доения — только два значения (MORNING/EVENING), как на бэкенде.
/// Для отчёта достаточно часа по умолчанию: пользователь вносит замер списком,
/// поминутное время каждой коровы здесь смысла не имеет.
DateTime _defaultDateTimeFor(DateTime date, MilkingTime time) {
  final hour = time == MilkingTime.evening ? 18 : 6;
  return DateTime(date.year, date.month, date.day, hour, 30);
}

void _invalidateAfterSave(Ref ref, {required List<int> savedIds}) {
  final providers = <ProviderBase<Object?>>[
    // История и аналитика в карточке каждой затронутой коровы.
    for (final id in savedIds) ...[
      lactationsByCattleProvider(id),
      cattleDetailsProvider(id),
      cattleByIdProvider(id),
    ],
    // Первый замер переводит корову в LACTATING — список и статистика стада
    // должны это увидеть.
    cattleListProvider,
    cattleStatisticsProvider,
    milkingCandidatesProvider,
  ];

  // Не поднимаем чужие экраны только ради сброса их кеша.
  for (final provider in providers) {
    if (ref.exists(provider)) ref.invalidate(provider);
  }
}
