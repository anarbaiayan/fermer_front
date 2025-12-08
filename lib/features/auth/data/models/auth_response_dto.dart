class AuthResponseDto {
  final String accessToken;
  final String refreshToken;
  final String tokenType;
  final int expiresIn;
  final UserDto user;

  const AuthResponseDto({
    required this.accessToken,
    required this.refreshToken,
    required this.tokenType,
    required this.expiresIn,
    required this.user,
  });

  factory AuthResponseDto.fromJson(Map<String, dynamic> json) {
    return AuthResponseDto(
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
      tokenType: json['tokenType'] as String,
      expiresIn: json['expiresIn'] as int,
      user: UserDto.fromJson(json['user'] as Map<String, dynamic>),
    );
  }
}

class UserDto {
  final int id;
  final String phoneNumber;
  final String? email;
  final String firstName;
  final String lastName;
  final List<String> roles;
  final bool phoneVerified;

  const UserDto({
    required this.id,
    required this.phoneNumber,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.roles,
    required this.phoneVerified,
  });

  factory UserDto.fromJson(Map<String, dynamic> json) {
    return UserDto(
      id: json['id'] as int,
      phoneNumber: json['phoneNumber'] as String,
      email: json['email'] as String?,              // может быть null
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      roles: (json['roles'] as List<dynamic>)
          .map((e) => e.toString())
          .toList(),
      phoneVerified: json['phoneVerified'] as bool,
    );
  }
}
