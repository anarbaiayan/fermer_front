import '../../domain/entities/vet_request_status.dart';

/// Заявка на препарат из `GET /api/pharmacy/requests` (ответ на create — та же форма).
class VetDrugRequestDto {
  final int id;
  final int? drugId;
  final String drugName;
  final String? companyName;
  final int quantity;
  final String? comment;
  final String? contactPhone;
  final VetRequestStatus status;
  final DateTime? createdAt;

  const VetDrugRequestDto({
    required this.id,
    this.drugId,
    required this.drugName,
    this.companyName,
    required this.quantity,
    this.comment,
    this.contactPhone,
    required this.status,
    this.createdAt,
  });

  factory VetDrugRequestDto.fromJson(Map<String, dynamic> json) {
    return VetDrugRequestDto(
      id: (json['id'] as num).toInt(),
      drugId: (json['drugId'] as num?)?.toInt(),
      drugName: (json['drugName'] ?? '').toString(),
      companyName: (json['companyName'] as String?)?.trim(),
      quantity: (json['quantity'] as num?)?.toInt() ?? 0,
      comment: (json['comment'] as String?)?.trim(),
      contactPhone: (json['contactPhone'] as String?)?.trim(),
      status: VetRequestStatus.fromRaw(json['status']?.toString()),
      createdAt: DateTime.tryParse((json['createdAt'] ?? '').toString()),
    );
  }
}
