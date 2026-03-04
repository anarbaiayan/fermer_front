import 'package:flutter/material.dart';
import 'package:frontend/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/app_outlined_button.dart';

class LoginRegisterBlock extends StatelessWidget {
  const LoginRegisterBlock({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: [
        Center(
          child: Text(
            l10n.loginNoAccount,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.primary3,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Center(
          child: Text(
            l10n.loginRegisterHint,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: AppColors.authSmallText),
          ),
        ),
        const SizedBox(height: 22),
        AppOutlinedButton(
          text: l10n.loginRegisterButton,
          onPressed: () => context.push('/register-step1'),
        ),
      ],
    );
  }
}
