import '../../domain/entities/milking_candidate.dart';

/// Разбор элемента `GET /cattle/category/COW`.
///
/// Список коров для контрольного надоя берём именно из этого эндпоинта, потому
/// что он отдаёт `productionState` / `isLactating` / `animalGroup` прямо в
/// элементе страницы — без запроса деталей на каждое животное.
class MilkingCandidateDto {
  final int id;
  final String tagNumber;
  final String name;
  final bool isLactating;
  final String? animalGroup;

  const MilkingCandidateDto({
    required this.id,
    required this.tagNumber,
    required this.name,
    required this.isLactating,
    required this.animalGroup,
  });

  factory MilkingCandidateDto.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    if (id is! num || !id.isFinite || id != id.toInt()) {
      throw const FormatException('Invalid cattle id');
    }

    final group = (json['animalGroup'] as String?)?.trim();

    return MilkingCandidateDto(
      id: id.toInt(),
      tagNumber: (json['tagNumber'] as String?)?.trim() ?? '',
      name: (json['name'] as String?)?.trim() ?? '',
      // Бэкенд отдаёт оба поля; productionState — источник истины для фильтра
      // "Дойные", isLactating оставляем запасным вариантом.
      isLactating:
          json['productionState'] == 'LACTATING' || json['isLactating'] == true,
      animalGroup: (group == null || group.isEmpty) ? null : group,
    );
  }
}

MilkingCandidate milkingCandidateFromDto(MilkingCandidateDto dto) {
  return MilkingCandidate(
    id: dto.id,
    tagNumber: dto.tagNumber,
    name: dto.name,
    isLactating: dto.isLactating,
    animalGroup: dto.animalGroup,
  );
}
