import 'package:flutter/material.dart';
import 'package:frontend/core/localization/l10n_extension.dart';
import 'package:frontend/core/theme/app_colors.dart';

import '../../domain/entities/finance_enums.dart';
import '../finance_styles.dart';
import 'finance_common.dart';

/// Выбор категории расхода плитками, по четыре в ряд, как в прототипе.
/// Плитки одного ряда одной высоты.
class ExpenseCategoryTiles extends StatelessWidget {
  const ExpenseCategoryTiles({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final ExpenseCategory? selected;
  final ValueChanged<ExpenseCategory> onChanged;

  static const _perRow = 4;

  @override
  Widget build(BuildContext context) {
    const categories = ExpenseCategory.values;
    final rows = <Widget>[];
    for (var start = 0; start < categories.length; start += _perRow) {
      final rowItems = categories.skip(start).take(_perRow).toList();
      rows.add(
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < _perRow; i++) ...[
                if (i > 0) const SizedBox(width: 8),
                Expanded(
                  child: i < rowItems.length
                      ? _CategoryTile(
                          category: rowItems[i],
                          selected: rowItems[i] == selected,
                          onTap: () => onChanged(rowItems[i]),
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            ],
          ),
        ),
      );
    }
    return Column(
      children: [
        for (var i = 0; i < rows.length; i++) ...[
          if (i > 0) const SizedBox(height: 8),
          rows[i],
        ],
      ],
    );
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({
    required this.category,
    required this.selected,
    required this.onTap,
  });

  final ExpenseCategory category;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      child: Material(
        color: selected ? FinanceColors.softGreen : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: selected ? AppColors.primary1 : AppColors.additional2,
            width: 1.5,
          ),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Stack(
            children: [
              Container(
                constraints: const BoxConstraints(minHeight: 84),
                padding: const EdgeInsets.fromLTRB(4, 10, 4, 8),
                alignment: Alignment.center,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FinanceIconSquare.small(
                      icon: category.iconName,
                      color: category.color,
                    ),
                    const SizedBox(height: 6),
                    // Подписи — одно слово («Оборудование», «Ветпрепараттар»),
                    // и в плитку шириной ~72 px не всегда влезают. Слово
                    // уменьшается целиком, а не рвётся посередине.
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        category.localizedLabel(context.l10n),
                        maxLines: 1,
                        style: const TextStyle(
                          fontSize: 11.5,
                          height: 1.2,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (selected)
                Positioned(
                  top: 5,
                  right: 5,
                  child: Container(
                    width: 18,
                    height: 18,
                    decoration: const BoxDecoration(
                      color: AppColors.primary1,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      size: 12,
                      color: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
