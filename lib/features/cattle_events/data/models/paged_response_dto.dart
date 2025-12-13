class PagedResponseDto<T> {
  final int? totalElements;
  final int? totalPages;
  final int? size;
  final int? number;
  final List<T> content;

  const PagedResponseDto({
    required this.content,
    this.totalElements,
    this.totalPages,
    this.size,
    this.number,
  });

  factory PagedResponseDto.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    final rawContent = (json['content'] as List?) ?? const [];
    return PagedResponseDto<T>(
      totalElements: (json['totalElements'] as num?)?.toInt(),
      totalPages: (json['totalPages'] as num?)?.toInt(),
      size: (json['size'] as num?)?.toInt(),
      number: (json['number'] as num?)?.toInt(),
      content: rawContent
          .map((e) => fromJsonT(e as Map<String, dynamic>))
          .toList(),
    );
  }
}
