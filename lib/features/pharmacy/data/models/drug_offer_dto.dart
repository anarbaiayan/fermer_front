/// Предложение конкретного производителя на препарат (для сравнения цен внутри группы).
///
/// Каждое предложение — это отдельный препарат в БД (`drugId`), поэтому именно
/// `drugId` уходит в заявку `POST /api/pharmacy/requests`.
class DrugOfferDto {
  final int drugId;
  final int? companyId;
  final String companyName;

  /// Торговое название (напр. «Бутофан 100 мл»).
  final String name;
  final String? packaging;

  /// Цена за единицу. Может быть null, если в каталоге цена не указана.
  final double? price;
  final String? imageUrl;

  const DrugOfferDto({
    required this.drugId,
    this.companyId,
    required this.companyName,
    required this.name,
    this.packaging,
    this.price,
    this.imageUrl,
  });

  factory DrugOfferDto.fromJson(Map<String, dynamic> json) {
    return DrugOfferDto(
      drugId: (json['drugId'] as num).toInt(),
      companyId: (json['companyId'] as num?)?.toInt(),
      companyName: (json['companyName'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      packaging: (json['packaging'] as String?)?.trim(),
      price: (json['price'] as num?)?.toDouble(),
      imageUrl: (json['imageUrl'] as String?)?.trim(),
    );
  }
}
