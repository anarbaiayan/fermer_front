import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/widgets/app_bottom_nav_bar.dart';
import 'package:frontend/core/widgets/fermer_plus_app_bar.dart';
import 'package:frontend/core/widgets/fermer_plus_drawer.dart';

class AppScaffold extends StatelessWidget {
  final Widget body;
  final int? bottomNavIndex;

  final String farmName;
  final String? avatarUrl;

  final bool enableDrawer;
  final bool showBell;

  final bool showAppBar;
  final Color? backgroundColor;

  final Widget? floatingActionButton;
  final FloatingActionButtonLocation? floatingActionButtonLocation;

  const AppScaffold({
    super.key,
    required this.body,
    this.bottomNavIndex,
    required this.farmName,
    this.avatarUrl,
    this.enableDrawer = true,
    this.showBell = true,
    this.showAppBar = true,
    this.backgroundColor,
    this.floatingActionButton,
    this.floatingActionButtonLocation,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: enableDrawer
          ? FermerPlusDrawer(farmName: farmName, avatarUrl: avatarUrl)
          : null,

      appBar: showAppBar
          ? PreferredSize(
              preferredSize: const Size.fromHeight(56),
              child: Builder(
                builder: (ctx) => FermerPlusAppBar(
                  onMenuTap: enableDrawer
                      ? () => Scaffold.of(ctx).openDrawer()
                      : null,
                  showBell: showBell,
                ),
              ),
            )
          : null,

      bottomNavigationBar: bottomNavIndex == null
          ? null
          : AppBottomNavBar(currentIndex: bottomNavIndex!),

      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,

      backgroundColor: backgroundColor ?? AppColors.background,
      body: body,
    );
  }
}
