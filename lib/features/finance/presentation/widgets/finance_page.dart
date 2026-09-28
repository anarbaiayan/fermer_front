import 'package:flutter/material.dart';
import 'package:frontend/core/localization/l10n_extension.dart';
import 'package:frontend/core/widgets/app_page.dart';
import 'package:frontend/core/widgets/app_scaffold.dart';
import 'package:frontend/core/widgets/page_header.dart';
import 'package:go_router/go_router.dart';

/// Экран «Финансов» вне оболочки — форма, справочник, долги: шапка без
/// меню и колокольчика, заголовок со стрелкой назад, без нижнего бара.
class FinancePage extends StatelessWidget {
  const FinancePage({
    super.key,
    required this.title,
    required this.children,
    this.spacing = 22,
  });

  final String title;
  final List<Widget> children;

  /// Отступ между блоками, как между полями формы в прототипе.
  final double spacing;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      enableDrawer: false,
      showBell: false,
      farmName: context.l10n.farmName,
      body: AppPage(
        child: ListView(
          padding: const EdgeInsets.only(top: 16, bottom: 40),
          children: [
            HerdPageHeader(
              title: title,
              maxLines: 2,
              onBack: () => closeFinancePage(context),
            ),
            const SizedBox(height: 16),
            for (var i = 0; i < children.length; i++) ...[
              if (i > 0) SizedBox(height: spacing),
              children[i],
            ],
          ],
        ),
      ),
    );
  }
}

/// Сообщение после сохранения.
///
/// [aboveFab] — для форм, которые возвращают к списку с плавающей кнопкой.
/// Снекбар показывает корневой Scaffold оболочки, и кнопка страницы под
/// ним не поднимается; поднимаем сообщение, чтобы «+ Расход» можно было
/// нажать сразу. На остальных экранах так оно закрыло бы их кнопки.
void showFinanceMessage(
  ScaffoldMessengerState messenger,
  String text, {
  bool aboveFab = false,
}) {
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        content: Text(text),
        behavior: aboveFab ? SnackBarBehavior.floating : null,
        margin: aboveFab ? const EdgeInsets.fromLTRB(16, 0, 16, 84) : null,
      ),
    );
}

/// Назад по стеку, а если экран открыт по ссылке — в раздел. Вход в
/// оболочку только через `go`, иначе появится вторая копия оболочки.
void closeFinancePage<T>(BuildContext context, [T? result]) {
  if (context.canPop()) {
    context.pop(result);
  } else {
    context.go('/finance');
  }
}
