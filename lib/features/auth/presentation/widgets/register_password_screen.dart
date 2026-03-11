import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/widgets/app_text_field.dart';
import 'package:frontend/core/widgets/app_primary_button.dart';
import 'package:frontend/core/widgets/app_success_dialog.dart';
import 'package:frontend/features/auth/application/auth_providers.dart';
import 'package:frontend/features/auth/presentation/widgets/register_header.dart';
import 'package:frontend/features/herd/presentation/widgets/herd_steps_indicator.dart';
import 'package:frontend/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

import '../auth_error_localizer.dart';
import 'register_flow_models.dart';

class RegisterStep2Screen extends HookConsumerWidget {
  final RegisterInfo initialData;

  const RegisterStep2Screen({super.key, required this.initialData});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final authState = ref.watch(authControllerProvider);

    final phoneController = useTextEditingController();
    final passwordController = useTextEditingController();
    final confirmController = useTextEditingController();

    final passwordVisible = useState(false);
    final confirmVisible = useState(false);

    final phoneError = useState<String?>(null);
    final passwordError = useState<String?>(null);

    final phoneFormatter = useMemoized(
      () => MaskTextInputFormatter(
        mask: '+7 (###) ###-##-##',
        // ignore: deprecated_member_use
        filter: {'#': RegExp(r'\d')},
      ),
    );

    Future<void> onRegisterPressed() async {
      phoneError.value = null;
      passwordError.value = null;

      final unmasked = phoneFormatter.getUnmaskedText();
      if (unmasked.length != 10) {
        phoneError.value = l10n.loginPhoneError;
        return;
      }

      final phone = '+7$unmasked';
      final pass = passwordController.text.trim();
      final confirm = confirmController.text.trim();

      if (pass.length < 6) {
        passwordError.value = l10n.registerPasswordMin;
        return;
      }

      if (pass != confirm) {
        passwordError.value = l10n.registerPasswordsMismatch;
        return;
      }

      await ref
          .read(authControllerProvider.notifier)
          .register(
            phoneNumber: phone,
            password: pass,
            firstName: initialData.firstName,
            lastName: initialData.lastName,
            farmName: initialData.farmName,
          );

      final newState = ref.read(authControllerProvider);

      if (newState.tokens != null &&
          newState.error == null &&
          context.mounted) {
        await showAppSuccessDialog(
          context,
          title: l10n.registerSuccessTitle,
          message: l10n.registerSuccessMessage,
          iconAsset: 'assets/icons/user-success.svg',
          iconHeight: 111,
          iconWidth: 111,
          onButtonPressed: () {},
          buttonText: l10n.registerSuccessButton,
          buttonIcon: const Icon(Icons.arrow_forward_rounded),
          buttonIconSize: 18,
          buttonIconAfterText: true,
        );
        if (context.mounted) {
          context.go('/home');
        }
      } else if (newState.error != null && context.mounted) {
        final message = localizeAuthError(context, newState.error!);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      }
    }

    final hasGlobalError = authState.error != null;

    String? passwordFieldErrorText() {
      if (passwordError.value != null) return passwordError.value;
      if (hasGlobalError) {
        final raw = authState.error;
        if (raw == null) return l10n.registerErrorGeneric;
        return localizeAuthError(context, raw);
      }
      return null;
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const RegisterHeader(),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.registerSubtitle,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.authSmallText,
                        ),
                      ),
                      const SizedBox(height: 32),
                      const HerdStepsIndicator(currentStep: 2),
                      const SizedBox(height: 32),

                      // Телефон
                      AppTextField(
                        label: l10n.loginPhoneLabel,
                        hintText: l10n.loginPhoneHint,
                        controller: phoneController,
                        keyboardType: TextInputType.phone,
                        inputFormatters: <TextInputFormatter>[phoneFormatter],
                        errorText: phoneError.value,
                      ),

                      const SizedBox(height: 16),

                      // Пароль
                      AppTextField(
                        label: l10n.loginPasswordLabel,
                        hintText: l10n.forgotPasswordNewHint,
                        controller: passwordController,
                        obscureText: !passwordVisible.value,
                        suffixIcon: IconButton(
                          onPressed: () =>
                              passwordVisible.value = !passwordVisible.value,
                          icon: Icon(
                            passwordVisible.value
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            size: 20,
                            color: AppColors.additional3,
                          ),
                        ),
                        errorText: passwordFieldErrorText(),
                      ),

                      const SizedBox(height: 16),

                      // Подтверждение пароля
                      AppTextField(
                        label: l10n.forgotPasswordConfirmLabel,
                        hintText: l10n.forgotPasswordConfirmHint,
                        controller: confirmController,
                        obscureText: !confirmVisible.value,
                        suffixIcon: IconButton(
                          onPressed: () =>
                              confirmVisible.value = !confirmVisible.value,
                          icon: Icon(
                            confirmVisible.value
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            size: 20,
                            color: AppColors.additional3,
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),

                      AppPrimaryButton(
                        text: l10n.registerButton,
                        isLoading: authState.isLoading,
                        onPressed: authState.isLoading
                            ? null
                            : () => onRegisterPressed(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
