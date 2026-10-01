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

  /// Покупатель с просроченным долгом (`FINANCE_OVERDUE`).
  final int? counterpartyId;

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
    this.counterpartyId,
  });

  bool get isUnread => readAt == null;

  /// Куда ведёт нажатие: карточка животного или «Долги» с покупателем.
  /// `null` — уведомление никуда не ведёт.
  String? get target {
    if (type == NotificationType.financeOverdue) {
      final id = counterpartyId;
      return id == null
          ? '/finance/debts'
          : '/finance/debts?counterpartyId=$id';
    }
    final cattleId = cattleInfo?.cattleId;
    return cattleId == null ? null : '/herd/$cattleId';
  }

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
    int? counterpartyId,
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
      counterpartyId: counterpartyId ?? this.counterpartyId,
    );
  }
}
