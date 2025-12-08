import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/features/auth/application/auth_providers.dart';
import 'package:frontend/features/auth/presentation/widgets/register_header.dart';
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

      final unmasked = phoneFormatter.getUnmaskedText(); // 7064078385 и т.п.
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

      await ref.read(authControllerProvider.notifier).register(
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
        await _showSuccessDialog(context);
        if (context.mounted) {
          context.go('/home');
        }
      } else if (newState.error != null && context.mounted) {
        // дополнительно покажем Snackbar с ошибкой сервера
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(newState.error!)),
        );
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
                          fontSize: 11,
                          color: AppColors.authSmallText,
                        ),
                      ),

                      const SizedBox(height: 32),

                      // -------- Телефон --------
                      const Text(
                        'Номер телефона',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: AppColors.primary3,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: phoneController,
                        keyboardType: TextInputType.phone,
                        inputFormatters: <TextInputFormatter>[phoneFormatter],
                        decoration: _outlinedInputDecoration(
                          hintText: 'Введите номер',
                          // если глобальная ошибка, тоже подсветим поле
                          hasError:
                              phoneError.value != null || hasGlobalError,
                        ),
                      ),
                      if (phoneError.value != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          phoneError.value!,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.error,
                          ),
                        ),
                      ],

                      const SizedBox(height: 16),

                      // -------- Пароль --------
                      const Text(
                        'Пароль',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: AppColors.primary3,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: passwordController,
                        obscureText: !passwordVisible.value,
                        decoration: _outlinedInputDecoration(
                          hintText: 'Введите пароль',
                          hasError:
                              passwordError.value != null || hasGlobalError,
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
                        ),
                      ),

                      const SizedBox(height: 16),

                      // -------- Подтверждение пароля --------
                      const Text(
                        'Подтверждение пароля',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: AppColors.primary3,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: confirmController,
                        obscureText: !confirmVisible.value,
                        decoration: _outlinedInputDecoration(
                          hintText: 'Введите пароль повторно',
                          hasError:
                              passwordError.value != null || hasGlobalError,
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
                      ),

                      // локальная ошибка пароля ИЛИ серверная
                      if (passwordError.value != null || hasGlobalError) ...[
                        const SizedBox(height: 4),
                        Text(
                          passwordError.value ??
                              authState.error ??
                              'Ошибка регистрации. Попробуйте снова.',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.error,
                          ),
                        ),
                      ],

                      const SizedBox(height: 32),

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
                          onPressed: authState.isLoading
                              ? null
                              : () => onRegisterPressed(),
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
                                  'Зарегистрироваться',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                        ),
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

  InputDecoration _outlinedInputDecoration({
    required String hintText,
    bool hasError = false,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 14,
        vertical: 14,
      ),
      suffixIcon: suffixIcon,
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(
          color: hasError ? AppColors.error : AppColors.additional1,
          width: 1,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(
          color: hasError ? AppColors.error : AppColors.primary1,
          width: 1.5,
        ),
      ),
    );
  }
}

Future<void> _showSuccessDialog(BuildContext context) async {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (ctx) {
      return Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 36, 24, 36),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SvgPicture.asset(
                'assets/icons/user-success.svg',
                width: 111,
                height: 111,
              ),
              const SizedBox(height: 15),
              const Text(
                'Вы успешно\nзарегистрировались\nв Fermer+!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary3,
                ),
              ),
              const SizedBox(height: 7),
              const Text(
                'Для того, чтобы начать использовать\nприложение, нажмите на кнопку "Начать работу"',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 11, color: AppColors.authSmallText),
              ),
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
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Начать работу',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary1,
                        ),
                      ),
                      SizedBox(width: 6),
                      Icon(
                        Icons.arrow_forward_rounded,
                        size: 18,
                        color: AppColors.primary1,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
