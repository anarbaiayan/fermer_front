import 'package:flutter/material.dart';

/// Плейсхолдер-картинка препарата: у grouped-offers бэк фактически не заполняет
/// `imageUrl`, поэтому UI text-first — рисуем диагональную штриховку в бежевых
/// тонах (как в дизайне). Если `imageUrl` всё же есть — показываем фото с
/// откатом на плейсхолдер.
class DrugPlaceholderImage extends StatelessWidget {
  final String? imageUrl;
  final double? width;
  final double height;
  final double borderRadius;
  final String? label;

  const DrugPlaceholderImage({
    super.key,
    this.imageUrl,
    this.width,
    this.height = 64,
    this.borderRadius = 12,
    this.label,
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(borderRadius);
    final placeholder = ClipRRect(
      borderRadius: radius,
      child: CustomPaint(
        painter: _HatchPainter(),
        child: SizedBox(
          width: width,
          height: height,
          child: label == null
              ? null
              : Center(
                  child: Text(
                    label!,
                    style: const TextStyle(
                      fontSize: 13,
                      letterSpacing: 1.2,
                      color: Color(0xFFB7B29B),
                    ),
                  ),
                ),
        ),
      ),
    );

    final url = imageUrl;
    if (url == null || url.isEmpty) return placeholder;

    return ClipRRect(
      borderRadius: radius,
      child: SizedBox(
        width: width,
        height: height,
        child: Image.network(
          url,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => placeholder,
          loadingBuilder: (context, child, progress) =>
              progress == null ? child : placeholder,
        ),
      ),
    );
  }
}

class _HatchPainter extends CustomPainter {
  static const _bg = Color(0xFFEDEBDD);
  static const _line = Color(0xFFDBD8C4);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(rect, Paint()..color = _bg);

    final linePaint = Paint()
      ..color = _line
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke;

    canvas.save();
    canvas.clipRect(rect);
    const gap = 16.0;
    for (double x = -size.height; x < size.width; x += gap) {
      canvas.drawLine(
        Offset(x, size.height),
        Offset(x + size.height, 0),
        linePaint,
      );
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _HatchPainter oldDelegate) => false;
}
