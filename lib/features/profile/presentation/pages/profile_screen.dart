import 'package:flutter/material.dart';
import 'package:frontend/core/icons/app_icons.dart';
import 'package:frontend/core/localization/l10n_extension.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/widgets/app_button.dart';
import 'package:frontend/core/widgets/app_scaffold.dart';
import 'package:frontend/core/widgets/app_success_dialog.dart';
import 'package:frontend/core/widgets/confirm_dialog.dart';
import 'package:frontend/features/auth/application/auth_providers.dart';
import 'package:frontend/features/auth/presentation/auth_error_localizer.dart';
import 'package:frontend/features/cattle_events/application/planned_events_providers.dart';
import 'package:frontend/features/herd/application/herd_providers.dart';
import 'package:frontend/features/herd/presentation/widgets/herd_small_action_card.dart';
import 'package:frontend/features/notifications/application/notifications_providers.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  Future<void> _handleDeleteAccount(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;

    final ok = await showConfirmDialog(
      context: context,
      title: l10n.profileDeleteAccountConfirm,
      iconName: 'power_off',
      iconColor: AppColors.primary1,
      confirmText: l10n.profileDeleteAccountButton,
      cancelText: l10n.dialogCancel,
    );

    if (!ok || !context.mounted) return;

    await ref.read(authControllerProvider.notifier).deleteAccount();

    if (!context.mounted) return;

    final state = ref.read(authControllerProvider);
    if (state.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(localizeAuthError(context, state.error!))),
      );
      return;
    }

    ref.invalidate(plannedEventsProvider('PENDING'));
    ref.invalidate(plannedEventsProvider('COMPLETED'));
    ref.invalidate(cattleListProvider);
    ref.invalidate(cattleStatisticsProvider);
    ref.invalidate(unreadNotificationsCountProvider);
    ref.invalidate(notificationsFeedProvider(false));
    ref.invalidate(notificationsFeedProvider(true));

    await showAppSuccessDialog(
      context,
      title: l10n.profileDeleteAccountSuccessTitle,
      message: l10n.profileDeleteAccountSuccessMessage,
      buttonText: l10n.restoreAccountGoLogin,
      iconAsset: 'assets/icons/user-success.svg',
      iconWidth: 111,
      iconHeight: 111,
    );

    if (!context.mounted) return;
    context.go('/login');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final farmName = l10n.farmName;
    const phone = '+7 709 851 31 21';
    const String? email = null;

    final headerColor = const Color(0xFFB7E4C7);

    return AppScaffold(
      farmName: farmName,
      body: SafeArea(
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(10)),
          child: Container(
            color: const Color(0xFFF7F5EF),
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            IconButton(
                              padding: EdgeInsets.zero,
                              icon: AppIcons.svg('arrow', size: 32),
                              onPressed: () => context.pop(),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                l10n.profileMyTitle,
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary3,
                                ),
                              ),
                            ),
                            const SizedBox(width: 48),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              width: 1,
                              color: AppColors.additional2,
                            ),
                            boxShadow: const [
                              BoxShadow(
                                color: Color.fromRGBO(0, 0, 0, 0.04),
                                blurRadius: 8,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                height: 90,
                                decoration: BoxDecoration(
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(10),
                                  ),
                                  gradient: LinearGradient(
                                    colors: [
                                      headerColor.withValues(alpha: 0.35),
                                      Colors.white,
                                    ],
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                  ),
                                ),
                              ),
                              const Divider(
                                height: 0.5,
                                color: AppColors.additional2,
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 12,
                                ),
                                child: Container(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  decoration: const BoxDecoration(
                                    border: Border(
                                      bottom: BorderSide(
                                        color: AppColors.additional2,
                                        width: 1,
                                      ),
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        alignment: Alignment.center,
                                        child: AppIcons.svg('info', size: 34),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Text(
                                          l10n.animalMainInfo,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.primary3,
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        padding: EdgeInsets.zero,
                                        icon: AppIcons.svg('edit', size: 30),
                                        onPressed: () {},
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                child: Column(
                                  children: [
                                    _InfoRow(
                                      label: l10n.loginPhoneLabel,
                                      value: phone,
                                    ),
                                    const SizedBox(height: 8),
                                    _InfoRow(
                                      label: l10n.profileFarmLabel,
                                      value: '"$farmName"',
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 12,
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: SmallActionCard(
                                        title: l10n.profileResetPasswordTitle,
                                        subtitle: l10n.profileResetPasswordHint,
                                        icon: AppIcons.svg(
                                          'reset_password',
                                          size: 26,
                                        ),
                                        onTap: () {},
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: SmallActionCard(
                                        title: l10n.profileEmailTitle,
                                        subtitle:
                                            email ?? l10n.profileEmailAddHint,
                                        icon: AppIcons.svg('email', size: 26),
                                        onTap: () {},
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12),
                              Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  12,
                                  0,
                                  12,
                                  16,
                                ),
                                child: SizedBox(
                                  width: double.infinity,
                                  height: 48,
                                  child: OutlinedButton(
                                    style: OutlinedButton.styleFrom(
                                      side: const BorderSide(
                                        color: Color(0xFFD74B4B),
                                        width: 1.2,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      backgroundColor: Colors.transparent,
                                    ),
                                    onPressed: () =>
                                        _handleDeleteAccount(context, ref),
                                    child: Text(
                                      l10n.profileDeleteAccountButton,
                                      style: const TextStyle(
                                        color: Color(0xFFD74B4B),
                                        fontWeight: FontWeight.w700,
                                        fontSize: 15,
                                      ),
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
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: FermerPlusBigButton(
                    text: l10n.dialogClose,
                    height: 50,
                    borderRadius: 5,
                    onPressed: () => context.pop(),
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

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 160,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: AppColors.primary3,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: AppColors.primary3,
            ),
          ),
        ),
      ],
    );
  }
}
