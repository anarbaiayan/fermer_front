import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:frontend/core/theme/app_colors.dart';

Future<void> showAppSuccessDialog(
  BuildContext context, {
  required String title,
  String? message,

  String buttonText = 'Понятно',

  // Иконка сверху (как было)
  String iconAsset = 'assets/icons/success.svg',
  Widget? icon,
  double iconWidth = 50,
  double iconHeight = 50,

  // Иконка в кнопке (НОВОЕ)
  Widget? buttonIcon,
  double buttonIconSize = 18,
  double buttonIconGap = 6,
  bool buttonIconAfterText = true, // как у тебя: текст, потом стрелка

  EdgeInsets contentPadding = const EdgeInsets.fromLTRB(24, 36, 24, 36),
  bool barrierDismissible = false,
  VoidCallback? onButtonPressed,
}) {
  final topIconWidget =
      icon ??
      SvgPicture.asset(
        iconAsset,
        width: iconWidth,
        height: iconHeight,
      );

  Widget buildButtonChild() {
    if (buttonIcon == null) {
      return Text(
        buttonText,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.primary1,
        ),
      );
    }

    final iconSized = IconTheme(
      data: const IconThemeData(color: AppColors.primary1),
      child: SizedBox(
        width: buttonIconSize,
        height: buttonIconSize,
        // ignore: unnecessary_non_null_assertion
        child: FittedBox(fit: BoxFit.contain, child: buttonIcon!),
      ),
    );

    final textWidget = Text(
      buttonText,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.primary1,
      ),
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: buttonIconAfterText
          ? [
              textWidget,
              SizedBox(width: buttonIconGap),
              iconSized,
            ]
          : [
              iconSized,
              SizedBox(width: buttonIconGap),
              textWidget,
            ],
    );
  }

  return showDialog(
    context: context,
    barrierDismissible: barrierDismissible,
    builder: (ctx) {
      return Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        child: Padding(
          padding: contentPadding,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: iconWidth,
                height: iconHeight,
                child: FittedBox(fit: BoxFit.contain, child: topIconWidget),
              ),
              const SizedBox(height: 12),

              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary3,
                ),
              ),

              if (message != null) ...[
                const SizedBox(height: 12),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.authSmallText,
                  ),
                ),
              ],

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(
                      color: AppColors.primary1,
                      width: 1.4,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    onButtonPressed?.call();
                  },
                  child: buildButtonChild(),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
