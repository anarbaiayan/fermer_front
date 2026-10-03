import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/core/network/api_exceptions.dart';
import 'package:frontend/core/router/app_router.dart';
import 'package:frontend/features/finance/application/finance_providers.dart';
import 'package:frontend/features/finance/application/finance_report.dart';
import 'package:frontend/features/finance/data/mock/mock_finance_repository.dart';
import 'package:frontend/features/finance/domain/entities/finance_date.dart';
import 'package:frontend/features/finance/domain/entities/finance_entities.dart';
import 'package:frontend/features/finance/domain/entities/finance_enums.dart';
import 'package:frontend/features/finance/domain/entities/finance_inputs.dart';
import 'package:frontend/features/finance/presentation/pages/finance_report_ready_screen.dart';
import 'package:frontend/features/finance/presentation/tabs/finance_report_tab.dart';
import 'package:frontend/features/finance/presentation/widgets/finance_chips.dart';
import 'package:frontend/features/notifications/application/notifications_providers.dart';
import 'package:frontend/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final _l10n = lookupAppLocalizations(const Locale('ru'));
final _nbsp = String.fromCharCode(0x00A0);

String _money(String digits) => '${digits.replaceAll(' ', _nbsp)}$_nbsp₸';

final _today = DateTime.utc(2026, 9, 19);

MockFinanceRepository _repo() => MockFinanceRepository(
  clock: () => DateTime(2026, 9, 19, 12),
  latency: Duration.zero,
);

class _FailingReportRepository extends MockFinanceRepository {
  _FailingReportRepository()
    : super(clock: () => DateTime(2026, 9, 19, 12), latency: Duration.zero);

  @override
  Future<FinanceReportFile> getReportPdf(FinanceReportRequest request) async =>
      throw ApiException('Отчёт временно недоступен', 503);
}

Future<void> _pump(
  WidgetTester tester,
  MockFinanceRepository repo, {
  String location = '/finance?tab=report',
  List<FinanceReportDocument>? shared,
}) async {
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);

  final directory = Directory.systemTemp.createTempSync('finance_report_');
  addTearDown(() => directory.deleteSync(recursive: true));
  final router = GoRouter(
    initialLocation: location,
    routes: appRouter.configuration.routes,
  );
  addTearDown(router.dispose);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        financeRepositoryProvider.overrideWithValue(repo),
        financeClockProvider.overrideWithValue(() => DateTime(2026, 9, 19, 12)),
        unreadNotificationsCountProvider.overrideWith((ref) async => 0),
        financeReportDirectoryProvider.overrideWithValue(() async => directory),
        financeShareFileProvider.overrideWithValue(
          (document, origin) async => shared?.add(document),
        ),
      ],
      child: MaterialApp.router(
        routerConfig: router,
        locale: const Locale('ru'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
      ),
    ),
  );
  await tester.pumpAndSettle();
}

final _page = find
    .byWidgetPredicate(
      (widget) =>
          widget is Scrollable && widget.axisDirection == AxisDirection.down,
    )
    .first;

