import 'ration_catalog_item_dto.dart';

class UserRationDto {
  final int id;
  final RationCatalogItemDto ration;
  final double quantityKg;
  final bool isAvailable;
  final double totalCost;

  UserRationDto({
    required this.id,
    required this.ration,
    required this.quantityKg,
    required this.isAvailable,
    required this.totalCost,
  });

  factory UserRationDto.fromJson(Map<String, dynamic> json) {
    return UserRationDto(
      id: (json['id'] as num).toInt(),
      ration: RationCatalogItemDto.fromJson(
        json['ration'] as Map<String, dynamic>,
      ),
      quantityKg: (json['quantityKg'] as num?)?.toDouble() ?? 0,
      isAvailable: (json['isAvailable'] as bool?) ?? true,
      totalCost: (json['totalCost'] as num?)?.toDouble() ?? 0,
    );
  }
}
