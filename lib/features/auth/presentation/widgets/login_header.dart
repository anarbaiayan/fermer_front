import 'package:flutter/material.dart';
import 'package:frontend/l10n/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_logo.dart';

class LoginHeader extends StatelessWidget {
  const LoginHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const AppLogo(height: 40),

        const SizedBox(height: 32),

        Text(
          l10n.loginTitle,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: AppColors.primary1,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          l10n.loginSubtitle,
          style: TextStyle(fontSize: 14, color: AppColors.authSmallText),
        ),
      ],
    );
  }
}