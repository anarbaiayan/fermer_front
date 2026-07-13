import 'package:flutter/material.dart';
import 'package:frontend/core/icons/app_icons.dart';
import 'package:frontend/core/localization/l10n_extension.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:go_router/go_router.dart';

class AppBottomNavBar extends StatelessWidget {
  final int currentIndex;

  const AppBottomNavBar({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return BottomNavigationBar(
      currentIndex: currentIndex,
      selectedItemColor: AppColors.primary1,
      unselectedItemColor: AppColors.additional3,
      type: BottomNavigationBarType.fixed,
      onTap: (index) {
        if (index == currentIndex) return;
        switch (index) {
          case 0:
            context.go('/home');
            break;
          case 1:
            context.go('/herd');
            break;
          case 2:
            context.go('/events');
            break;
          case 3:
            context.go('/lactation');
            break;
          case 4:
            context.go('/more');
            break;
        }
      },
      items: [
        BottomNavigationBarItem(
          icon: AppIcons.svg('home', color: AppColors.additional3),
          activeIcon: AppIcons.svg('home', color: AppColors.primary1),
          label: l10n.navHome,
        ),
        BottomNavigationBarItem(
          icon: AppIcons.svg('cow-bottom', color: AppColors.additional3),
          activeIcon: AppIcons.svg('cow-bottom', color: AppColors.primary1),
          label: l10n.navHerd,
        ),
        BottomNavigationBarItem(
          icon: AppIcons.svg('events', color: AppColors.additional3),
          activeIcon: AppIcons.svg('events', color: AppColors.primary1),
          label: l10n.navEvents,
        ),
        BottomNavigationBarItem(
          icon: AppIcons.svg('lactation', color: AppColors.additional3),
          activeIcon: AppIcons.svg('lactation', color: AppColors.primary1),
          label: l10n.navLactation,
        ),
        BottomNavigationBarItem(
          icon: AppIcons.svg('actions', color: AppColors.additional3),
          activeIcon: AppIcons.svg('actions', color: AppColors.primary1),
          label: l10n.navMore,
        ),
      ],
    );
  }
}
