import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/lactation/application/control_milking_providers.dart';
import 'package:frontend/features/lactation/domain/entities/milking_candidate.dart';
import 'package:frontend/features/lactation/presentation/pages/control_milking_values_screen.dart';
import 'package:frontend/l10n/app_localizations.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

List<MilkingCandidate> _cows(int count) => [
  for (var i = 0; i < count; i++)
    MilkingCandidate(
      id: i + 1,
      tagNumber: '0012$i',
      name: 'Бурёнка $i',
      isLactating: true,
      animalGroup: null,
    ),
];

Future<void> _pumpValuesScreen(
  WidgetTester tester, {
  required List<MilkingCandidate> cows,
  List<Override> overrides = const [],
}) async {
  tester.view.physicalSize = const Size(360, 720);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  final container = ProviderContainer(
    overrides: [
      milkingCandidatesProvider.overrideWith((ref) async => cows),
      ...overrides,
    ],
  );
  addTearDown(container.dispose);
  container
      .read(controlMilkingDraftProvider.notifier)
      .selectAll(cows.map((c) => c.id));

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        locale: const Locale('ru'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: const ControlMilkingValuesScreen(),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('milk fields are centred against the cow row and fit 360px', (
    tester,
  ) async {
    final cows = _cows(3);
    await _pumpValuesScreen(tester, cows: cows);
    expect(tester.takeException(), isNull);

    final field = tester.getRect(find.byType(TextField).first);
    final row = tester.getRect(find.byType(TextField).first.hitTestable());
    final name = tester.getRect(find.text(cows.first.name));
    final context = tester.element(find.byType(ControlMilkingValuesScreen));
    final l10n = AppLocalizations.of(context)!;
    final milkHeader = tester.getRect(find.text(l10n.controlMilkingColumnMilk));

    // Поле не должно уезжать вверх относительно блока с кличкой и биркой.
    expect((field.center.dy - name.center.dy).abs(), lessThan(12.0));
    // Колонка "Молоко" стоит ровно над полями ввода.
    expect((milkHeader.center.dx - field.center.dx).abs(), lessThan(1.0));
    // Достаточно крупное, чтобы попадать пальцем и читать значение.
    expect(field.height, greaterThanOrEqualTo(44));
    expect(field.width, greaterThanOrEqualTo(90));
    expect(field.right, lessThanOrEqualTo(360));
    expect(row.right, lessThanOrEqualTo(360));

    // Две строки подряд отстоят ровно на высоту строки — без лишнего воздуха.
    final secondField = tester.getRect(find.byType(TextField).at(1));
    expect(secondField.top - field.top, lessThanOrEqualTo(62.0));
  });

  testWidgets('tag is secondary under the cow name', (tester) async {
    final cows = _cows(2);
    await _pumpValuesScreen(tester, cows: cows);

    final name = tester.getRect(find.text(cows.first.name));
    final tag = tester.getRect(find.text(cows.first.tagNumber));

    // Бирка — вторая строка того же блока, а не отдельная колонка.
    expect(tag.top, greaterThan(name.top));
    expect((tag.left - name.left).abs(), lessThan(1.0));
  });

  testWidgets('filled rows are marked with a check', (tester) async {
    final cows = _cows(3);
    await _pumpValuesScreen(tester, cows: cows);

    expect(find.byIcon(Icons.check), findsNothing);

    await tester.enterText(find.byType(TextField).first, '18.5');
    await tester.pump();

    expect(find.byIcon(Icons.check), findsOneWidget);
  });

  testWidgets('next moves focus to the following cow', (tester) async {
    final cows = _cows(3);
    await _pumpValuesScreen(tester, cows: cows);

    final fields = find.byType(TextField);
    await tester.tap(fields.first);
    await tester.pump();
    await tester.enterText(fields.first, '18.5');
    await tester.testTextInput.receiveAction(TextInputAction.next);
    await tester.pumpAndSettle();

    final second = tester.widget<TextField>(fields.at(1));
    expect(second.focusNode?.hasFocus, isTrue);
  });

  testWidgets('zero litres block saving before any request is sent', (
    tester,
  ) async {
    var duplicateChecks = 0;
    var saves = 0;
    final cows = _cows(3);
    await _pumpValuesScreen(
      tester,
      cows: cows,
      overrides: [
        findControlMilkingDuplicatesProvider.overrideWithValue(({
          required date,
          required milkingTime,
          required cattleIds,
        }) async {
          duplicateChecks++;
          return {};
        }),
        saveControlMilkingProvider.overrideWithValue(({
          required date,
          required milkingTime,
          required entries,
          required duplicateCattleIds,
          required duplicateAction,
        }) async {
          saves++;
          throw StateError('must not be called');
        }),
      ],
    );
    final context = tester.element(find.byType(ControlMilkingValuesScreen));
    final l10n = AppLocalizations.of(context)!;

    final fields = find.byType(TextField);
    await tester.enterText(fields.at(0), '18.5');
    await tester.enterText(fields.at(1), '0');
    await tester.enterText(fields.at(2), '21');
    await tester.tap(find.text(l10n.save));
    await tester.pump();

    // Одна корова с нулём уронила бы весь атомарный пакет — не отправляем.
    expect(find.text(l10n.lactationMilkPositive), findsOneWidget);
    expect(duplicateChecks, 0);
    expect(saves, 0);
    // Ноль остаётся в поле, а не превращается в пустое значение.
    expect(tester.widget<TextField>(fields.at(1)).controller?.text, '0');
  });
}
