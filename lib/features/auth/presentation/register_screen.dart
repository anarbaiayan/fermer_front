import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/features/auth/presentation/widgets/register_header.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

import 'widgets/register_flow_models.dart';

class RegisterStep1Screen extends HookWidget {
  const RegisterStep1Screen({super.key});

  @override
  Widget build(BuildContext context) {
    final firstNameController = useTextEditingController();
    final lastNameController = useTextEditingController();
    final farmNameController = useTextEditingController();

    Future<void> onNextPressed() async {
      final first = firstNameController.text.trim();
      final last = lastNameController.text.trim();
      final farm = farmNameController.text.trim();

      if (first.isEmpty || last.isEmpty || farm.isEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Заполните все поля')));
        return;
      }

      final data = RegisterInfo(
        firstName: first,
        lastName: last,
        farmName: farm,
      );

      context.push('/register-step2', extra: data);
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const RegisterHeader(),

              // ----- ВСЁ ОСТАЛЬНОЕ В PADDING -----
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text(
                      'Введите информацию для регистрации',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.authSmallText,
                      ),
                    ),

                    const SizedBox(height: 32),
                    // Имя
                    const Text(
                      'Имя',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: AppColors.primary3,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: firstNameController,
                      decoration: _outlinedInputDecoration('Заполните поле'),
                    ),

                    const SizedBox(height: 16),

                    // Фамилия
                    const Text(
                      'Фамилия',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: AppColors.primary3,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: lastNameController,
                      decoration: _outlinedInputDecoration('Заполните поле'),
                    ),

                    const SizedBox(height: 16),

                    // Название фермы
                    const Text(
                      'Название фермы',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: AppColors.primary3,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: farmNameController,
                      decoration: _outlinedInputDecoration('Заполните поле'),
                    ),

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
                        onPressed: onNextPressed,
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Продолжить',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(width: 6),
                            Icon(Icons.arrow_forward_rounded, size: 18),
                          ],
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
    );
  }

  InputDecoration _outlinedInputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: AppColors.additional1, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: AppColors.primary1, width: 1.5),
      ),
    );
  }
}