Future<void> _tap(WidgetTester tester, Finder finder) async {
  if (finder.evaluate().isEmpty) {
    // Сначала к началу страницы, потом вниз.
    await tester.drag(_page, const Offset(0, 3000));
    await tester.pumpAndSettle();
  }
  if (finder.evaluate().isEmpty) {
    await tester.scrollUntilVisible(finder, 200, scrollable: _page);
  }
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

/// Карточка «В документ попадут» ниже экрана — прокручиваем к ней.
Future<void> _showContents(WidgetTester tester) async {
  final card = find.text(_l10n.financeReportOperations);
  if (card.evaluate().isEmpty) {
    await tester.scrollUntilVisible(card, 200, scrollable: _page);
  }
  await tester.pumpAndSettle();
}

/// Строка «ключ — значение» в карточке «В документ попадут».
Finder _row(String key, String value) => find.ancestor(
  of: find.text(key),
  matching: find.byWidgetPredicate(
    (widget) =>
        widget is Row &&
        widget.children.any(
          (child) =>
              child is Expanded &&
              child.child is Text &&
              (child.child as Text).data == value,
        ),
  ),
);

void main() {
  group('period', () {
    FinancePeriod resolve(
      FinanceReportPeriodKind kind, {
      DateTime? today,
      DateTime? from,
      DateTime? to,
    }) => FinanceReportPeriodChoice(
      kind,
      from: from,
      to: to,
    ).resolve(today ?? _today);

    test('months and the quarter', () {
      expect(
        resolve(FinanceReportPeriodKind.thisMonth),
        FinancePeriod(DateTime.utc(2026, 9, 1), DateTime.utc(2026, 9, 30)),
      );
      expect(
        resolve(
          FinanceReportPeriodKind.lastMonth,
          today: DateTime.utc(2026, 1, 10),
        ),
        FinancePeriod(DateTime.utc(2025, 12, 1), DateTime.utc(2025, 12, 31)),
      );
      expect(
        resolve(FinanceReportPeriodKind.quarter),
        FinancePeriod(DateTime.utc(2026, 7, 1), DateTime.utc(2026, 9, 30)),
      );
      expect(
        resolve(
          FinanceReportPeriodKind.quarter,
          today: DateTime.utc(2026, 11, 2),
        ),
        FinancePeriod(DateTime.utc(2026, 10, 1), DateTime.utc(2026, 12, 31)),
      );
    });

    test('own period: from the month start to today by default', () {
      expect(
        resolve(FinanceReportPeriodKind.custom),
        FinancePeriod(DateTime.utc(2026, 9, 1), _today),
      );
      expect(
        resolve(
          FinanceReportPeriodKind.custom,
          from: DateTime.utc(2026, 8, 15),
          to: DateTime.utc(2026, 9, 10),
        ),
        FinancePeriod(DateTime.utc(2026, 8, 15), DateTime.utc(2026, 9, 10)),
      );
    });
  });

  test('file names are safe for any phone', () {
    expect(
      safeReportFileName('Финансы_КХ «Акбулак»_сентябрь_2026'),
      'Финансы_КХ_Акбулак_сентябрь_2026.pdf',
    );
    expect(safeReportFileName('a/b:c*.pdf'), 'abc.pdf');
    expect(safeReportFileName('  '), 'report.pdf');
  });

  test('the mock returns a valid one-page PDF', () async {
    final file = await _repo().getReportPdf(
      FinanceReportRequest(
        period: FinancePeriod.month(_today),
        type: FinanceReportType.full,
      ),
    );
    final text = latin1.decode(file.bytes);
    expect(text, startsWith('%PDF-1.4'));
    expect(text, contains('Income: 666400 KZT'));
    expect(text.trimRight(), endsWith('%%EOF'));
    // Таблица xref указывает точно на начало объектов.
    final xref = int.parse(
      RegExp(r'startxref\n(\d+)').firstMatch(text)!.group(1)!,
    );
    expect(text.substring(xref), startsWith('xref'));
    final offsets = RegExp(
      r'(\d{10}) 00000 n',
    ).allMatches(text).map((m) => int.parse(m.group(1)!)).toList();
    for (var i = 0; i < offsets.length; i++) {
      expect(text.substring(offsets[i]), startsWith('${i + 1} 0 obj'));
    }
  });

  group('report tab', () {
    testWidgets('shows what goes into the document', (tester) async {
      await _pump(tester, _repo());

      expect(find.byType(FinanceReportTab), findsOneWidget);
      expect(find.text('01.09.2026 — 30.09.2026'), findsWidgets);
      await _showContents(tester);
      expect(_row(_l10n.financeTabIncome, _money('666 400')), findsOneWidget);
      expect(_row(_l10n.financeTabExpense, _money('593 500')), findsOneWidget);
      expect(_row(_l10n.financeProfit, _money('72 900')), findsOneWidget);
      expect(_row(_l10n.financeReportOperations, '17'), findsOneWidget);

      await _tap(tester, find.text(_l10n.financeDebtsTitle));
      expect(_row(_l10n.financeDebtsTitle, _money('378 000')), findsOneWidget);
      expect(_row(_l10n.financeReportOperations, '4'), findsOneWidget);
      expect(find.text(_l10n.financeProfit), findsNothing);

      await _tap(
        tester,
        find.widgetWithText(FinanceChip, _l10n.financeReportLastMonth),
      );
      expect(find.text('01.08.2026 — 31.08.2026'), findsWidgets);
    });

    testWidgets('own period picks its dates', (tester) async {
      await _pump(tester, _repo());
      await _tap(
        tester,
        find.widgetWithText(FinanceChip, _l10n.financeReportCustom),
      );
      expect(find.text(_l10n.financeReportFrom), findsOneWidget);
      expect(find.text(_l10n.financeReportTo), findsOneWidget);
      await _showContents(tester);
      expect(find.text('01.09.2026 — 19.09.2026'), findsOneWidget);
    });

    testWidgets('makes the PDF and sends it', (tester) async {
      final shared = <FinanceReportDocument>[];
      await _pump(tester, _repo(), shared: shared);

      await _tap(tester, find.text(_l10n.financeReportMake));
      expect(find.byType(FinanceReportReadyScreen), findsOneWidget);
      expect(find.text('Финансы_сентябрь_2026.pdf'), findsOneWidget);
      expect(find.textContaining(_l10n.financeReportFull), findsWidgets);

      await _tap(tester, find.text(_l10n.financeReportShare));
      final document = shared.single;
      expect(document.fileName, 'Финансы_сентябрь_2026.pdf');
      expect(document.request.type, FinanceReportType.full);
      final bytes = File(document.path).readAsBytesSync();
      expect(latin1.decode(bytes.sublist(0, 8)), '%PDF-1.4');
      expect(document.sizeBytes, bytes.length);
    });

    testWidgets('a backend error stays on the tab', (tester) async {
      await _pump(tester, _FailingReportRepository());
      await _tap(tester, find.text(_l10n.financeReportMake));
      expect(find.byType(FinanceReportReadyScreen), findsNothing);
      expect(find.text('Отчёт временно недоступен'), findsOneWidget);
    });

    testWidgets('the ready screen without a document offers a new one', (
      tester,
    ) async {
      await _pump(tester, _repo(), location: '/finance/report/ready');
      expect(find.text(_l10n.financeReportMissing), findsOneWidget);
      await _tap(tester, find.text(_l10n.financeReportMake));
      expect(find.byType(FinanceReportTab), findsOneWidget);
    });

    testWidgets('selection survives a trip to another tab', (tester) async {
      await _pump(tester, _repo());
      await _tap(tester, find.text(_l10n.financeReportExpense));
      await _tap(tester, find.text(_l10n.financeTabSummary));
      await _tap(tester, find.text(_l10n.financeTabReport));
      await _showContents(tester);
      expect(find.text(_l10n.financeProfit), findsNothing);
      expect(_row(_l10n.financeReportOperations, '8'), findsOneWidget);
    });
  });
}
