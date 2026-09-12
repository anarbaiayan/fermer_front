import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/lactation/application/lactation_providers.dart';
import 'package:frontend/features/lactation/domain/entities/lactation_period_summary.dart';
import 'package:frontend/features/lactation/presentation/pages/lactation_milk_accounting_screen.dart';
import 'package:frontend/l10n/app_localizations.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

void main() {
  for (final language in ['ru', 'kk']) {
    testWidgets('Period summary fits a small screen in $language', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(320, 640);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            lactationPeriodSummaryProvider.overrideWith(
              (ref) async => const LactationPeriodSummary(
                reportedCowCount: 11,
                totalMilkLiters: 330.5,
                milkUsedForCalves: 30,
                unsuitableMilk: 10,
                hasInvalidMilkBalance: true,
              ),
            ),
          ],
          child: MaterialApp(
            locale: Locale(language),
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: const TextScaler.linear(1.5)),
              child: child!,
            ),
            home: const Scaffold(
              body: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: LactationMilkAccountingSection(),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      final context = tester.element(
        find.byType(LactationMilkAccountingSection),
      );
      final l10n = AppLocalizations.of(context)!;
      expect(find.text(l10n.lactationCowReports), findsOneWidget);
      expect(find.text(l10n.lactationCowReportsHint), findsOneWidget);
      expect(find.text(l10n.lactationInvalidBalanceWarning), findsOneWidget);
      expect(find.textContaining('330'), findsOneWidget);
    });
  }
}
