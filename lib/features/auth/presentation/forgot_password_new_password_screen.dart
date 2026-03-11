import 'package:flutter/material.dart';
import 'package:frontend/core/localization/l10n_extension.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/widgets/app_logo.dart';
import 'package:frontend/core/widgets/app_text_field.dart';
import 'package:frontend/core/widgets/app_primary_button.dart';
import 'package:frontend/core/widgets/app_page.dart';
import 'package:frontend/core/widgets/app_success_dialog.dart';
import 'package:go_router/go_router.dart';

class ForgotPasswordNewPasswordScreen extends StatefulWidget {
  final String? phoneNumber;
  final String? code;

  const ForgotPasswordNewPasswordScreen({
    super.key,
    this.phoneNumber,
    this.code,
  });

  @override
  State<ForgotPasswordNewPasswordScreen> createState() =>
      _ForgotPasswordNewPasswordScreenState();
}

class _ForgotPasswordNewPasswordScreenState
    extends State<ForgotPasswordNewPasswordScreen> {
  final _pass1 = TextEditingController();
  final _pass2 = TextEditingController();

  bool _show1 = false;
  bool _show2 = false;

  @override
  void dispose() {
    _pass1.dispose();
    _pass2.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: AppPage(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(0, 24, 0, 24),
            children: [
              const SizedBox(height: 6),
              const AppLogo(height: 40),

              const SizedBox(height: 28),

              Text(
                l10n.forgotPasswordNewTitle,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary3,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                l10n.forgotPasswordNewSubtitle,
                style: TextStyle(
                  fontSize: 13,
                  height: 1.35,
                  color: AppColors.additional3,
                ),
              ),

              const SizedBox(height: 32),

              AppTextField(
                label: l10n.forgotPasswordNewLabel,
                hintText: l10n.forgotPasswordNewHint,
                controller: _pass1,
                obscureText: !_show1,
                suffixIcon: IconButton(
                  onPressed: () => setState(() => _show1 = !_show1),
                  icon: Icon(_show1 ? Icons.visibility_off : Icons.visibility),
                  color: AppColors.additional3,
                ),
              ),

              const SizedBox(height: 14),

              AppTextField(
                label: l10n.forgotPasswordConfirmLabel,
                hintText: l10n.forgotPasswordConfirmHint,
                controller: _pass2,
                obscureText: !_show2,
                suffixIcon: IconButton(
                  onPressed: () => setState(() => _show2 = !_show2),
                  icon: Icon(_show2 ? Icons.visibility_off : Icons.visibility),
                  color: AppColors.additional3,
                ),
              ),

              const SizedBox(height: 18),

              AppPrimaryButton(
                text: l10n.forgotPasswordSetButton,
                onPressed: () async {
                  await showAppSuccessDialog(
                    context,
                    title: l10n.forgotPasswordSuccess,
                    iconAsset: 'assets/icons/user-success.svg',
                    buttonText: l10n.forgotPasswordGoLogin,
                    iconHeight: 111,
                    iconWidth: 111,
                  );

                  if (!context.mounted) return;
                  context.go('/login');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
