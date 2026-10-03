import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/core/network/api_exceptions.dart';
import 'package:frontend/core/router/app_router.dart';
import 'package:frontend/features/finance/application/finance_providers.dart';
import 'package:frontend/features/finance/data/mock/mock_finance_repository.dart';
import 'package:frontend/features/finance/domain/entities/finance_entities.dart';
import 'package:frontend/features/finance/domain/entities/finance_inputs.dart';
import 'package:frontend/features/finance/domain/entities/money.dart';
import 'package:frontend/features/finance/presentation/finance_contact.dart';
import 'package:frontend/features/notifications/application/notifications_providers.dart';
import 'package:frontend/features/notifications/domain/entities/app_notification.dart';
import 'package:frontend/features/notifications/domain/entities/notification_status.dart';
import 'package:frontend/features/notifications/domain/entities/notification_type.dart';
import 'package:frontend/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final _l10n = lookupAppLocalizations(const Locale('ru'));
final _nbsp = String.fromCharCode(0x00A0);

String _money(String digits) => '${digits.replaceAll(' ', _nbsp)}$_nbsp₸';

MockFinanceRepository _repo({bool demo = true}) => MockFinanceRepository(
  clock: () => DateTime(2026, 9, 19, 12),
  latency: Duration.zero,
  withDemoData: demo,
);

class _NoSalesRepository extends MockFinanceRepository {
  _NoSalesRepository()
    : super(clock: () => DateTime(2026, 9, 19, 12), latency: Duration.zero);

  @override
  Future<List<Sale>> getSales(SaleFilter filter) async =>
      throw ApiException('Server error', 500);
}

class _NoDebtsRepository extends MockFinanceRepository {
  _NoDebtsRepository()
    : super(clock: () => DateTime(2026, 9, 19, 12), latency: Duration.zero);

  @override
  Future<List<CounterpartyDebt>> getDebts() async =>
      throw ApiException('Not Found', 404);
}

