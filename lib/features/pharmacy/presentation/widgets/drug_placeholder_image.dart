import 'package:flutter/material.dart';
import 'package:frontend/core/icons/app_icons.dart';
import 'package:frontend/core/theme/app_colors.dart';

/// Изображение препарата. У grouped-offers бэк фактически не заполняет
/// `imageUrl`, поэтому UI text/icon-first: мягкая зелёная подложка с иконкой
/// препарата (в стиле аватар-плейсхолдера приложения). Если `imageUrl` есть —
/// показываем фото с откатом на плейсхолдер.
class DrugPlaceholderImage extends StatelessWidget {
  final String? imageUrl;
  final double? width;
  final double height;
  final double borderRadius;
  final double? iconSize;

  const DrugPlaceholderImage({
    super.key,
    this.imageUrl,
    this.width,
    this.height = 64,
    this.borderRadius = 12,
    this.iconSize,
  });

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(borderRadius);
    final placeholder = Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.primary1.withValues(alpha: 0.06),
        borderRadius: radius,
      ),
      alignment: Alignment.center,
      child: AppIcons.svg(
        'medicine',
        size: iconSize ?? height * 0.42,
        color: AppColors.primary1.withValues(alpha: 0.55),
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
