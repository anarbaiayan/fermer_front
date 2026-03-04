import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/widgets/app_text_field.dart';
import 'package:frontend/features/auth/presentation/widgets/register_header.dart';
import 'package:frontend/features/herd/presentation/widgets/herd_steps_indicator.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:frontend/l10n/app_localizations.dart';

import 'widgets/register_flow_models.dart';

class RegisterStep1Screen extends HookWidget {
  const RegisterStep1Screen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final firstNameController = useTextEditingController();
    final lastNameController = useTextEditingController();
    final farmNameController = useTextEditingController();

    Future<void> onNextPressed() async {
      final first = firstNameController.text.trim();
      final last = lastNameController.text.trim();
      final farm = farmNameController.text.trim();

      if (first.isEmpty || last.isEmpty || farm.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.registerFillAll)),
        );
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

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Text(
                      l10n.registerSubtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.authSmallText,
                      ),
                    ),

                    const SizedBox(height: 32),
                    const HerdStepsIndicator(currentStep: 1),

                    const SizedBox(height: 32),

                    AppTextField(
                      label: l10n.registerFirstName,
                      hintText: l10n.registerFirstNameHint,
                      controller: firstNameController,
                    ),

                    const SizedBox(height: 16),

                    AppTextField(
                      label: l10n.registerLastName,
                      hintText: l10n.registerLastNameHint,
                      controller: lastNameController,
                    ),

                    const SizedBox(height: 16),

                    AppTextField(
                      label: l10n.registerFarmName,
                      hintText: l10n.registerFarmNameHint,
                      controller: farmNameController,
                    ),

                    const SizedBox(height: 32),

                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.primary1,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                        onPressed: onNextPressed,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              l10n.continueText,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Icon(Icons.arrow_forward_rounded, size: 18),
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
}