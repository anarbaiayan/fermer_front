import 'package:flutter/material.dart';
import 'package:frontend/core/icons/app_icons.dart';
import 'package:frontend/core/theme/app_colors.dart';

/// Чип выбора: покупатель, товар, счёт, фильтр. Выбранный — залит зелёным.
///
/// [add] рисует пунктирный чип «+ Новый».
class FinanceChip extends StatelessWidget {
  const FinanceChip({
    super.key,
    required this.label,
    this.selected = false,
    this.onTap,
    this.icon,
    this.trailingText,
    this.trailingIcon,
  }) : add = false;

  const FinanceChip.add({super.key, required this.label, this.onTap})
    : selected = false,
      icon = null,
      trailingText = null,
      trailingIcon = null,
      add = true;

  final String label;
  final bool selected;
  final VoidCallback? onTap;

  /// Иконка из `assets/icons` слева от текста.
  final String? icon;

  /// Приглушённый текст справа, например остаток счёта.
  final String? trailingText;
  final IconData? trailingIcon;
  final bool add;

  @override
  Widget build(BuildContext context) {
    final foreground = selected
        ? Colors.white
        : add
        ? AppColors.primary1
        : AppColors.primary3;

    final content = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (add) ...[
          Icon(Icons.add_rounded, size: 18, color: foreground),
          const SizedBox(width: 4),
        ] else if (icon != null) ...[
          AppIcons.svg(icon!, size: 16, color: foreground),
          const SizedBox(width: 6),
        ],
        // Длинное имя покупателя обрезается, а не выходит за строку.
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 14,
              fontWeight: add || selected ? FontWeight.w600 : FontWeight.w500,
              color: foreground,
            ),
          ),
        ),
        if (trailingText != null) ...[
          const SizedBox(width: 6),
          Text(
            trailingText!,
            maxLines: 1,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: foreground.withValues(alpha: 0.75),
            ),
          ),
        ],
        if (trailingIcon != null) ...[
          const SizedBox(width: 4),
          Icon(
            trailingIcon,
            size: 18,
            color: selected ? Colors.white : AppColors.additional3,
          ),
        ],
      ],
    );

    return Semantics(
      button: true,
      selected: selected,
      child: Material(
        color: selected ? AppColors.primary1 : Colors.white,
        shape: add
            ? const StadiumBorder()
            : StadiumBorder(
                side: BorderSide(
                  color: selected ? AppColors.primary1 : AppColors.additional2,
                ),
              ),
        child: InkWell(
          customBorder: const StadiumBorder(),
          onTap: onTap,
          child: CustomPaint(
            painter: add ? const _DashedStadiumPainter() : null,
            child: Container(
              height: 36,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              // По ширине содержимого и вне ряда чипов.
              child: Center(widthFactor: 1, child: content),
            ),
          ),
        ),
      ),
    );
  }
}

/// Ряд чипов: одной прокручиваемой строкой или с переносом ([wrap]).
///
/// В прокручиваемой строке выбранный чип сам выезжает в видимую часть,
/// если выбран не пальцем: например, сводка открыла расходы сразу
/// с категорией «Прочее» в конце ряда.
class FinanceChipRow extends StatefulWidget {
  const FinanceChipRow({super.key, required this.children, this.wrap = false});

  final List<Widget> children;
  final bool wrap;

  @override
  State<FinanceChipRow> createState() => _FinanceChipRowState();
}

class _FinanceChipRowState extends State<FinanceChipRow> {
  final _selectedKey = GlobalKey();
  int? _revealed;

  int? get _selectedIndex {
    for (var i = 0; i < widget.children.length; i++) {
      final child = widget.children[i];
      if (child is FinanceChip && child.selected) return i;
    }
    return null;
  }

  void _reveal() {
    final context = _selectedKey.currentContext;
    if (!mounted || context == null) return;
    final box = context.findRenderObject();
    final position = Scrollable.maybeOf(context)?.position;
    if (box == null || position == null) return;
    // Только горизонтально и только если чип не виден целиком.
    for (final policy in [
      ScrollPositionAlignmentPolicy.keepVisibleAtEnd,
      ScrollPositionAlignmentPolicy.keepVisibleAtStart,
    ]) {
      position.ensureVisible(
        box,
        alignmentPolicy: policy,
        duration: const Duration(milliseconds: 200),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final children = widget.children;
    if (widget.wrap) {
      return Wrap(spacing: 8, runSpacing: 8, children: children);
    }
    final selected = _selectedIndex;
    if (selected != null && selected != _revealed) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _reveal());
    }
    _revealed = selected;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      clipBehavior: Clip.none,
      child: Row(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) const SizedBox(width: 8),
            if (i == selected)
              KeyedSubtree(key: _selectedKey, child: children[i])
            else
              children[i],
          ],
        ],
      ),
    );
  }
}

class _DashedStadiumPainter extends CustomPainter {
  const _DashedStadiumPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          rect.deflate(0.5),
          Radius.circular(size.height / 2),
        ),
      );
    final paint = Paint()
      ..color = AppColors.primary1.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    const dash = 4.0;
    const gap = 3.0;
    for (final metric in path.computeMetrics()) {
      for (var d = 0.0; d < metric.length; d += dash + gap) {
        canvas.drawPath(metric.extractPath(d, d + dash), paint);
      }
    }
  }

  @override
  bool shouldRepaint(_DashedStadiumPainter oldDelegate) => false;
}
