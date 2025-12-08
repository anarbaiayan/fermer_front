import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Небольшая кнопка типа "Подробнее"
class FermerPlusSmallButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  /// Ширина кнопки. Если null - кнопка подстраивается под контент.
  final double? width;

  /// Высота кнопки (по умолчанию 36).
  final double height;

  /// Цвет фона (по умолчанию основной зелёный).
  final Color backgroundColor;

  const FermerPlusSmallButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.width,
    this.height = 36,
    this.backgroundColor = AppColors.primary1,
  });

  @override
  Widget build(BuildContext context) {
    final button = FilledButton(
      style: FilledButton.styleFrom(
        backgroundColor: backgroundColor,
        minimumSize: Size(0, height),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
        ),
      ),
      onPressed: onPressed,
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: Colors.white,
        ),
      ),
    );

    if (width == null) return button;

    return SizedBox(
      width: width,
      child: button,
    );
  }
}

/// Большая широкая кнопка типа "Добавить животное"
class FermerPlusBigButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  /// Высота кнопки (по умолчанию 48).
  final double height;
  final double borderRadius;
  final double fontSize;

  const FermerPlusBigButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.height = 48,
    this.borderRadius = 8,
    this.fontSize = 16,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity, // растянуть на всю ширину
      height: height,
      child: FilledButton(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
        onPressed: onPressed,
        child: Text(
          text,
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
