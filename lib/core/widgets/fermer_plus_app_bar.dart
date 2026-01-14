import 'package:flutter/material.dart';
import 'package:frontend/core/icons/app_icons.dart';
import '../theme/app_colors.dart';

class FermerPlusAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback? onMenuTap;
  final bool showBell;

  const FermerPlusAppBar({super.key, this.onMenuTap, this.showBell = true});

  @override
  Widget build(BuildContext context) {
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
        if (showBell)
          Padding(
            padding: const EdgeInsets.only(right: 24),
            child: IconButton(
              padding: EdgeInsets.zero,
              icon: AppIcons.svg('bell', color: Colors.white),
              onPressed: () {},
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
