/// Действие препарата (используется для фильтра-чипов в каталоге).
///
/// Backend отдаёт русское `name` всегда и `nameKk` — не для всех записей,
/// поэтому в казахской локали берём `nameKk`, иначе fallback на `name`.
class DrugActionDto {
  final int id;
  final String name;
  final String? nameKk;

  const DrugActionDto({required this.id, required this.name, this.nameKk});

  String localizedName(String languageCode) {
    if (languageCode == 'kk' && (nameKk ?? '').trim().isNotEmpty) {
      return nameKk!.trim();
    }
    return name;
  }

  factory DrugActionDto.fromJson(Map<String, dynamic> json) {
    return DrugActionDto(
      id: (json['id'] as num).toInt(),
      name: (json['name'] ?? '').toString(),
      nameKk: (json['nameKk'] as String?)?.trim(),
    );
  }
}
