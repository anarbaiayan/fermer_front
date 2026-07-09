/// Компания-производитель ветпрепаратов.
///
/// Backend не отдаёт казахских версий названия/описания — показываем как есть.
class PharmacyCompanyDto {
  final int id;
  final String name;
  final String? description;

  const PharmacyCompanyDto({
    required this.id,
    required this.name,
    this.description,
  });

  factory PharmacyCompanyDto.fromJson(Map<String, dynamic> json) {
    return PharmacyCompanyDto(
      id: (json['id'] as num).toInt(),
      name: (json['name'] ?? '').toString(),
      description: (json['description'] as String?)?.trim(),
    );
  }
}
