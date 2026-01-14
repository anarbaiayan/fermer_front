import 'package:frontend/features/cattle_events/application/planned_events_providers.dart';
import 'package:frontend/features/cattle_events/data/models/create_bulk_event_dto.dart';
import 'package:frontend/features/herd/application/herd_providers.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

import '../data/datasources/cattle_events_api.dart';
import '../data/models/cattle_event_dto.dart';
import '../data/models/create_cattle_event_dto.dart';
import '../domain/entities/cattle_event.dart';

final _dateFmt = DateFormat('yyyy-MM-dd');

DateTime _parseYmdSafe(String s) {
  try {
    return _dateFmt.parseStrict(s);
  } catch (_) {
    return DateTime.fromMillisecondsSinceEpoch(0);
  }
}

DateTime? _tryParseDateTime(String? raw) {
  if (raw == null) return null;
  return DateTime.tryParse(raw);
}

CattleEvent _toEntity(CattleEventDto d) {
  return CattleEvent(
    id: d.id ?? 0,
    cattleId: d.cattleId ?? 0,
    eventType: d.eventType,
    eventDate: _parseYmdSafe(d.eventDate),
    title: d.title,
    description: d.description,
    notes: d.notes,
    createdAt: _tryParseDateTime(d.createdAt),
  );
}

/// Превью событий для карточки (3 последних)
final cattleEventsPreviewProvider =
    FutureProvider.family<List<CattleEvent>, int>((ref, cattleId) async {
      final api = ref.read(cattleEventsApiProvider);
      final page = await api.getEvents(
        cattleId: cattleId,
        page: 0,
        size: 200,
        sort: const ['eventDate,desc'],
      );
      return page.content.map(_toEntity).toList();
    });

/// Полный список (для будущей страницы журнала)
final cattleEventsListProvider = FutureProvider.family<List<CattleEvent>, int>((
  ref,
  cattleId,
) async {
  final api = ref.read(cattleEventsApiProvider);
  final page = await api.getEvents(
    cattleId: cattleId,
    page: 0,
    size: 50,
    sort: const ['eventDate,desc'],
  );
  return page.content.map(_toEntity).toList();
});

final cattleAvailableEventTypesProvider =
    FutureProvider.family<List<String>, int>((ref, cattleId) async {
      final api = ref.read(cattleEventsApiProvider);
      return api.getAvailableTypes(cattleId: cattleId);
    });

final createCattleEventProvider =
    Provider<Future<void> Function(int cattleId, CreateCattleEventDto dto)>((
      ref,
    ) {
      return (cattleId, dto) async {
        final api = ref.read(cattleEventsApiProvider);
        await api.createEvent(cattleId: cattleId, body: dto);

        ref.invalidate(cattleEventsPreviewProvider(cattleId));
        ref.invalidate(cattleEventsListProvider(cattleId));
        ref.invalidate(cattleAvailableEventTypesProvider(cattleId));
        ref.invalidate(cattleDetailsProvider(cattleId));
        ref.invalidate(cattleByIdProvider(cattleId));
      };
    });

final deleteCattleEventProvider =
    Provider<Future<void> Function(int cattleId, int eventId)>((ref) {
      return (cattleId, eventId) async {
        final api = ref.read(cattleEventsApiProvider);
        await api.deleteEvent(cattleId: cattleId, eventId: eventId);

        ref.invalidate(cattleEventsPreviewProvider(cattleId));
        ref.invalidate(cattleEventsListProvider(cattleId));
        ref.invalidate(cattleAvailableEventTypesProvider(cattleId));
      };
    });

final completeCattleEventProvider =
    Provider<Future<void> Function(int cattleId, int eventId)>((ref) {
      return (cattleId, eventId) async {
        final api = ref.read(cattleEventsApiProvider);
        await api.completeEvent(eventId: eventId);

        // обновим planned список
        ref.invalidate(plannedEventsProvider('PENDING'));
        ref.invalidate(plannedEventsProvider('COMPLETED'));

        // опционально - обновить журналы конкретной коровы
        ref.invalidate(cattleEventsPreviewProvider(cattleId));
        ref.invalidate(cattleEventsListProvider(cattleId));
      };
    });

final deletePlannedEventProvider =
    Provider<Future<void> Function(int cattleId, int eventId)>((ref) {
      return (cattleId, eventId) async {
        final api = ref.read(cattleEventsApiProvider);
        await api.deleteEvent(cattleId: cattleId, eventId: eventId);

        ref.invalidate(plannedEventsProvider('PENDING'));
        ref.invalidate(plannedEventsProvider('COMPLETED'));

        ref.invalidate(cattleEventsPreviewProvider(cattleId));
        ref.invalidate(cattleEventsListProvider(cattleId));
      };
    });

final createBulkCattleEventsProvider =
    Provider<Future<void> Function(CreateBulkEventDto dto)>((ref) {
      return (dto) async {
        final api = ref.read(cattleEventsApiProvider);
        await api.createBulkEvents(body: dto);

        // общий список задач
        ref.invalidate(plannedEventsProvider('PENDING'));
        ref.invalidate(plannedEventsProvider('COMPLETED'));

        // общий herd
        ref.invalidate(cattleStatisticsProvider);
        ref.invalidate(cattleListProvider);

        // КЛЮЧ: обновляем детали КАЖДОГО выбранного животного
        for (final id in dto.cattleIds) {
          ref.invalidate(cattleDetailsProvider(id));
          ref.invalidate(cattleByIdProvider(id));
          ref.invalidate(cattleEventsPreviewProvider(id));
          ref.invalidate(cattleEventsListProvider(id));
          // если у тебя есть upcomingEventsPreviewProvider - тоже invalidate
        }
      };
    });
