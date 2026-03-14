import '../../domain/entities/app_notification.dart';
import '../../domain/entities/notification_status.dart';
import '../../domain/entities/notification_type.dart';

DateTime? _parseDate(String? raw) {
  if (raw == null || raw.trim().isEmpty) return null;
  return DateTime.tryParse(raw);
}

class NotificationCattleInfoDto {
  final int? cattleId;
  final String? cattleTagNumber;
  final String? cattleName;

  const NotificationCattleInfoDto({
    this.cattleId,
    this.cattleTagNumber,
    this.cattleName,
  });

  factory NotificationCattleInfoDto.fromJson(Map<String, dynamic> json) {
    return NotificationCattleInfoDto(
      cattleId: (json['cattleId'] as num?)?.toInt(),
      cattleTagNumber: (json['cattleTagNumber'] as String?)?.trim(),
      cattleName: (json['cattleName'] as String?)?.trim(),
    );
  }

  NotificationCattleInfo toEntity() {
    return NotificationCattleInfo(
      cattleId: cattleId,
      cattleTagNumber: cattleTagNumber,
      cattleName: cattleName,
    );
  }
}

class NotificationDto {
  final int id;
  final String typeRaw;
  final String statusRaw;
  final String title;
  final String message;
  final DateTime? notificationDate;
  final DateTime? readAt;
  final bool archived;
  final NotificationCattleInfoDto? cattleInfo;

  const NotificationDto({
    required this.id,
    required this.typeRaw,
    required this.statusRaw,
    required this.title,
    required this.message,
    required this.notificationDate,
    required this.readAt,
    required this.archived,
    required this.cattleInfo,
  });

  factory NotificationDto.fromJson(Map<String, dynamic> json) {
    return NotificationDto(
      id: (json['id'] as num?)?.toInt() ?? 0,
      typeRaw: (json['type'] ?? '').toString(),
      statusRaw: (json['status'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      message: (json['message'] ?? '').toString(),
      notificationDate: _parseDate(json['notificationDate'] as String?),
      readAt: _parseDate(json['readAt'] as String?),
      archived: (json['archived'] as bool?) ?? false,
      cattleInfo: json['cattleInfo'] is Map<String, dynamic>
          ? NotificationCattleInfoDto.fromJson(
              json['cattleInfo'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  AppNotification toEntity() {
    return AppNotification(
      id: id,
      type: NotificationTypeX.fromApi(typeRaw),
      status: NotificationStatusX.fromApi(statusRaw),
      rawType: typeRaw,
      rawStatus: statusRaw,
      title: title,
      message: message,
      notificationDate: notificationDate,
      readAt: readAt,
      archived: archived,
      cattleInfo: cattleInfo?.toEntity(),
    );
  }
}
