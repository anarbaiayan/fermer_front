class PagedResponseDto<T> {
  final List<T> content;
  final int number;
  final int size;
  final int totalPages;
  final int totalElements;

  const PagedResponseDto({
    required this.content,
    required this.number,
    required this.size,
    required this.totalPages,
    required this.totalElements,
  });

  factory PagedResponseDto.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    final raw = (json['content'] as List?) ?? const [];
    return PagedResponseDto(
      content: raw.whereType<Map<String, dynamic>>().map(fromJsonT).toList(),
      number: (json['number'] as num?)?.toInt() ?? 0,
      size: (json['size'] as num?)?.toInt() ?? raw.length,
      totalPages: (json['totalPages'] as num?)?.toInt() ?? 0,
      totalElements: (json['totalElements'] as num?)?.toInt() ?? raw.length,
    );
  }
}
