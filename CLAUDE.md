# Fermer+ Frontend - Claude Working Rules

## Project Summary
- Flutter mobile app for cattle/farm management.
- Main domains: auth, herd, cattle events, lactation, rations/feed stock, pharmacy, notifications, profile/settings, support.
- Product languages: Russian and Kazakh.
- Android package: `kz.fermerplus.app`.
- Backend repository is stored next to this frontend project in sibling folder `../fp-backend`.

## Tech Stack
- Flutter + Dart
- Riverpod / hooks_riverpod
- GoRouter
- Dio + auth interceptor + token refresh
- SharedPreferences + FlutterSecureStorage
- ARB localization (`lib/l10n`)

## Core Architecture
- Keep feature-based structure under `lib/features/<feature>/`.
- Standard layers:
  - `data/` - API, DTOs, mappers
  - `domain/` - entities/enums
  - `application/` - providers/controllers
  - `presentation/` - screens/widgets
- Shared infrastructure lives in `lib/core/`.
- Do not bypass layers by calling Dio directly from presentation.

## Data and API Rules
- Base API URL is currently defined in `lib/core/network/network_providers.dart`.
- When backend implementation details are needed locally, check sibling repository `../fp-backend`.
- Before changing API contracts, verify the backend state through GitHub MCP if available.
- Backend contract changes must be reflected consistently in:
  - DTOs
  - API datasource
  - providers/controller invalidation
  - UI states and empty/error states
- Prefer backend message extraction via existing API exception helpers instead of ad hoc parsing.

## State Management Rules
- Use Riverpod for async data, mutations, derived state, and invalidation.
- Reuse existing provider style in each feature before introducing new patterns.
- After create/update/delete/regenerate actions, invalidate the exact affected providers.
- Auth state stays centralized in `auth_controller.dart`.

## Routing Rules
- All app routes are centralized in `lib/core/router/app_router.dart`.
- New screens must be added to router and linked from the correct entry points.
- The canonical bottom navigation order is fixed:
  - index 0: Home (`/home`)
  - index 1: Herd (`/herd`)
  - index 2: Events (`/events`)
  - index 3: Lactation (`/lactation`)
  - index 4: More (`/more`)
- Rations and pharmacy are not bottom-navigation tabs. They are discovered through `/more`; ration, feed-stock, and pharmacy screens use bottom-nav index `4` when they show the bottom bar.
- Screens that show the bottom bar live inside the `ShellRoute` in `app_router.dart`. `AppShell` (`lib/core/widgets/app_shell.dart`) owns the bar and the drawer, so they stay fixed while pages change:
  - tabs use `NoTransitionPage`; sections opened from More use the default platform transition (iOS swipe-back works);
  - the highlighted tab comes from `AppShell.indexForPath`, so a new bar screen needs both a shell route and an entry there; `AppScaffold.bottomNavIndex` only matters outside the shell;
  - the `ShellRoute` stays last in the route list so `/rations/stocks/:type` does not swallow `/rations/stocks/add`;
  - from a screen outside the shell, reach shell screens with `context.go`, never `context.push` — push would build a second shell with the same navigator key.
- On the More screen, use `context.go` for primary bottom-navigation destinations and `context.push` for nested sections, so Back returns to More.
- Finance: `/finance` is one shell screen (bar index `4`); its tabs Summary / Income / Expense / Report switch inside `FinanceScreen`, deep link `/finance?tab=income`. Forms, debts, accounts and buyers, and the ready PDF live under `/finance/**` outside the shell, without the bar.
- `FermerPlusDrawer` keeps profile, settings, FAQ, support, referral, and logout. Pharmacy must not be added back to the drawer.
- Preserve route semantics already used in the app:
  - `/herd/:id`
  - `/rations`
  - `/notifications`
  - auth flow routes

## Localization Rules
- No new user-facing strings inline in widgets if they belong to app UI.
- Add strings to both `lib/l10n/app_ru.arb` and `lib/l10n/app_kk.arb`.
- Regenerate localization after changes.
- If backend already provides translated content (for example `name` / `nameKk`), use backend data instead of duplicating translations in frontend.
- For event types, keep labels centralized in `cattle_event_type.dart` + localization keys.

## UI / UX Rules
- Preserve the existing app visual language: custom app scaffold, drawer, app bar, cards, dialogs, buttons.
- Reuse shared widgets from `lib/core/widgets` where possible.
- The More screen (`lib/features/more`) is a grouped app directory. Keep its three groups: primary sections, farm management, and account/support.
- More items use existing SVG icons in rounded-square icon containers, grouped white cards, and the existing green/brown/neutral palette.
- Prefer explicit empty states and actionable errors over generic snackbars.
- Destructive actions should keep confirm dialog + success/error feedback.

