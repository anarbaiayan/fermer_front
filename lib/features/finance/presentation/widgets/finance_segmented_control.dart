import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_colors.dart';

import '../finance_styles.dart';

/// Сегментный переключатель: «Оплачено / В долг», «л / кг / шт»,
/// «Наличные / Карта / Банк», «Счета / Покупатели».
///
/// Порядок сегментов — порядок ключей [segments].
class FinanceSegmentedControl<T> extends StatelessWidget {
  const FinanceSegmentedControl({
    super.key,
    required this.segments,
    required this.selected,
    required this.onChanged,
  });

  final Map<T, String> segments;
  final T selected;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: FinanceColors.fieldFill,
        borderRadius: BorderRadius.circular(40),
      ),
      child: Row(
        children: [
          for (final entry in segments.entries)
            Expanded(
              child: _Segment(
                label: entry.value,
                selected: entry.key == selected,
                onTap: () {
                  if (entry.key != selected) onChanged(entry.key);
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  const _Segment({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          height: 40,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 6),
          decoration: BoxDecoration(
            color: selected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(40),
            boxShadow: selected
                ? const [
                    BoxShadow(
                      color: Color(0x14000000),
                      blurRadius: 6,
                      offset: Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 14,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              color: selected ? AppColors.primary1 : AppColors.additional3,
            ),
          ),
        ),
      ),
    );
  }
}
