import 'package:flutter/material.dart';
import 'package:frontend/core/icons/app_icons.dart';
import 'package:frontend/core/localization/l10n_extension.dart';
import 'package:frontend/core/theme/app_colors.dart';

/// Что пользователь выбрал в шторке "Добавить данные о надое".
enum AddLactationKind {
  /// Ежедневный общий отчёт по ферме.
  bulk,

  /// Контрольный замер продуктивности отдельных коров.
  control,
}

/// Шторка выбора сценария по кнопке "+" на экране "Лактация".
///
/// Закрывается свайпом, тапом вне, кнопкой "Отменить" и системным Back —
/// поведение по умолчанию у [showModalBottomSheet], специально ничего не
/// перехватываем.
Future<AddLactationKind?> showAddLactationTypeSheet(BuildContext context) {
  return showModalBottomSheet<AddLactationKind>(
    context: context,
    backgroundColor: Colors.white,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) => const _AddLactationTypeSheet(),
  );
}

class _AddLactationTypeSheet extends StatelessWidget {
  const _AddLactationTypeSheet();

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.additional2,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              l10n.lactationAddSheetTitle,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.primary3,
              ),
            ),
            const SizedBox(height: 16),
            _SheetOption(
              title: l10n.lactationFarmMilking,
              subtitle: l10n.lactationAddSheetFarmHint,
              onTap: () => Navigator.of(context).pop(AddLactationKind.bulk),
            ),
            const SizedBox(height: 10),
            _SheetOption(
              title: l10n.controlMilkingTitle,
              subtitle: l10n.lactationAddSheetControlHint,
              onTap: () => Navigator.of(context).pop(AddLactationKind.control),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  l10n.dialogCancel,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.additional3,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SheetOption extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SheetOption({
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.additional2),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.primary2,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(child: AppIcons.svg('lactation_number', size: 28)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary3,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.additional3,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
