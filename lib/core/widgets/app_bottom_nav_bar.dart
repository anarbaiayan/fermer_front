import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/core/icons/app_icons.dart';
import 'package:frontend/core/theme/app_colors.dart';

class AppBottomNavBar extends StatelessWidget {
  final int currentIndex;

  const AppBottomNavBar({super.key, required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      selectedItemColor: AppColors.primary1,
      unselectedItemColor: AppColors.additional3,
      type: BottomNavigationBarType.fixed,

      onTap: (index) {
        if (index == currentIndex) return;
        switch (index) {
          case 0: context.go('/home'); break;
          case 1: context.go('/herd'); break;
          case 2: context.go('/events'); break;
          case 3: context.go('/reports'); break;
          case 4: context.go('/profile'); break;
        }
      },

      items: [
        BottomNavigationBarItem(
          icon: AppIcons.svg('home', color: AppColors.additional3),
          activeIcon: AppIcons.svg('home', color: AppColors.primary1),
          label: 'Главная',
        ),
        BottomNavigationBarItem(
          icon: AppIcons.svg('cow-bottom', color: AppColors.additional3),
          activeIcon: AppIcons.svg('cow-bottom', color: AppColors.primary1),
          label: 'Стадо',
        ),
        BottomNavigationBarItem(
          icon: AppIcons.svg('events', color: AppColors.additional3),
          activeIcon: AppIcons.svg('events', color: AppColors.primary1),
          label: 'События',
        ),
        BottomNavigationBarItem(
          icon: AppIcons.svg('checklist', color: AppColors.additional3),
          activeIcon: AppIcons.svg('checklist', color: AppColors.primary1),
          label: 'Отчеты',
        ),
        BottomNavigationBarItem(
          icon: AppIcons.svg('user', color: AppColors.additional3),
          activeIcon: AppIcons.svg('user', color: AppColors.primary1),
          label: 'Профиль',
        ),
      ],
    );
  }
}
