import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/widgets/app_page.dart';
import 'package:frontend/core/widgets/app_button.dart';
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
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: AppPage(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(0, 24, 0, 24),
            children: [
              const SizedBox(height: 6),
              const Center(
                child: Text(
                  'FERMER +',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary1,
                  ),
                ),
              ),

              const SizedBox(height: 28),

              const Text(
                'Введите новый пароль',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary3,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Установите новый пароль для входа в приложение',
                style: TextStyle(
                  fontSize: 13,
                  height: 1.35,
                  color: AppColors.additional3,
                ),
              ),

              const SizedBox(height: 32),

              const Text(
                'Новый пароль',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary3,
                ),
              ),
              const SizedBox(height: 8),

              TextField(
                controller: _pass1,
                obscureText: !_show1,
                decoration: InputDecoration(
                  hintText: 'Введите новый пароль',
                  filled: true,
                  fillColor: AppColors.background,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 14,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.additional1),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: AppColors.primary1,
                      width: 1.2,
                    ),
                  ),
                  suffixIcon: IconButton(
                    onPressed: () => setState(() => _show1 = !_show1),
                    icon: Icon(
                      _show1 ? Icons.visibility_off : Icons.visibility,
                    ),
                    color: AppColors.additional3,
                  ),
                ),
              ),

              const SizedBox(height: 14),

              const Text(
                'Подтверждение пароля',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary3,
                ),
              ),
              const SizedBox(height: 8),

              TextField(
                controller: _pass2,
                obscureText: !_show2,
                decoration: InputDecoration(
                  hintText: 'Введите пароль повторно',
                  filled: true,
                  fillColor: AppColors.background,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 14,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.additional1),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: AppColors.primary1,
                      width: 1.2,
                    ),
                  ),
                  suffixIcon: IconButton(
                    onPressed: () => setState(() => _show2 = !_show2),
                    icon: Icon(
                      _show2 ? Icons.visibility_off : Icons.visibility,
                    ),
                    color: AppColors.additional3,
                  ),
                ),
              ),

              const SizedBox(height: 18),

              FermerPlusBigButton(
                text: 'Установить пароль',
                height: 50,
                borderRadius: 6,
                onPressed: () async {
                  // пока без бэка: просто вернем на login
                  await showAppSuccessDialog(
                    context,
                    title: 'Новый пароль успешно\nустановлен!',
                    iconAsset:
                        'assets/icons/user-success.svg', // если у тебя уже есть
                    buttonText: 'Войти в Fermer +',
                    iconHeight: 111,
                    iconWidth: 111
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
