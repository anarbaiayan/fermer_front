import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:frontend/features/auth/application/auth_providers.dart';
import 'package:frontend/features/cattle_events/data/datasources/cattle_events_api.dart';
import '../data/models/planned_event_dto.dart';
import '../domain/entities/planned_event.dart';

final _ymd = DateFormat('yyyy-MM-dd');

DateTime _parseYmdSafe(String? s) {
  if (s == null) return DateTime.fromMillisecondsSinceEpoch(0);
  try {
    return _ymd.parseStrict(s);
  } catch (_) {
    return DateTime.fromMillisecondsSinceEpoch(0);
  }
}

PlannedEvent plannedEventFromDto(PlannedEventDto d) {
  final ci = d.cattleInfo;

  final cattleId = d.cattleId ?? ci?.cattleId ?? 0;
  final cattleName = d.cattleName ?? ci?.cattleName ?? '-';
  final cattleTag = d.cattleTagNumber ?? ci?.cattleTagNumber ?? '-';

  return PlannedEvent(
    id: d.id ?? 0,
    cattleId: cattleId,
    cattleName: cattleName,
    cattleTagNumber: cattleTag,
    cattleCategory: ci?.category,
    daysUntil: d.daysUntil ?? 0,
    eventType: d.eventType ?? 'OTHER',
    plannedDate: _parseYmdSafe(d.plannedDate),
    priority: d.priority ?? 0,
    title: d.title ?? '',
  );
}

final plannedEventsProvider = FutureProvider.autoDispose
    .family<List<PlannedEvent>, String>((ref, status) async {
      // КЛЮЧЕВО: привязываем кеш к текущему токену
      ref.watch(authControllerProvider.select((s) => s.tokens?.accessToken));

      final api = ref.read(plannedEventsApiProvider);

      final page = await api.getPlannedEvents(
        status: status,
        page: 0,
        size: 200,
        sort: const ['plannedDate,asc'],
      );

      final list = page.content.map(plannedEventFromDto).toList();

      list.sort((a, b) {
        final d = a.daysUntil.compareTo(b.daysUntil);
        if (d != 0) return d;

        final p = b.priority.compareTo(a.priority);
        if (p != 0) return p;

        return a.plannedDate.compareTo(b.plannedDate);
      });

      return list;
    });
