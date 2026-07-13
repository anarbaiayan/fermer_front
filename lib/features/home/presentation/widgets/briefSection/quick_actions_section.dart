import 'package:flutter/material.dart';
import 'package:frontend/core/icons/app_icons.dart';
import 'package:frontend/core/localization/l10n_extension.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:go_router/go_router.dart';

/// Блок «Быстрые действия» на главной: три квадратные кнопки-шортката.
///
/// Переходы — tab-like (`context.go`), как у bottom nav: экран не кладётся
/// поверх текущего стека.
class QuickActionsSection extends StatelessWidget {
  const QuickActionsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.homeQuickActions,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _QuickActionTile(
                iconName: 'events',
                label: l10n.homeActionEvent,
                onTap: () => context.go('/events'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _QuickActionTile(
                iconName: 'cow',
                label: l10n.homeHerd,
                onTap: () => context.go('/herd'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _QuickActionTile(
                iconName: 'medicine',
                label: l10n.pharmacyTitle,
                onTap: () => context.go('/pharmacy'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

/// Округлённый квадрат: иконка по центру сверху, подпись снизу.
class _QuickActionTile extends StatelessWidget {
  final String iconName;
  final String label;
  final VoidCallback onTap;

  const _QuickActionTile({
    required this.iconName,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      // Квадрат: ширину задаёт Expanded, высота считается от неё —
      // одинаковый размер кнопок на любом экране, без overflow.
      aspectRatio: 1,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Ink(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.primary1.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.additional2),
              boxShadow: const [
                BoxShadow(
                  color: Color.fromRGBO(213, 215, 218, 0.22),
                  offset: Offset(0, 4),
                  blurRadius: 20,
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AppIcons.svg(iconName, size: 28, color: AppColors.primary1),
                const SizedBox(height: 10),
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      label,
                      maxLines: 1,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary3,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
