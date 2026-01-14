import 'package:flutter/material.dart';
import 'package:frontend/core/icons/app_icons.dart';
import 'package:frontend/core/theme/app_colors.dart';

class ConfirmDialog extends StatelessWidget {
  final String title;
  final String? iconName;
  final Color? iconColor;

  final String confirmText;
  final String cancelText;

  final Color confirmColor;
  final Color confirmTextColor;

  const ConfirmDialog({
    super.key,
    required this.title,
    this.iconName,
    this.iconColor,
    this.confirmText = 'Ок',
    this.cancelText = 'Отменить',
    this.confirmColor = const Color(0xFFD74B4B),
    this.confirmTextColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 18),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(30, 36, 30, 36),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 6),
            if (iconName != null) ...[
              AppIcons.svg(iconName!, size: 50, color: iconColor),
              const SizedBox(height: 14),
            ],
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: AppColors.primary3,
              ),
            ),
            const SizedBox(height: 28),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 44,
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: confirmColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      onPressed: () => Navigator.of(context).pop(true),
                      child: Text(
                        confirmText,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: confirmTextColor,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 24),
                Expanded(
                  child: SizedBox(
                    height: 44,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.primary3),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text(
                        'Отменить',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.primary3,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

Future<bool> showConfirmDialog({
  required BuildContext context,
  required String title,
  String? iconName,
  Color? iconColor,
  String confirmText = 'Ок',
  String cancelText = 'Отменить',
  bool barrierDismissible = true,
  Color confirmColor = const Color(0xFFD74B4B),
}) async {
  final res = await showDialog<bool>(
    context: context,
    barrierDismissible: barrierDismissible,
    builder: (_) => ConfirmDialog(
      title: title,
      iconName: iconName,
      iconColor: iconColor,
      confirmText: confirmText,
      cancelText: cancelText,
      confirmColor: confirmColor,
    ),
  );
  return res == true;
}
