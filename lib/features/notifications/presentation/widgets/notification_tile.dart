import 'package:flutter/material.dart';
import 'package:frontend/core/localization/l10n_extension.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/app_notification.dart';
import '../../domain/entities/notification_type.dart';

class NotificationTile extends StatelessWidget {
  final AppNotification notification;
  final VoidCallback onTap;

  const NotificationTile({
    super.key,
    required this.notification,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final tag = notification.cattleInfo?.cattleTagNumber?.trim();
    final tagText = (tag == null || tag.isEmpty) ? l10n.selectCattleNoTag : tag;
    final dateText = notification.notificationDate == null
        ? '-'
        : DateFormat('dd.MM.yyyy').format(notification.notificationDate!);

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
          decoration: BoxDecoration(
            color: notification.isUnread ? const Color(0xFFEFF6F1) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.additional2),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: _iconBg(notification.type),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _icon(notification.type),
                  size: 20,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: notification.isUnread
                                  ? FontWeight.w700
                                  : FontWeight.w600,
                              color: AppColors.primary3,
                            ),
                          ),
                        ),
                        if (notification.isUnread)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppColors.primary1,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.message,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.additional3,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${l10n.notificationsTagLabel}: $tagText',
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.primary3,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Text(
                          dateText,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.additional3,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _icon(NotificationType type) {
    switch (type) {
      case NotificationType.pregnancyCheck:
        return Icons.pregnant_woman_outlined;
      case NotificationType.heatCheck:
        return Icons.thermostat;
      case NotificationType.startDryPeriod:
        return Icons.nightlight_round;
      case NotificationType.expectedCalving:
        return Icons.event;
      case NotificationType.vaccinationDue:
        return Icons.medical_services_outlined;
      case NotificationType.weighingDue:
        return Icons.monitor_weight_outlined;
      case NotificationType.calvingSoon:
        return Icons.warning_amber_rounded;
      case NotificationType.overdueCalving:
        return Icons.error_outline;
      case NotificationType.treatmentEnd:
        return Icons.healing_outlined;
      case NotificationType.stateChanged:
        return Icons.info_outline;
      case NotificationType.reminder:
        return Icons.alarm;
      case NotificationType.info:
      case NotificationType.unknown:
        return Icons.notifications_none;
    }
  }

  Color _iconBg(NotificationType type) {
    switch (type) {
      case NotificationType.overdueCalving:
        return const Color(0xFFD9534F);
      case NotificationType.calvingSoon:
      case NotificationType.heatCheck:
        return const Color(0xFFF0AD4E);
      case NotificationType.vaccinationDue:
      case NotificationType.treatmentEnd:
        return const Color(0xFF5BC0DE);
      case NotificationType.weighingDue:
        return const Color(0xFF7A8B99);
      case NotificationType.stateChanged:
      case NotificationType.info:
      case NotificationType.reminder:
      case NotificationType.unknown:
        return const Color(0xFF4A78C1);
      default:
        return AppColors.primary1;
    }
  }
}
