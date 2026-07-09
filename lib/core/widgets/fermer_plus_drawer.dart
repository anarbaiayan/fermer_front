import 'package:flutter/material.dart';
import 'package:frontend/core/icons/app_icons.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/widgets/confirm_dialog.dart';
import 'package:frontend/features/cattle_events/application/planned_events_providers.dart';
import 'package:frontend/features/herd/application/herd_providers.dart';
import 'package:frontend/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../features/auth/application/auth_providers.dart';

class FermerPlusDrawer extends ConsumerWidget {
  final String farmName;
  final String? avatarUrl;

  const FermerPlusDrawer({super.key, required this.farmName, this.avatarUrl});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    return Drawer(
      backgroundColor: Colors.white,
      elevation: 16,
      width: MediaQuery.of(context).size.width * 0.78,
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 18),

            Center(
              child: Column(
                children: [
                  _AvatarCircle(avatarUrl: avatarUrl),
                  const SizedBox(height: 14),
                  Text(
                    '"$farmName"',
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.additional3,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            _DrawerItem(
              icon: 'user',
              text: l10n.drawerProfile,
              onTap: () {
                Navigator.of(context).pop();
                context.push('/profile');
              },
            ),
            _DrawerItem(
              icon: 'settings',
              text: l10n.drawerSettings,
              onTap: () {
                Navigator.of(context).pop();
                context.push('/settings');
              },
            ),
            _DrawerItem(
              icon: 'cart',
              text: l10n.drawerPharmacy,
              onTap: () {
                Navigator.of(context).pop();
                context.push('/pharmacy');
              },
            ),
            _DrawerItem(
              icon: 'questions',
              text: l10n.drawerFaq,
              onTap: () {
                Navigator.of(context).pop();
                context.push('/faq');
              },
            ),
            _DrawerItem(
              icon: 'support',
              text: l10n.drawerSupport,
              onTap: () {
                Navigator.of(context).pop();
                context.push('/support');
              },
            ),
            _DrawerItem(
              icon: 'referal',
              text: l10n.drawerReferral,
              onTap: () {
                Navigator.of(context).pop();
                context.push('/referral');
              },
            ),

            const Spacer(),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
              child: InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () async {
                  final container = ProviderScope.containerOf(
                    context,
                    listen: false,
                  );

                  final router = GoRouter.of(context);

                  final rootNav = Navigator.of(context, rootNavigator: true);
                  final rootCtx = rootNav.context;

                  ref.invalidate(plannedEventsProvider('PENDING'));
                  ref.invalidate(plannedEventsProvider('COMPLETED'));
                  ref.invalidate(cattleListProvider);
                  ref.invalidate(cattleStatisticsProvider);

                  Navigator.of(context).pop();

                  final ok = await showConfirmDialog(
                    context: rootCtx,
                    title: l10n.drawerLogoutConfirm,
                    iconName: 'power_off',
                    iconColor: AppColors.primary1,
                    confirmText: l10n.drawerLogoutButton,
                    cancelText: l10n.dialogCancel,
                  );

                  if (!ok) return;

                  await container
                      .read(authControllerProvider.notifier)
                      .logout();

                  router.go('/login');
                },
                child: Row(
                  children: [
                    AppIcons.svg(
                      'logout',
                      size: 22,
                      color: const Color(0xFFD74B4B),
                    ),
                    const SizedBox(width: 14),
                    Text(
                      l10n.drawerLogout,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFD74B4B),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final String icon;
  final String text;
  final VoidCallback onTap;

  const _DrawerItem({
    required this.icon,
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            AppIcons.svg(icon, size: 22, color: AppColors.primary1),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: AppColors.primary3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AvatarCircle extends StatelessWidget {
  final String? avatarUrl;
  const _AvatarCircle({this.avatarUrl});

  @override
  Widget build(BuildContext context) {
    Widget placeholder() => Container(
      color: const Color(0xFFF2F4F7),
      alignment: Alignment.center,
      child: AppIcons.svg(
        'avatar_placeholder',
        size: 60,
        color: AppColors.primary1,
      ),
    );

    return Container(
      width: 88,
      height: 88,
      decoration: const BoxDecoration(shape: BoxShape.circle),
      clipBehavior: Clip.antiAlias,
      child: avatarUrl == null
          ? placeholder()
          : Image.network(
              avatarUrl!,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => placeholder(),
              loadingBuilder: (context, child, progress) {
                if (progress == null) return child;
                return placeholder();
              },
            ),
    );
  }
}
