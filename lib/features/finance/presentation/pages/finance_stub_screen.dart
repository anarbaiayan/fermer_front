import 'package:flutter/material.dart';
import 'package:frontend/core/localization/l10n_extension.dart';
import 'package:frontend/core/widgets/app_page.dart';
import 'package:frontend/core/widgets/app_scaffold.dart';
import 'package:frontend/core/widgets/page_header.dart';
import 'package:go_router/go_router.dart';

import '../widgets/finance_common.dart';

/// Временный экран для маршрутов «Финансов», чьи модули ещё не готовы.
/// Каждый модуль заменяет свою заглушку в `app_router.dart` на настоящий
/// экран. Как и формы, открывается без нижнего бара.
class FinanceStubScreen extends StatelessWidget {
  const FinanceStubScreen({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AppScaffold(
      enableDrawer: false,
      showBell: false,
      farmName: l10n.farmName,
      body: AppPage(
        child: ListView(
          padding: const EdgeInsets.only(top: 16, bottom: 24),
          children: [
            HerdPageHeader(
              title: title,
              onBack: () =>
                  context.canPop() ? context.pop() : context.go('/finance'),
            ),
            const SizedBox(height: 24),
            FinanceMessageCard(title: l10n.financeStubMessage),
          ],
        ),
      ),
    );
  }
}
