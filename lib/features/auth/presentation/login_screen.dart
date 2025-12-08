import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

import '../../../core/theme/app_colors.dart';
import '../application/auth_providers.dart';
import 'widgets/login_header.dart';
import 'widgets/login_phone_field.dart';
import 'widgets/login_password_field.dart';
import 'widgets/login_divider.dart';
import 'widgets/login_register_block.dart';
import 'widgets/login_forgot_password_button.dart';

class LoginScreen extends HookConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authControllerProvider);

    // контроллеры
    final phoneController = useTextEditingController();
    final passwordController = useTextEditingController();

    // локальные состояния
    final passwordVisible = useState(false);
    final phoneError = useState<String?>(null);

    // маска телефона: +7 (###) ###-##-##
    final phoneFormatter = useMemoized(
      () => MaskTextInputFormatter(
        mask: '+7 (###) ###-##-##',
        // ignore: deprecated_member_use
        filter: {'#': RegExp(r'\d')},
      ),
    );

    Future<void> onLoginPressed() async {
      phoneError.value = null;

      final unmasked = phoneFormatter.getUnmaskedText(); // "7064078385"
      if (unmasked.length != 10) {
        phoneError.value = 'Введите корректный номер телефона';
        return;
      }

      final phone = '+7$unmasked';
      final pass = passwordController.text;
      if (pass.isEmpty) return;

      await ref
          .read(authControllerProvider.notifier)
          .login(phoneNumber: phone, password: pass);

      final newState = ref.read(authControllerProvider);
      if (newState.tokens != null &&
          newState.error == null &&
          context.mounted) {
        context.go('/home');
      }
    }

    final hasPasswordError = authState.error != null;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 30),

                const LoginHeader(),

                const SizedBox(height: 32),

                LoginPhoneField(
                  controller: phoneController,
                  formatter: phoneFormatter,
                  errorText: phoneError.value,
                ),

                const SizedBox(height: 24),

                LoginPasswordField(
                  controller: passwordController,
                  isVisible: passwordVisible.value,
                  onToggleVisibility: () =>
                      passwordVisible.value = !passwordVisible.value,
                  hasError: hasPasswordError,
                  errorText: authState.error,
                ),

                const SizedBox(height: 10),

                const LoginForgotPasswordButton(),

                const SizedBox(height: 46),

                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    onPressed: authState.isLoading ? null : onLoginPressed,
                    child: authState.isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Войти',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 18),

                const LoginDivider(),

                const SizedBox(height: 39),

                const LoginRegisterBlock(),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