## Business-Critical Behaviors
- Rations screen has two modes:
  - direct cattle context -> one cattle ration
  - standalone screen -> all user rations
- If user has no available feeds, ration-related screens should show the proper empty state, not a raw server error.
- Sidebar logout and profile delete-account are different flows; do not merge them casually.
- Notifications use pagination, unread badge, archive/read actions, and navigation to herd item if cattle exists.

## Finance Module (`lib/features/finance`)
- Enabled in every build: the backend `/api/finance/**` is on prod since 01.10.2026, so there is no feature flag any more.
- Screens use only `FinanceRepository` via `financeRepositoryProvider`. Default source is `FinanceApi`; `--dart-define=FINANCE_MOCK=true` switches to `MockFinanceRepository` (same rules as the backend) for demos without a server.
- `test/features/finance/finance_api_live_test.dart` checks `FinanceApi` against a running backend (local or dev only, it registers a new user): `flutter test test/features/finance/finance_api_live_test.dart --dart-define=FINANCE_LIVE_API=http://localhost:8888/api`. Run it after backend contract changes.
- Mutations go through `financeMutationsProvider`, which invalidates the exact affected providers.
- Money is `Money` (integer tiyn) and quantities are `Quantity` (thousandths); no arithmetic on `double`. Format with `FinanceFormat`.
- Account balance = initial balance + paid sales − expenses. A debt sale never changes balances until it is paid.
- UI says "Покупатели" for backend `counterparties`.
- `FinanceApi` is checked against backend branch `finance` (commit df38a37 plus local fixes of 30.09.2026), which follows the spec: `isPaid` filter, `POST /finance/sales/{id}/pay`, `/debts`, `/report/pdf`, debt due date defaults to sale date + 14 days (the form still sends it). `DELETE` on accounts and counterparties only deactivates; there is no restore (not needed for now). Differences the app handles: `GET /debts` is not sorted (the app sorts most overdue first), a debt without a buyer comes named «Без контрагента» (the app shows its own localized label). The backend also has `GET /finance/today`; the Home block does not use it because it needs the day's sales and expenses in detail.
- A product from the fixed list is sent in Russian (`SaleProduct.apiName`), so the database and the backend PDF have one name in any app language; screens show it in the app language (`SaleProduct.displayName`). Own products go as typed.
- Balances in Summary and on Home use `balanceAccounts`: active accounts, then hidden ones that still hold money (marked hidden), all counted in the total.
- Finance forms close the keyboard on a tap outside the fields and on scroll (`FinanceKeyboardDismiss`): the iPhone number pad has no Done key. The Finance header has a back arrow: back through the stack, else `/more`.
- iOS: `share_plus` is not in `ios/Podfile.lock` yet; the first `flutter build ios` / `pod install` on a Mac adds it — commit the updated lock file.
- Product decisions for the module (payment, price hint, PDF sharing, overdue push) are in `docs/business-decisions.md`, section Finance.
- The home "Today" block lives in `lib/features/home/presentation/widgets/todaySection/`. A `FINANCE_OVERDUE` push or notification opens `/finance/debts`, with `?counterpartyId=` when the payload has it (null for a debt without a buyer).

## Platform / Release Rules
- Android release must keep `INTERNET` permission in `android/app/src/main/AndroidManifest.xml`.
- Before Play upload:
  - bump `version` in `pubspec.yaml`
  - build `.aab`
  - verify signing config and package id
- Release fixes that only exist in debug/profile manifests are incomplete.

## Validation Workflow
- After meaningful code changes, run targeted checks:
  - `dart format ...`
  - `flutter gen-l10n` if localization changed
  - `flutter analyze <touched areas>`
- For release-related work, also run:
  - `flutter build appbundle --release`

## Git and Editing Safety
- Assume the working tree may contain user changes.
- Never revert unrelated changes.
- Do not rewrite large areas if a local targeted fix is enough.
- Keep docs/rules updated when introducing important project-level conventions.

## MCP Usage
- Prefer GitHub MCP for current backend truth:
  - API routes
  - DTO fields
  - recent backend pull requests / commits
  - release notes / operational docs
- If MCP data conflicts with local assumptions, trust MCP and update docs/code accordingly.
