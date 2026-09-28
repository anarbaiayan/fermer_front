import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_colors.dart';

/// Нижняя шторка «Финансов»: белая, скругление 24, ручка сверху.
/// Поднимается над клавиатурой и прокручивается, если не помещается.
Future<T?> showFinanceSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (sheetContext) => Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.viewInsetsOf(sheetContext).bottom,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 10, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.additional2,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 14),
            builder(sheetContext),
          ],
        ),
      ),
    ),
  );
}

/// Шторка выбора одного значения из списка, например фильтра счёта.
/// Возвращает выбранный ключ или `null`, если шторку закрыли.
Future<T?> showFinancePickerSheet<T>({
  required BuildContext context,
  required String title,
  required Map<T, String> options,
  required T selected,
}) {
  return showFinanceSheet<T>(
    context: context,
    builder: (sheetContext) => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.primary3,
          ),
        ),
        const SizedBox(height: 4),
        for (final entry in options.entries)
          InkWell(
            onTap: () => Navigator.of(sheetContext).pop(entry.key),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
              decoration: const BoxDecoration(
                border: Border(bottom: BorderSide(color: Color(0xFFF0F0F0))),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      entry.value,
                      style: const TextStyle(
                        fontSize: 15,
                        color: AppColors.primary3,
                      ),
                    ),
                  ),
                  if (entry.key == selected)
                    const Icon(
                      Icons.check_rounded,
                      size: 20,
                      color: AppColors.primary1,
                    ),
                ],
              ),
            ),
          ),
      ],
    ),
  );
}
