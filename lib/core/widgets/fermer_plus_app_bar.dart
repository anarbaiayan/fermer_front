import 'package:flutter/material.dart';
import 'package:frontend/core/icons/app_icons.dart';
import '../theme/app_colors.dart';

class FermerPlusAppBar extends StatelessWidget implements PreferredSizeWidget {
  const FermerPlusAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.primary1,
      elevation: 0,
      centerTitle: true,

      // расстояние между leading и названием
      titleSpacing: 24,

      leadingWidth: 56, // чтобы оставить место под 24px + иконку

      leading: Padding(
        padding: const EdgeInsets.only(left: 24),
        child: IconButton(
          padding: EdgeInsets.zero,
          icon: AppIcons.svg('menu', color: Colors.white),
          onPressed: () {},
        ),
      ),

      title: const Text(
        'FERMER+',
        style: TextStyle(
          fontFamily: 'Montserrat',
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),

      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 24),
          child: IconButton(
            padding: EdgeInsets.zero,
            icon: AppIcons.svg('bell', color: Colors.white),
            onPressed: () {},
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(56);
}

