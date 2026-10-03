import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/core/widgets/fermer_plus_drawer.dart';
import 'package:frontend/features/auth/application/auth_controller.dart';
import 'package:frontend/features/auth/application/auth_providers.dart';
import 'package:frontend/features/auth/domain/entities/user.dart';
import 'package:frontend/l10n/app_localizations.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class _StubAuth extends StateNotifier<AuthState> implements AuthController {
  _StubAuth(super.state);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

User _user(String? farmName) => User(
  id: 1,
  phoneNumber: '+77777777777',
  email: null,
  firstName: 'Иван',
  lastName: 'Иванов',
  farmName: farmName,
  city: null,
  region: null,
  roles: const ['ROLE_USER'],
  phoneVerified: false,
);

Future<void> _pumpDrawer(WidgetTester tester, {User? user}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        authControllerProvider.overrideWith(
          (ref) => _StubAuth(AuthState(user: user)),
        ),
      ],
      child: MaterialApp(
        locale: const Locale('ru'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: Scaffold(
          body: FermerPlusDrawer(
            farmName: lookupAppLocalizations(const Locale('ru')).farmName,
          ),
        ),
      ),
    ),
  );
  await tester.pump();
}

void main() {
  final fallback = lookupAppLocalizations(const Locale('ru')).farmName;

  testWidgets('shows the farm name from the profile', (tester) async {
    await _pumpDrawer(tester, user: _user('Ромашка'));

    expect(find.text('"Ромашка"'), findsOneWidget);
    expect(find.text('"$fallback"'), findsNothing);
  });

  testWidgets('keeps the default caption when the profile has no farm name', (
    tester,
  ) async {
    await _pumpDrawer(tester, user: _user(null));
    expect(find.text('"$fallback"'), findsOneWidget);

    await _pumpDrawer(tester, user: _user('   '));
    expect(find.text('"$fallback"'), findsOneWidget);
  });

  testWidgets('keeps the default caption before the profile is loaded', (
    tester,
  ) async {
    await _pumpDrawer(tester);
    expect(find.text('"$fallback"'), findsOneWidget);
  });
}
