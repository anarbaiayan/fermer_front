import 'package:frontend/features/cattle_events/data/datasources/cattle_events_api.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

List<String> _stripSystem(List<String> types) =>
    types.where((t) => !t.startsWith('SYSTEM_')).toList();

final bulkAvailableEventTypesProvider = FutureProvider.autoDispose
    .family<List<String>, String>((ref, key) async {
      if (key.trim().isEmpty) return const [];

      final ids = key
          .split(',')
          .where((s) => s.trim().isNotEmpty)
          .map(int.parse)
          .toList();

      if (ids.isEmpty) return const [];

      // Берем API напрямую, БЕЗ ref.watch других providers
      final api = ref.read(cattleEventsApiProvider);

      final lists = await Future.wait(
        ids.map((id) => api.getAvailableTypes(cattleId: id)),
      );

      // intersection
      Set<String>? acc;
      for (final raw in lists) {
        final set = _stripSystem(raw).toSet();
        acc = (acc == null) ? set : acc.intersection(set);
        if (acc.isEmpty) break;
      }

      final result = (acc ?? <String>{}).toList()..sort();
      return result;
    });
