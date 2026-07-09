/// Плоский элемент каталога (`GET /api/pharmacy/drugs`).
///
/// Используется, когда включён фильтр по производителю (`companyId`), который
/// `GET /api/pharmacy/catalog` не поддерживает. Затем группируется на клиенте
/// в [DrugGroupDto] по тому же правилу, что и на бэке.
class VetDrugDto {
  final int id;
  final String name;
  final String? activeIngredient;
  final String? packaging;
  final double? price;
  final String? imageUrl;

  final int? actionId;
  final String? actionName;

  final int? companyId;
  final String companyName;

  const VetDrugDto({
    required this.id,
    required this.name,
    this.activeIngredient,
    this.packaging,
    this.price,
    this.imageUrl,
    this.actionId,
    this.actionName,
    this.companyId,
    required this.companyName,
  });

  factory VetDrugDto.fromJson(Map<String, dynamic> json) {
    return VetDrugDto(
      id: (json['id'] as num).toInt(),
      name: (json['name'] ?? '').toString(),
      activeIngredient: (json['activeIngredient'] as String?)?.trim(),
      packaging: (json['packaging'] as String?)?.trim(),
      price: (json['price'] as num?)?.toDouble(),
      imageUrl: (json['imageUrl'] as String?)?.trim(),
      actionId: (json['actionId'] as num?)?.toInt(),
      actionName: (json['actionName'] as String?)?.trim(),
      companyId: (json['companyId'] as num?)?.toInt(),
      companyName: (json['companyName'] ?? '').toString(),
    );
  }
}
