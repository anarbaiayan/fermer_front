import 'package:flutter/material.dart';
import 'package:frontend/core/localization/l10n_extension.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/widgets/app_logo.dart';
import 'package:frontend/core/widgets/app_page.dart';
import 'package:frontend/core/widgets/app_primary_button.dart';
import 'package:frontend/core/widgets/app_success_dialog.dart';
import 'package:frontend/core/widgets/app_text_field.dart';
import 'package:frontend/features/auth/application/auth_providers.dart';
import 'package:frontend/features/auth/presentation/auth_error_localizer.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

class RestoreAccountScreen extends ConsumerStatefulWidget {
  const RestoreAccountScreen({super.key});

  @override
  ConsumerState<RestoreAccountScreen> createState() =>
      _RestoreAccountScreenState();
}

class _RestoreAccountScreenState extends ConsumerState<RestoreAccountScreen> {
  final _phoneCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _phoneFormatter = MaskTextInputFormatter(
    mask: '+7 (###) ###-##-##',
    // ignore: deprecated_member_use
    filter: {'#': RegExp(r'\d')},
  );

  bool _showPassword = false;
  bool _submitted = false;
  String? _phoneError;
  String? _passwordError;

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _restoreAccount() async {
    final l10n = context.l10n;

    setState(() {
      _submitted = true;
      _phoneError = null;
      _passwordError = null;
    });

    final digits = _phoneFormatter.getUnmaskedText();
    if (digits.length != 10) {
      setState(() => _phoneError = l10n.loginPhoneError);
      return;
    }

    if (_passwordCtrl.text.trim().isEmpty) {
      setState(() => _passwordError = l10n.restoreAccountPasswordRequired);
      return;
    }

    await ref
        .read(authControllerProvider.notifier)
        .restoreAccount(
          phoneNumber: '+7$digits',
          password: _passwordCtrl.text.trim(),
        );

    if (!mounted) return;

    final state = ref.read(authControllerProvider);
    if (state.error != null) return;

    await showAppSuccessDialog(
      context,
      title: l10n.restoreAccountSuccessTitle,
      message: l10n.restoreAccountSuccessMessage,
      buttonText: l10n.restoreAccountGoLogin,
      iconAsset: 'assets/icons/user-success.svg',
      iconWidth: 111,
      iconHeight: 111,
    );

    if (!mounted) return;
    context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final authState = ref.watch(authControllerProvider);
    final authError = _submitted && authState.error != null
        ? localizeAuthError(context, authState.error!)
        : null;

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
                l10n.restoreAccountTitle,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary3,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                l10n.restoreAccountSubtitle,
                style: const TextStyle(
                  fontSize: 13,
                  height: 1.35,
                  color: AppColors.additional3,
                ),
              ),
              const SizedBox(height: 24),
              AppTextField(
                label: l10n.loginPhoneLabel,
                hintText: l10n.loginPhoneHint,
                controller: _phoneCtrl,
                keyboardType: TextInputType.phone,
                inputFormatters: [_phoneFormatter],
                errorText: _phoneError,
              ),
              const SizedBox(height: 16),
              AppTextField(
                label: l10n.loginPasswordLabel,
                hintText: l10n.loginPasswordLabel,
                controller: _passwordCtrl,
                obscureText: !_showPassword,
                errorText: _passwordError ?? authError,
                suffixIcon: IconButton(
                  onPressed: () =>
                      setState(() => _showPassword = !_showPassword),
                  icon: Icon(
                    _showPassword ? Icons.visibility_off : Icons.visibility,
                  ),
                  color: AppColors.additional3,
                ),
              ),
              const SizedBox(height: 18),
              AppPrimaryButton(
                text: l10n.restoreAccountButton,
                isLoading: authState.isLoading,
                onPressed: authState.isLoading ? null : _restoreAccount,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
