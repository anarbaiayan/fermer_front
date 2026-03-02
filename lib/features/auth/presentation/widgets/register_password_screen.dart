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
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

import 'register_flow_models.dart';

class RegisterStep2Screen extends HookConsumerWidget {
  final RegisterInfo initialData;

  const RegisterStep2Screen({super.key, required this.initialData});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
      // очищаем старые локальные ошибки
      phoneError.value = null;
      passwordError.value = null;

      final unmasked = phoneFormatter.getUnmaskedText();
      if (unmasked.length != 10) {
        phoneError.value = 'Введите корректный номер телефона';
        return;
      }

      final phone = '+7$unmasked';
      final pass = passwordController.text.trim();
      final confirm = confirmController.text.trim();

      if (pass.length < 6) {
        passwordError.value = 'Минимум 6 символов';
        return;
      }

      if (pass != confirm) {
        passwordError.value = 'Пароли не совпадают';
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
          title: 'Вы успешно\nзарегистрировались\nв Fermer+!',
          message:
              'Для того, чтобы начать использовать\nприложение, нажмите на кнопку\n"Начать работу"',
          iconAsset: 'assets/icons/user-success.svg',
          iconHeight: 111,
          iconWidth: 111,
          onButtonPressed: () {},
          buttonText: 'Начать работу ',
          buttonIcon: const Icon(Icons.arrow_forward_rounded),
          buttonIconSize: 18,
          buttonIconAfterText: true,
        );
        if (context.mounted) {
          context.go('/home');
        }
      } else if (newState.error != null && context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(newState.error!)));
      }
    }

    final hasGlobalError = authState.error != null;

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
                        'Введите информацию для регистрации',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.authSmallText,
                        ),
                      ),
                      const SizedBox(height: 32),
                      const HerdStepsIndicator(currentStep: 2),

                      const SizedBox(height: 32),

                      // -------- Телефон --------
                      AppTextField(
                        label: 'Номер телефона',
                        hintText: 'Введите номер',
                        controller: phoneController,
                        keyboardType: TextInputType.phone,
                        inputFormatters: <TextInputFormatter>[phoneFormatter],
                        errorText: phoneError.value,
                      ),

                      const SizedBox(height: 16),

                      // -------- Пароль --------
                      AppTextField(
                        label: 'Пароль',
                        hintText: 'Введите пароль',
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
                        errorText: passwordError.value != null || hasGlobalError
                            ? (passwordError.value ??
                                  authState.error ??
                                  'Ошибка регистрации. Попробуйте снова.')
                            : null,
                      ),

                      const SizedBox(height: 16),

                      // -------- Подтверждение пароля --------
                      AppTextField(
                        label: 'Подтверждение пароля',
                        hintText: 'Введите пароль повторно',
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
                        text: 'ЗАРЕГИСТРИРОВАТЬСЯ',
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
