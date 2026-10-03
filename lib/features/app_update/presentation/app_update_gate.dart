import 'package:flutter/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../application/app_update_providers.dart';
import 'update_required_screen.dart';

/// Стоит над всеми маршрутами (`MaterialApp.builder`): пока сборка
/// устарела, вместо приложения — экран обновления. Ни ссылка, ни пуш, ни
/// кнопка «Назад» его не обходят.
class AppUpdateGate extends ConsumerWidget {
  const AppUpdateGate({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(appUpdateProvider);
    if (!status.updateRequired) return child;
    return UpdateRequiredScreen(status: status);
  }
}
