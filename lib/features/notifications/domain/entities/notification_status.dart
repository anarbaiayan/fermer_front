enum NotificationStatus {
  pending,
  sent,
  read,
  completed,
  snoozed,
  overdue,
  archived,
  unknown,
}

extension NotificationStatusX on NotificationStatus {
  static NotificationStatus fromApi(String? raw) {
    switch ((raw ?? '').toUpperCase()) {
      case 'PENDING':
        return NotificationStatus.pending;
      case 'SENT':
        return NotificationStatus.sent;
      case 'READ':
        return NotificationStatus.read;
      case 'COMPLETED':
        return NotificationStatus.completed;
      case 'SNOOZED':
        return NotificationStatus.snoozed;
      case 'OVERDUE':
        return NotificationStatus.overdue;
      case 'ARCHIVED':
        return NotificationStatus.archived;
      default:
        return NotificationStatus.unknown;
    }
  }
}
