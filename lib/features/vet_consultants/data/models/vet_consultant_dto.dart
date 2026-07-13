/// Ветврач-консультант, доступный клиенту для связи через WhatsApp.
///
/// `GET /api/vet-consultants` уже отдаёт только доступных (`available = true`),
/// поэтому фильтровать на клиенте не нужно.
class VetConsultantDto {
  final int id;
  final String fullName;
  final String specialization;
  final String whatsappNumber;
  final String? photoUrl;
  final String? description;

  /// Стоимость консультации. Может отсутствовать (бесплатно / не указана).
  final double? consultationPrice;
  final bool available;

  const VetConsultantDto({
    required this.id,
    required this.fullName,
    required this.specialization,
    required this.whatsappNumber,
    this.photoUrl,
    this.description,
    this.consultationPrice,
    this.available = true,
  });

  /// Номер, пригодный для WhatsApp deep link: только цифры.
  String get whatsappDigits => whatsappNumber.replaceAll(RegExp(r'[^0-9]'), '');

  factory VetConsultantDto.fromJson(Map<String, dynamic> json) {
    return VetConsultantDto(
      id: (json['id'] as num).toInt(),
      fullName: (json['fullName'] ?? '').toString(),
      specialization: (json['specialization'] ?? '').toString(),
      whatsappNumber: (json['whatsappNumber'] ?? '').toString(),
      photoUrl: (json['photoUrl'] as String?)?.trim(),
      description: (json['description'] as String?)?.trim(),
      consultationPrice: (json['consultationPrice'] as num?)?.toDouble(),
      available: (json['available'] as bool?) ?? true,
    );
  }
}
