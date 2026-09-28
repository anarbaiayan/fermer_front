import 'package:flutter/material.dart';
import 'package:frontend/core/localization/l10n_extension.dart';

import '../widgets/finance_common.dart';
import '../widgets/finance_page.dart';

/// Временный экран для маршрутов «Финансов», чьи модули ещё не готовы.
/// Каждый модуль заменяет свою заглушку в `app_router.dart` на настоящий
/// экран.
class FinanceStubScreen extends StatelessWidget {
  const FinanceStubScreen({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return FinancePage(
      title: title,
      children: [FinanceMessageCard(title: context.l10n.financeStubMessage)],
    );
  }
}
