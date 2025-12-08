class RegisterRequestDto {
  final String phoneNumber;
  final String password;
  final String firstName;
  final String lastName;
  final String farmName;

  const RegisterRequestDto({
    required this.phoneNumber,
    required this.password,
    required this.firstName,
    required this.lastName,
    required this.farmName,
  });

  Map<String, dynamic> toJson() => {
        'phoneNumber': phoneNumber,
        'password': password,
        'firstName': firstName,
        'lastName': lastName,
        'farmName': farmName,
      };
}
