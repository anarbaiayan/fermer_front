import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/core/router/app_router.dart';
import 'package:frontend/features/finance/application/finance_providers.dart';
import 'package:frontend/features/finance/data/mock/mock_finance_repository.dart';
import 'package:frontend/features/finance/domain/entities/finance_enums.dart';
import 'package:frontend/features/finance/domain/entities/money.dart';
import 'package:frontend/features/finance/presentation/finance_phone.dart';
import 'package:frontend/features/finance/presentation/pages/finance_account_form_screen.dart';
import 'package:frontend/features/finance/presentation/pages/finance_settings_screen.dart';
import 'package:frontend/features/finance/presentation/widgets/finance_onboarding.dart';
import 'package:frontend/features/notifications/application/notifications_providers.dart';
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

/// Настоящие маршруты приложения, начиная с [location].
Future<GoRouter> _pump(
  WidgetTester tester,
  String location,
  MockFinanceRepository repo,
) async {
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
  return router;
}

Finder _field(int index) => find.byType(TextField).at(index);

final _page = find
    .byWidgetPredicate(
      (widget) =>
          widget is Scrollable && widget.axisDirection == AxisDirection.down,
    )
    .first;

/// Докручивает ленивый список до [finder] и нажимает.
Future<void> _tap(WidgetTester tester, Finder finder) async {
  if (finder.evaluate().isEmpty) {
    await tester.scrollUntilVisible(finder, 200, scrollable: _page);
  }
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

void main() {
  group('first entry', () {
    testWidgets('asks for real balances and creates the accounts', (
      tester,
    ) async {
      final repo = _repo(demo: false);
      await _pump(tester, '/finance', repo);

      expect(find.text(_l10n.financeOnboardingTitle), findsOneWidget);
      expect(find.text(_l10n.financeTabSummary), findsNothing);
      expect(find.byTooltip(_l10n.financeSettingsTitle), findsNothing);

      await _tap(tester, find.text(_l10n.financeOnboardingStart));
      expect(find.text(_l10n.financeOnboardingEmptyError), findsOneWidget);

      await tester.enterText(_field(0), '245000');
      await tester.pump();
      expect(find.text('245${_nbsp}000'), findsOneWidget);
      await _tap(tester, find.text(_l10n.financeOnboardingStart));

      expect(find.text(_l10n.financeOnboardingDone), findsOneWidget);
      expect(find.text(_l10n.financeTabSummary), findsOneWidget);

      final accounts = await repo.getAccounts();
      expect(accounts, hasLength(1));
      expect(accounts.single.name, 'Касса');
      expect(accounts.single.type, AccountType.cash);
      expect(accounts.single.balance, Money.tenge(245000));
    });

    testWidgets('zero is a valid balance, an empty card is skipped', (
      tester,
    ) async {
      final repo = _repo(demo: false);
      await _pump(tester, '/finance', repo);

      await tester.enterText(_field(1), '0');
      await _tap(tester, find.text(_l10n.financeOnboardingStart));

      final accounts = await repo.getAccounts();
      expect(accounts.single.name, 'Kaspi');
      expect(accounts.single.balance, Money.zero);
    });

    testWidgets('another account added on the way stays on the first entry', (
      tester,
    ) async {
      final repo = _repo(demo: false);
      await _pump(tester, '/finance', repo);

      await _tap(tester, find.text(_l10n.financeOnboardingOtherAccount));
      expect(find.byType(FinanceAccountFormScreen), findsOneWidget);

      await _tap(tester, find.text('Halyk'));
      await tester.enterText(_field(1), '400000');
      await _tap(tester, find.text(_l10n.financeAccountCreate));

      // Первый вход не закрылся сам: фермер ещё может вписать кассу.
      expect(find.byType(FinanceOnboarding), findsOneWidget);
      expect(find.text('Halyk'), findsOneWidget);
      expect(find.text(_money('400 000')), findsOneWidget);

      await _tap(tester, find.text(_l10n.financeOnboardingStart));
      expect(find.text(_l10n.financeTabSummary), findsOneWidget);
      final halyk = (await repo.getAccounts()).single;
      expect(halyk.type, AccountType.bank);
    });
  });

  group('accounts', () {
    testWidgets('list with balances and hidden accounts', (tester) async {
      await _pump(tester, '/finance/settings', _repo());

      expect(find.text('Касса'), findsOneWidget);
      expect(find.text(_money('161 900')), findsOneWidget);
      expect(find.text(_money('922 000')), findsOneWidget);
      expect(find.text(_money('350 000')), findsOneWidget);
      expect(
        find.text(_l10n.financeHiddenSection.toUpperCase()),
        findsOneWidget,
      );
      expect(find.text('Старая карта'), findsOneWidget);
    });

    testWidgets('editing the initial balance previews the new balance', (
      tester,
    ) async {
      final repo = _repo();
      await _pump(tester, '/finance/settings', repo);

      await _tap(tester, find.text('Kaspi'));
      expect(find.text(_l10n.financeAccountBalanceNow), findsOneWidget);
      expect(find.text(_money('922 000')), findsOneWidget);
      expect(find.text('950${_nbsp}000'), findsOneWidget);

      await tester.enterText(_field(1), '1000000');
      await tester.pump();
      expect(
        find.text(_l10n.financeBalanceWillBe('Kaspi', _money('972 000'))),
        findsOneWidget,
      );

      await _tap(tester, find.text(_l10n.financeSave));
      expect(find.byType(FinanceSettingsScreen), findsOneWidget);
      expect(find.text(_money('972 000')), findsOneWidget);
      expect(find.text(_l10n.financeAccountSaved), findsOneWidget);
    });

    testWidgets('a new account needs a name and a balance', (tester) async {
      final repo = _repo(demo: false);
      await _pump(tester, '/finance/accounts/new', repo);

      await _tap(tester, find.text(_l10n.financeAccountCreate));
      expect(find.text(_l10n.financeAccountNameError), findsOneWidget);
      expect(find.text(_l10n.financeAccountInitialError), findsOneWidget);
      expect(await repo.getAccounts(), isEmpty);

      await tester.enterText(_field(0), 'Jusan');
      await _tap(tester, find.text(_l10n.financeAccountTypeBank));
      await tester.enterText(_field(1), '0');
      await _tap(tester, find.text(_l10n.financeAccountCreate));

      final account = (await repo.getAccounts()).single;
      expect(account.name, 'Jusan');
      expect(account.type, AccountType.bank);
      expect(account.initialBalance, Money.zero);
    });

    testWidgets('hiding asks first and moves the account to hidden', (
      tester,
    ) async {
      final repo = _repo();
      await _pump(tester, '/finance/settings', repo);

      await _tap(tester, find.text('Halyk'));
      await _tap(tester, find.text(_l10n.financeAccountHide));
      expect(
        find.text(_l10n.financeAccountHideConfirm('Halyk')),
        findsOneWidget,
      );
      await _tap(tester, find.text(_l10n.financeHideAction));

      expect(find.text(_l10n.financeAccountHidden), findsOneWidget);
      final halyk = (await repo.getAccounts()).firstWhere(
        (a) => a.name == 'Halyk',
      );
      expect(halyk.active, isFalse);
    });

    testWidgets('an unknown account shows a message, not a crash', (
      tester,
    ) async {
      await _pump(tester, '/finance/accounts/999', _repo());
      expect(find.text(_l10n.financeAccountNotFound), findsOneWidget);
    });
  });

  group('buyers', () {
    testWidgets('list shows phones and debts', (tester) async {
      await _pump(tester, '/finance/settings?tab=buyers', _repo());

      expect(find.text('Магазин Береке'), findsOneWidget);
      expect(find.text('+7 701 234 56 78'), findsOneWidget);
      expect(find.text(_l10n.financeNoPhone), findsOneWidget);
      expect(
        find.text(_l10n.financeBuyerOwes(_money('285 000'))),
        findsOneWidget,
      );
      expect(
        find.text(_l10n.financeBuyerOwes(_money('66 000'))),
        findsOneWidget,
      );
    });

    testWidgets('editing reformats an old phone into the mask', (tester) async {
      await _pump(tester, '/finance/settings?tab=buyers', _repo());
      await _tap(tester, find.text('Магазин Береке'));
      expect(find.text('+7 (701) 234-56-78'), findsOneWidget);
    });

    testWidgets('a new buyer: optional phone must be complete', (tester) async {
      final repo = _repo(demo: false);
      await _pump(tester, '/finance/counterparties/new', repo);

      await _tap(tester, find.text(_l10n.financeCounterpartyAdd));
      expect(find.text(_l10n.financeCounterpartyNameError), findsOneWidget);

      await tester.enterText(_field(0), 'Кафе «Жайлау»');
      await tester.enterText(_field(1), '70512');
      await _tap(tester, find.text(_l10n.financeCounterpartyAdd));
      expect(find.text(_l10n.financePhoneError), findsOneWidget);

      await tester.enterText(_field(1), '7051184022');
      await _tap(tester, find.text(_l10n.financeCounterpartyAdd));
      final buyer = (await repo.getCounterparties()).single;
      expect(buyer.name, 'Кафе «Жайлау»');
      expect(buyer.phone, '+7 (705) 118-40-22');
    });

    testWidgets('a buyer without a phone', (tester) async {
      final repo = _repo(demo: false);
      await _pump(tester, '/finance/counterparties/new', repo);
      await tester.enterText(_field(0), 'Айгерим');
      await _tap(tester, find.text(_l10n.financeCounterpartyAdd));
      expect((await repo.getCounterparties()).single.phone, isNull);
    });
  });

  group('helpers', () {
    test('buyer initial skips generic words and quotes', () {
      expect(buyerInitial('Магазин «Достык»'), 'Д');
      expect(buyerInitial('ИП Сауле, молочный отдел'), 'С');
      expect(buyerInitial('Кафе «Жайлау»'), 'Ж');
      expect(buyerInitial('Береке дүкені'), 'Б');
      expect(buyerInitial('магазин'), 'М');
      expect(buyerInitial(''), '?');
    });

    test('phone format and input', () {
      expect(FinancePhone.format('+7 701 234 56 78'), '+7 (701) 234-56-78');
      expect(FinancePhone.format('87012345678'), '+7 (701) 234-56-78');
      expect(FinancePhone.format('7012345678'), '+7 (701) 234-56-78');
      expect(FinancePhone.format('+998 90 123'), '+998 90 123');
      expect(FinancePhone.fromInput(''), isNull);
      expect(FinancePhone.fromInput('+7 ('), isNull);
      expect(FinancePhone.fromInput('+7 (701) 23'), '');
      expect(
        FinancePhone.fromInput('+7 (701) 234-56-78'),
        '+7 (701) 234-56-78',
      );
    });
  });
}
