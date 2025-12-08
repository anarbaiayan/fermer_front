class LogoutRequestDto {
  final String refreshToken;

  const LogoutRequestDto({required this.refreshToken});

  Map<String, dynamic> toJson() => {
        'refreshToken': refreshToken,
      };
}
