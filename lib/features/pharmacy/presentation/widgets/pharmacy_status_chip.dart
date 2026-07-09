import 'package:flutter/material.dart';
import 'package:frontend/core/localization/l10n_extension.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/features/pharmacy/domain/entities/vet_request_status.dart';
import 'package:frontend/features/pharmacy/presentation/pharmacy_format.dart';

/// Цветной чип статуса заявки. Текст локализуется на фронте.
class PharmacyStatusChip extends StatelessWidget {
  final VetRequestStatus status;

  const PharmacyStatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final color = _colorFor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        localizedRequestStatus(context.l10n, status),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Color _colorFor(VetRequestStatus status) {
    switch (status) {
      case VetRequestStatus.newRequest:
        return AppColors.background3;
      case VetRequestStatus.inProgress:
        return AppColors.warning;
      case VetRequestStatus.done:
        return AppColors.success;
      case VetRequestStatus.cancelled:
        return AppColors.error;
      case VetRequestStatus.unknown:
        return AppColors.additional3;
    }
  }
}
