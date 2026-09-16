import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/profile/presentation/widgets/edit_farm_name_dialog.dart';
import 'package:frontend/l10n/app_localizations.dart';

Future<BuildContext> _pumpScreen(WidgetTester tester) async {
  late BuildContext screenContext;
  await tester.pumpWidget(
    MaterialApp(
      locale: const Locale('ru'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: Builder(
        builder: (context) {
          screenContext = context;
          return const Scaffold(body: SizedBox.shrink());
        },
      ),
    ),
  );
  return screenContext;
}

AppLocalizations _l10n(WidgetTester tester) =>
    AppLocalizations.of(tester.element(find.byType(EditFarmNameDialog)))!;

void main() {
  testWidgets('cancel closes without a value and without exceptions', (
    tester,
  ) async {
    // Клавиатура открыта, пока диалог на экране: при её закрытии меняются
    // viewInsets и поддерево диалога перестраивается во время анимации.
    tester.view.viewInsets = const FakeViewPadding(bottom: 600);
    addTearDown(tester.view.resetViewInsets);

    final screenContext = await _pumpScreen(tester);
    final result = showDialog<String>(
      context: screenContext,
      builder: (_) => const EditFarmNameDialog(initialName: 'ферма'),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text(_l10n(tester).dialogCancel));
    await tester.pump();
    tester.view.viewInsets = FakeViewPadding.zero;
    await tester.pumpAndSettle();

    expect(await result, isNull);
    expect(tester.takeException(), isNull);
    expect(find.byType(EditFarmNameDialog), findsNothing);
  });

  testWidgets('save returns the edited name', (tester) async {
    final screenContext = await _pumpScreen(tester);
    final result = showDialog<String>(
      context: screenContext,
      builder: (_) => const EditFarmNameDialog(initialName: 'ферма'),
    );
    await tester.pumpAndSettle();
    final saveLabel = _l10n(tester).profileSaveButton;

    await tester.enterText(find.byType(TextField), 'новая ферма');
    await tester.tap(find.text(saveLabel));
    await tester.pumpAndSettle();

    expect(await result, 'новая ферма');
    expect(tester.takeException(), isNull);
  });
}
