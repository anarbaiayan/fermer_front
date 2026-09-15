class UserProfileUpdateRequestDto {
  final String farmName;

  const UserProfileUpdateRequestDto({required this.farmName});

  Map<String, dynamic> toJson() => {'farmName': farmName};
}
