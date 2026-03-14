import '../../domain/entities/app_notification.dart';
import 'notification_dto.dart';

class NotificationsPageDto {
  final List<NotificationDto> content;
  final int number;
  final int size;
  final int totalPages;
  final int totalElements;
  final bool last;

  const NotificationsPageDto({
    required this.content,
    required this.number,
    required this.size,
    required this.totalPages,
    required this.totalElements,
    required this.last,
  });

  factory NotificationsPageDto.fromJson(Map<String, dynamic> json) {
    final rawContent = (json['content'] as List?) ?? const [];
    return NotificationsPageDto(
      content: rawContent
          .whereType<Map<String, dynamic>>()
          .map(NotificationDto.fromJson)
          .toList(),
      number: (json['number'] as num?)?.toInt() ?? 0,
      size: (json['size'] as num?)?.toInt() ?? rawContent.length,
      totalPages: (json['totalPages'] as num?)?.toInt() ?? 0,
      totalElements: (json['totalElements'] as num?)?.toInt() ?? rawContent.length,
      last: (json['last'] as bool?) ?? true,
    );
  }

  List<AppNotification> toEntities() => content.map((e) => e.toEntity()).toList();
}
