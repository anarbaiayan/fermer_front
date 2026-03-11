import 'package:flutter/material.dart';
import 'package:frontend/core/localization/l10n_extension.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/widgets/app_logo.dart';
import 'package:frontend/core/widgets/app_text_field.dart';
import 'package:frontend/core/widgets/app_primary_button.dart';
import 'package:frontend/core/widgets/app_page.dart';
import 'package:go_router/go_router.dart';

class ForgotPasswordPhoneScreen extends StatefulWidget {
  const ForgotPasswordPhoneScreen({super.key});

  @override
  State<ForgotPasswordPhoneScreen> createState() =>
      _ForgotPasswordPhoneScreenState();
}

class _ForgotPasswordPhoneScreenState extends State<ForgotPasswordPhoneScreen> {
  final _phoneCtrl = TextEditingController();

  @override
  void dispose() {
    _phoneCtrl.dispose();
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
                l10n.forgotPasswordTitle,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary3,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                l10n.forgotPasswordSubtitle,
                style: TextStyle(
                  fontSize: 13,
                  height: 1.35,
                  color: AppColors.additional3,
                ),
              ),

              const SizedBox(height: 20),

              AppTextField(
                label: l10n.loginPhoneLabel,
                hintText: l10n.loginPhoneHint,
                controller: _phoneCtrl,
                keyboardType: TextInputType.phone,
              ),

              const SizedBox(height: 16),

              AppPrimaryButton(
                text: l10n.forgotPasswordGetCode,
                onPressed: () {
                  context.push(
                    '/forgot-password/code',
                    extra: _phoneCtrl.text.trim(),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
