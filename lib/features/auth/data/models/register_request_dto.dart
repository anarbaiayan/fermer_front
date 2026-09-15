class RegisterRequestDto {
  final String phoneNumber;
  final String password;
  final String firstName;
  final String lastName;
  final String farmName;
  final String city;
  final String region;

  const RegisterRequestDto({
    required this.phoneNumber,
    required this.password,
    required this.firstName,
    required this.lastName,
    required this.farmName,
    required this.city,
    required this.region,
  });

  Map<String, dynamic> toJson() => {
    'phoneNumber': phoneNumber,
    'password': password,
    'firstName': firstName,
    'lastName': lastName,
    'farmName': farmName,
    'city': city,
    'region': region,
  };
}
