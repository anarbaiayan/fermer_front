class RestoreAccountRequestDto {
  final String phoneNumber;
  final String password;

  const RestoreAccountRequestDto({
    required this.phoneNumber,
    required this.password,
  });

  Map<String, dynamic> toJson() => {
    'phoneNumber': phoneNumber,
    'password': password,
  };
}
