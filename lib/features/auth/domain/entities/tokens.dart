class Tokens {
  final String accessToken;
  final String refreshToken;
  final String tokenType; // обычно "Bearer"
  final int expiresIn;    // в секундах

  const Tokens({
    required this.accessToken,
    required this.refreshToken,
    required this.tokenType,
    required this.expiresIn,
  });
}
