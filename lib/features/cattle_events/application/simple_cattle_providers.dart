import 'package:frontend/features/cattle_events/domain/entities/simple_cattle.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:frontend/features/herd/data/datasources/herd_api.dart';

final simpleCattleByCategoryProvider =
    FutureProvider.autoDispose.family<List<SimpleCattle>, String>((ref, category) async {
  final api = ref.read(herdApiProvider);
  final raw = await api.getCattleSimpleByCategory(category: category);
  return raw.map(SimpleCattle.fromJson).toList();
});
