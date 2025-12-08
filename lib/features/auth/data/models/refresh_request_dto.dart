class RefreshRequestDto {
  final String refreshToken;

  const RefreshRequestDto({required this.refreshToken});

  Map<String, dynamic> toJson() => {
        'refreshToken': refreshToken,
      };
}
