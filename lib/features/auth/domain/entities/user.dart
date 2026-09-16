class User {
  final int id;
  final String phoneNumber;
  final String? email;
  final String firstName;
  final String lastName;
  final String farmName;
  final String? city;
  final String? region;
  final List<String> roles;
  final bool phoneVerified;

  const User({
    required this.id,
    required this.phoneNumber,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.farmName,
    required this.city,
    required this.region,
    required this.roles,
    required this.phoneVerified,
  });

  String get fullName => '$firstName $lastName';
}
