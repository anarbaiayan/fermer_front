import 'notification_status.dart';
import 'notification_type.dart';

class NotificationCattleInfo {
  final int? cattleId;
  final String? cattleTagNumber;
  final String? cattleName;

  const NotificationCattleInfo({
    this.cattleId,
    this.cattleTagNumber,
    this.cattleName,
  });
}

class AppNotification {
  final int id;
  final NotificationType type;
  final NotificationStatus status;
  final String rawType;
  final String rawStatus;
  final String title;
  final String message;
  final DateTime? notificationDate;
  final DateTime? readAt;
  final bool archived;
  final NotificationCattleInfo? cattleInfo;

  const AppNotification({
    required this.id,
    required this.type,
    required this.status,
    required this.rawType,
    required this.rawStatus,
    required this.title,
    required this.message,
    required this.notificationDate,
    required this.readAt,
    required this.archived,
    required this.cattleInfo,
  });

  bool get isUnread => readAt == null;

  AppNotification copyWith({
    int? id,
    NotificationType? type,
    NotificationStatus? status,
    String? rawType,
    String? rawStatus,
    String? title,
    String? message,
    DateTime? notificationDate,
    DateTime? readAt,
    bool? archived,
    NotificationCattleInfo? cattleInfo,
  }) {
    return AppNotification(
      id: id ?? this.id,
      type: type ?? this.type,
      status: status ?? this.status,
      rawType: rawType ?? this.rawType,
      rawStatus: rawStatus ?? this.rawStatus,
      title: title ?? this.title,
      message: message ?? this.message,
      notificationDate: notificationDate ?? this.notificationDate,
      readAt: readAt ?? this.readAt,
      archived: archived ?? this.archived,
      cattleInfo: cattleInfo ?? this.cattleInfo,
    );
  }
}
