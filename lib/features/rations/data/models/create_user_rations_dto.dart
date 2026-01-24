class CreateUserRationsDto {
  /// key = rationId, value = quantityKg
  final Map<int, double> rationQuantity;
  final bool isAvailable;

  CreateUserRationsDto({required this.rationQuantity, this.isAvailable = true});

  Map<String, dynamic> toJson() {
    return {
      'rationQuantity': rationQuantity.map((k, v) => MapEntry(k.toString(), v)),
      'isAvailable': isAvailable,
    };
  }
}
