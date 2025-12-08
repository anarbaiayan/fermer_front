import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:frontend/features/herd/data/datasources/herd_api.dart';
import 'package:frontend/features/herd/data/models/cattle_mappers.dart';
import 'package:frontend/features/herd/domain/entities/cattle.dart';

/// Загружает список животных с бэка
final cattleListProvider = FutureProvider.autoDispose<List<Cattle>>((ref) async {
  final api = ref.read(herdApiProvider);

  final dtos = await api.getCattleList(
    page: 0,
    size: 50,
    sortBy: 'createdAt',
    sortDirection: 'DESC',
  );

  return dtos.map(cattleFromDto).toList();
});

final cattleByIdProvider =
    FutureProvider.autoDispose.family<Cattle, int>((ref, id) async {
  debugPrint('cattleByIdProvider called with id=$id'); // ← лог
  final api = ref.read(herdApiProvider);
  final dto = await api.getCattleById(id);
  return cattleFromDto(dto);
});
