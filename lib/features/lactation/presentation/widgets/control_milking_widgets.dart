import 'package:flutter/material.dart';
import 'package:frontend/core/icons/app_icons.dart';
import 'package:frontend/core/localization/l10n_extension.dart';
import 'package:frontend/core/theme/app_colors.dart';

import '../../domain/entities/milking_time.dart';

/// Шапка шагов контрольного надоя: назад + заголовок + "Шаг N из 2".
class ControlMilkingHeader extends StatelessWidget {
  final int step;
  final VoidCallback onBack;

  const ControlMilkingHeader({
    super.key,
    required this.step,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            IconButton(
              padding: EdgeInsets.zero,
              icon: AppIcons.svg('arrow', size: 32),
              onPressed: onBack,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                l10n.controlMilkingTitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary3,
                ),
              ),
            ),
            const SizedBox(width: 48),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          l10n.controlMilkingStep(step, 2),
          style: const TextStyle(fontSize: 13, color: AppColors.additional3),
        ),
      ],
    );
  }
}

/// Выпадающий список времени доения.
///
/// Значения ровно те, что понимает бэкенд: MORNING / EVENING.
class MilkingTimeDropdown extends StatelessWidget {
  final MilkingTime value;
  final ValueChanged<MilkingTime> onChanged;

  const MilkingTimeDropdown({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(40),
        color: const Color.fromARGB(255, 239, 239, 239),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<MilkingTime>(
          value: value,
          isExpanded: true,
          items: [
            DropdownMenuItem(
              value: MilkingTime.morning,
              child: Text(l10n.lactationMorning),
            ),
            DropdownMenuItem(
              value: MilkingTime.evening,
              child: Text(l10n.lactationEvening),
            ),
          ],
          onChanged: (v) {
            if (v != null) onChanged(v);
          },
        ),
      ),
    );
  }
}

/// Локализованное название времени доения для сводных строк и диалогов.
String milkingTimeLabel(BuildContext context, MilkingTime time) {
  final l10n = context.l10n;
  return time == MilkingTime.evening
      ? l10n.lactationEvening
      : l10n.lactationMorning;
}

/// Закреплённая нижняя панель шага.
class ControlMilkingBottomBar extends StatelessWidget {
  final Widget info;
  final Widget action;

  const ControlMilkingBottomBar({
    super.key,
    required this.info,
    required this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.additional2)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
          child: Row(
            children: [
              Expanded(child: info),
              const SizedBox(width: 12),
              action,
            ],
          ),
        ),
      ),
    );
  }
}

/// Небольшая кнопка-чип для фильтров списка.
class ControlMilkingChip extends StatelessWidget {
  final String text;
  final bool active;
  final bool showCaret;
  final VoidCallback onTap;

  const ControlMilkingChip({
    super.key,
    required this.text,
    required this.active,
    required this.onTap,
    this.showCaret = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: active ? AppColors.primary1 : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: active ? AppColors.primary1 : AppColors.additional2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              text,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: active ? Colors.white : AppColors.primary3,
              ),
            ),
            if (showCaret) ...[
              const SizedBox(width: 4),
              Icon(
                Icons.keyboard_arrow_down,
                size: 16,
                color: active ? Colors.white : AppColors.primary3,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Единый пустой/ошибочный экран для обоих шагов.
class ControlMilkingMessageState extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? actionText;
  final VoidCallback? onAction;

  const ControlMilkingMessageState({
    super.key,
    required this.title,
    required this.subtitle,
    this.actionText,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.primary3,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.additional3,
              ),
            ),
            if (actionText != null && onAction != null) ...[
              const SizedBox(height: 12),
              TextButton(onPressed: onAction, child: Text(actionText!)),
            ],
          ],
        ),
      ),
    );
  }
}
