import 'package:flutter/material.dart';
import 'package:frontend/core/icons/app_icons.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/features/notifications/application/notifications_providers.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class FermerPlusAppBar extends ConsumerWidget implements PreferredSizeWidget {
  final VoidCallback? onMenuTap;
  final bool showBell;

  const FermerPlusAppBar({super.key, this.onMenuTap, this.showBell = true});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unreadAsync = showBell
        ? ref.watch(unreadNotificationsCountProvider)
        : const AsyncValue<int>.data(0);
    final unreadCount = unreadAsync.valueOrNull ?? 0;
    final badgeText = unreadCount > 99 ? '99+' : unreadCount.toString();

    return AppBar(
      backgroundColor: AppColors.primary1,
      elevation: 0,
      centerTitle: true,
      titleSpacing: 24,
      leadingWidth: 56,
      leading: Padding(
        padding: const EdgeInsets.only(left: 24),
        child: IconButton(
          padding: EdgeInsets.zero,
          icon: AppIcons.svg('menu', color: Colors.white),
          onPressed: () {
            onMenuTap?.call();
          },
        ),
      ),
      title: Image.asset(
        'assets/icons/logo_white.png',
        height: 28,
        fit: BoxFit.contain,
      ),
      actions: [
        if (showBell)
          Padding(
            padding: const EdgeInsets.only(right: 24),
            child: IconButton(
              padding: EdgeInsets.zero,
              onPressed: () => context.push('/notifications'),
              icon: Stack(
                clipBehavior: Clip.none,
                children: [
                  AppIcons.svg('bell', color: Colors.white),
                  if (unreadCount > 0)
                    Positioned(
                      right: -7,
                      top: -6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 1,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          badgeText,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          )
        else
          const SizedBox(width: 24),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(56);
}
