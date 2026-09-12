import 'package:dio/dio.dart';
import 'package:frontend/core/network/network_providers.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../domain/entities/lactation_validation.dart';
import '../models/milking_candidate_dto.dart';
import '../models/paged_response_dto.dart';

final milkingCandidatesApiProvider = Provider<MilkingCandidatesApi>((ref) {
  final client = ref.read(dioClientProvider);
  return MilkingCandidatesApi(client.dio);
});

/// Читает список коров для шага "Выбор коров" контрольного надоя.
///
/// Живёт в фиче лактации, а не в herd: это отдельный потребитель того же
/// эндпоинта со своей облегчённой моделью.
class MilkingCandidatesApi {
  static const _pageSize = 200;

  final Dio _dio;

  MilkingCandidatesApi(this._dio);

  Future<List<MilkingCandidateDto>> getCows({CancelToken? cancelToken}) async {
    final result = <MilkingCandidateDto>[];
    final ids = <int>{};
    int? total;

    for (var number = 0; ; number++) {
      if (cancelToken?.isCancelled ?? false) throw cancelToken!.cancelError!;

      final response = await _dio.get(
        '/cattle/category/COW',
        cancelToken: cancelToken,
        queryParameters: {'page': number, 'size': _pageSize},
      );

      final page = PagedResponseDto.fromJson(
        response.data as Map<String, dynamic>,
        MilkingCandidateDto.fromJson,
      );

      total ??= page.totalElements;
      // Список меняется между страницами (создали/удалили животное) — лучше
      // показать ошибку с "Повторить", чем молча потерять часть стада.
      if (page.number != number || page.totalElements != total) {
        throw LactationValidationError.incompleteData;
      }

      for (final item in page.content) {
        if (!ids.add(item.id)) throw LactationValidationError.incompleteData;
        result.add(item);
      }

      if (number + 1 >= page.totalPages) {
        if (result.length != total) {
          throw LactationValidationError.incompleteData;
        }
        return result;
      }
      if (page.content.isEmpty) throw LactationValidationError.incompleteData;
    }
  }
}
