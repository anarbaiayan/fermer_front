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
    final raw = json['content'];
    if (raw is! List) throw const FormatException('Missing page content');
    int pageNumber(String key) {
      final value = json[key];
      if (value is! num ||
          !value.isFinite ||
          value < 0 ||
          value != value.toInt()) {
        throw FormatException('Invalid pagination field: $key');
      }
      return value.toInt();
    }

    return PagedResponseDto(
      content: raw.map((item) {
        if (item is! Map<String, dynamic>) {
          throw const FormatException('Invalid page item');
        }
        return fromJsonT(item);
      }).toList(),
      number: pageNumber('number'),
      size: pageNumber('size'),
      totalPages: pageNumber('totalPages'),
      totalElements: pageNumber('totalElements'),
    );
  }
}