Future<void> _pump(
  WidgetTester tester,
  MockFinanceRepository repo, {
  String location = '/finance/debts',
  Future<bool> Function(Uri)? launcher,
}) async {
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 3;
  addTearDown(tester.view.reset);

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
        financeUrlLauncherProvider.overrideWithValue(
          launcher ?? (uri) async => true,
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
    await tester.scrollUntilVisible(finder, 200, scrollable: _page);
  }
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

Finder _total(String label, String digits) => find.ancestor(
  of: find.text(label),
  matching: find.byWidgetPredicate(
    (widget) =>
        widget is Column &&
        find
            .descendant(
              of: find.byWidget(widget),
              matching: find.text(_money(digits)),
            )
            .evaluate()
            .isNotEmpty,
  ),
);

AppNotification _notification(NotificationType type, {int? buyer, int? cow}) =>
    AppNotification(
      id: 1,
      type: type,
      status: NotificationStatus.sent,
      rawType: '',
      rawStatus: '',
      title: '',
      message: '',
      notificationDate: null,
      readAt: null,
      archived: false,
      cattleInfo: cow == null ? null : NotificationCattleInfo(cattleId: cow),
      counterpartyId: buyer,
    );

void main() {
  testWidgets('totals and buyers, the most overdue first', (tester) async {
    await _pump(tester, _repo());

    expect(find.text(_l10n.financeDebtsTitle), findsOneWidget);
    expect(_total(_l10n.financeDebtsTotal, '378 000'), findsWidgets);
    expect(_total(_l10n.financeIncomeFilterOverdue, '172 000'), findsWidgets);

    final zhailau = tester.getTopLeft(find.text('Кафе «Жайлау»')).dy;
    final bereke = tester.getTopLeft(find.text('Магазин Береке')).dy;
    final saule = tester.getTopLeft(find.text('ИП Сауле, молочный отдел')).dy;
    expect(zhailau, lessThan(bereke));
    expect(bereke, lessThan(saule));

    // Первый покупатель раскрыт; телефона нет — и кнопок связи нет.
    expect(find.text('20.08 · Сметана, 15 кг'), findsOneWidget);
    expect(find.text(_l10n.financeSaleDueWas('03.09')), findsOneWidget);
    expect(find.text(_l10n.financeNoPhoneFull), findsOneWidget);
    expect(find.text(_l10n.financeCall), findsNothing);
    expect(find.text(_l10n.financeSaleStatusOverdue(16)), findsOneWidget);
    expect(find.text(_l10n.financeDueUntilPill('29.09')), findsOneWidget);
  });

  testWidgets('a buyer opens to pay one of the sales', (tester) async {
    final repo = _repo();
    await _pump(tester, repo);

    await _tap(tester, find.text('Магазин Береке'));
    expect(find.text('+7 (701) 234-56-78'), findsOneWidget);
    expect(find.text('01.09 · Молоко, 580 л'), findsOneWidget);
    expect(find.text(_l10n.financeSaleDueWas('13.09')), findsOneWidget);
    expect(find.text('10.09 · Молоко, 560 л'), findsOneWidget);
    expect(find.text(_l10n.financeSalePayUntil('24.09')), findsOneWidget);

    final getFirst = find.descendant(
      of: find
          .ancestor(
            of: find.text('01.09 · Молоко, 580 л'),
            matching: find.byType(Row),
          )
          .first,
      matching: find.text(_l10n.financeGetPaymentShort),
    );
    await _tap(tester, getFirst);
    expect(
      find.text('Магазин Береке · Молоко, 580 л · продажа 01.09.2026'),
      findsOneWidget,
    );
    await _tap(tester, find.text(_l10n.financePayConfirm));

    expect(
      find.text(_l10n.financePaymentReceived(_money('145 000'), 'Касса')),
      findsOneWidget,
    );
    expect(find.text('01.09 · Молоко, 580 л'), findsNothing);
    expect(_total(_l10n.financeIncomeFilterOverdue, '27 000'), findsWidgets);
    final debts = await repo.getDebts();
    expect(
      debts.firstWhere((d) => d.counterpartyId == 5).totalDebt,
      Money.tenge(140000),
    );
  });

  testWidgets('call and remind open the phone and WhatsApp', (tester) async {
    final opened = <Uri>[];
    await _pump(
      tester,
      _repo(),
      launcher: (uri) async {
        opened.add(uri);
        return true;
      },
    );

    await _tap(tester, find.text('Магазин Береке'));
    await _tap(tester, find.text(_l10n.financeCall));
    expect(opened.single.toString(), 'tel:+77012345678');

    await _tap(tester, find.text(_l10n.financeRemind));
    final whatsApp = opened.last;
    expect(whatsApp.scheme, 'whatsapp');
    expect(whatsApp.queryParameters['phone'], '77012345678');
    expect(
      whatsApp.queryParameters['text'],
      _l10n.financeDebtReminderText(_money('285 000')),
    );
  });

  testWidgets('says so when the phone app does not open', (tester) async {
    await _pump(tester, _repo(), launcher: (uri) async => false);

    await _tap(tester, find.text('Магазин Береке'));
    await _tap(tester, find.text(_l10n.financeCall));
    expect(find.text(_l10n.financeCallError), findsOneWidget);
  });

  testWidgets('the overdue push opens its buyer', (tester) async {
    await _pump(tester, _repo(), location: '/finance/debts?counterpartyId=7');

    expect(find.text('15.09 · Творог, 30 кг'), findsOneWidget);
    expect(find.text('20.08 · Сметана, 15 кг'), findsNothing);
  });

  testWidgets('no debts', (tester) async {
    await _pump(tester, _repo(demo: false));
    expect(find.text(_l10n.financeNoDebtsTitle), findsOneWidget);
    expect(find.text(_l10n.financeNoDebtsText), findsOneWidget);
  });

  testWidgets('an error offers a retry', (tester) async {
    await _pump(tester, _NoDebtsRepository());
    expect(find.text(_l10n.financeLoadError), findsOneWidget);
    expect(find.text(_l10n.financeRetry), findsOneWidget);
  });

  testWidgets('works without product details from sales', (tester) async {
    await _pump(tester, _NoSalesRepository());
    // Товар и количество берутся из продаж; без них — дата и «Продажа».
    expect(find.text('20.08 · ${_l10n.financeSaleTitle}'), findsOneWidget);
  });

  group('notification', () {
    test('overdue debt leads to debts with the buyer', () {
      expect(
        _notification(NotificationType.financeOverdue, buyer: 5).target,
        '/finance/debts?counterpartyId=5',
      );
      expect(
        _notification(NotificationType.financeOverdue).target,
        '/finance/debts',
      );
      expect(
        _notification(NotificationType.reminder, cow: 42).target,
        '/herd/42',
      );
      expect(_notification(NotificationType.info).target, isNull);
      expect(
        NotificationTypeX.fromApi('FINANCE_OVERDUE'),
        NotificationType.financeOverdue,
      );
    });
  });
}
