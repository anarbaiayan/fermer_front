// bulk_event_providers.dart
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'cattle_events_providers.dart';

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

      // Параллельно забираем через КЕШИРУЕМЫЙ provider, а не через api
      final lists = await Future.wait(
        ids.map(
          (id) => ref.watch(cattleAvailableEventTypesProvider(id).future),
        ),
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
