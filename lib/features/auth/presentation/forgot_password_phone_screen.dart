import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/widgets/app_page.dart';
import 'package:frontend/core/widgets/app_button.dart';
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
                'Забыли пароль?',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary3,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Проверьте номер телефона, на который придет код верификации для сброса пароля',
                style: TextStyle(
                  fontSize: 13,
                  height: 1.35,
                  color: AppColors.additional3,
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                'Номер телефона',
                style: TextStyle(
                  fontSize: 16 ,
                  fontWeight: FontWeight.w500,
                  color: AppColors.primary3,
                ),
              ),
              const SizedBox(height: 8),

              TextField(
                controller: _phoneCtrl,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  hintText: '+7 7xx xxx xx xx',
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 14,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: AppColors.success,
                      width: 1,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: AppColors.success,
                      width: 1.2,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              FermerPlusBigButton(
                text: 'Получить код',
                height: 50,
                borderRadius: 6,
                onPressed: () {
                  // пока без бэка - просто идем дальше
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
