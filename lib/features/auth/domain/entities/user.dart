class User {
  final int id;
  final String phoneNumber;
  final String? email;
  final String firstName;
  final String lastName;
  final List<String> roles;
  final bool phoneVerified;

  const User({
    required this.id,
    required this.phoneNumber,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.roles,
    required this.phoneVerified,
  });

  String get fullName => '$firstName $lastName';
}
