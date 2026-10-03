import 'package:flutter/material.dart';
import 'package:frontend/core/localization/l10n_extension.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/core/widgets/app_bottom_nav_bar.dart';
import 'package:frontend/core/widgets/fermer_plus_drawer.dart';
import 'package:go_router/go_router.dart';

/// Persistent frame for the screens that show the bottom navigation.
///
/// The bar and the drawer live here, outside of the page transitions, so
/// switching tabs or opening a section from More replaces only the page body
/// while the bar stays in place.
class AppShell extends StatefulWidget {
  const AppShell({super.key, required this.currentIndex, required this.child});

  final int currentIndex;
  final Widget child;

  /// Tab highlighted for the top route of the shell.
  static int indexForPath(String? path) => switch (path) {
    '/home' => 0,
    '/herd' => 1,
    '/events' => 2,
    '/lactation' => 3,
    // More and the sections opened from it.
    _ => 4,
  };

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  /// True when a section opened inside the shell can be popped back.
  bool _canPopInShell(BuildContext context) {
    final matches = GoRouter.maybeOf(
      context,
    )?.routerDelegate.currentConfiguration.matches;
    final top = matches?.lastOrNull;
    return top is ShellRouteMatch && top.matches.length > 1;
  }

  @override
  Widget build(BuildContext context) {
    final platform = Theme.of(context).platform;
    final hasBackSwipe =
        platform == TargetPlatform.iOS || platform == TargetPlatform.macOS;

    return AppShellScope(
      openDrawer: () => _scaffoldKey.currentState?.openDrawer(),
      child: Scaffold(
        key: _scaffoldKey,
        drawer: FermerPlusDrawer(farmName: context.l10n.farmName),
        // The drawer edge zone sits above the pages; on iOS it would steal
        // the swipe-back gesture from a section opened from More.
        drawerEnableOpenDragGesture: !(hasBackSwipe && _canPopInShell(context)),
        backgroundColor: AppColors.background,
        body: widget.child,
        bottomNavigationBar: AppBottomNavBar(currentIndex: widget.currentIndex),
      ),
    );
  }
}

/// Lets pages inside [AppShell] reach the shell drawer and skip their own
/// bottom bar.
class AppShellScope extends InheritedWidget {
  const AppShellScope({
    super.key,
    required this.openDrawer,
    required super.child,
  });

  final VoidCallback openDrawer;

  static AppShellScope? maybeOf(BuildContext context) =>
      context.getInheritedWidgetOfExactType<AppShellScope>();

  @override
  bool updateShouldNotify(AppShellScope oldWidget) => false;
}
