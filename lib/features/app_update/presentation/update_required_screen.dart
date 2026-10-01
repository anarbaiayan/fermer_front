import 'package:flutter/material.dart';
import 'package:frontend/core/localization/l10n_extension.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/widgets/app_logo.dart';
import 'package:frontend/core/widgets/app_primary_button.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../application/app_update_providers.dart';
import '../domain/app_version_policy.dart';

/// Обязательное обновление: вместо приложения — только этот экран. Закрыть
/// его нельзя, единственное действие — открыть страницу в магазине.
class UpdateRequiredScreen extends ConsumerStatefulWidget {
  const UpdateRequiredScreen({super.key, required this.status});

  final AppUpdateStatus status;

  @override
  ConsumerState<UpdateRequiredScreen> createState() =>
      _UpdateRequiredScreenState();
}

class _UpdateRequiredScreenState extends ConsumerState<UpdateRequiredScreen> {
  bool _storeFailed = false;

  Future<void> _openStore() async {
    final url = widget.status.storeUrl;
    final opened =
        url != null &&
        await ref.read(appUpdateLauncherProvider)(Uri.parse(url));
    if (mounted) setState(() => _storeFailed = !opened);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final version = widget.status.installedVersion;

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 32),
                    const AppLogo(height: 40),
                    const SizedBox(height: 48),
                    Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: AppColors.background1,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Icon(
                        Icons.system_update_rounded,
                        size: 36,
                        color: AppColors.primary1,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      l10n.updateRequiredTitle,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary3,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      l10n.updateRequiredText,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 15,
                        height: 1.4,
                        color: AppColors.additional3,
                      ),
                    ),
                    const SizedBox(height: 32),
                    AppPrimaryButton(
                      text: l10n.updateRequiredAction,
                      onPressed: _openStore,
                    ),
                    if (_storeFailed) ...[
                      const SizedBox(height: 12),
                      Text(
                        l10n.updateRequiredStoreError,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.error,
                        ),
                      ),
                    ],
                    if (version != null) ...[
                      const SizedBox(height: 16),
                      Text(
                        l10n.updateRequiredInstalledVersion(version),
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.additional3,
                        ),
                      ),
                    ],
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
