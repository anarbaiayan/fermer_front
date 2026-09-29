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
- Hidden behind `kFinanceEnabled` (`lib/core/config/feature_flags.dart`), debug only while the module runs on mock data. Do not enable it for release until it is wired to the real API.
- Screens use only `FinanceRepository` via `financeRepositoryProvider`. Default source is `MockFinanceRepository` (same rules as the backend); `--dart-define=FINANCE_API=true` switches to `FinanceApi`. Once the backend ships `/api/finance/**`, flip `kFinanceUseMock` and `kFinanceEnabled`.
- Mutations go through `financeMutationsProvider`, which invalidates the exact affected providers.
- Money is `Money` (integer tiyn) and quantities are `Quantity` (thousandths); no arithmetic on `double`. Format with `FinanceFormat`.
- Account balance = initial balance + paid sales − expenses. A debt sale never changes balances until it is paid.
- UI says "Покупатели" for backend `counterparties`.
- Backend differs from the spec: sales filter param is `paid` (not `isPaid`), payment is `PUT /finance/sales/{id}/pay`, `DELETE` on accounts and counterparties only deactivates, and debts/PDF endpoints are not implemented yet. `GET /finance/summary` matches the spec; its `accounts` include hidden ones (active first). The backend does not default a debt due date; the form always sends it (sale date + 14 days).
- The backend is expected to match the spec in full. Build endpoints it has not shipped yet (debts, PDF report, milk on Home) against the spec contract; `FinanceApi` follows the backend code only where it already exists, so re-check those differences when wiring the API.
- Product decisions for the module (payment, price hint, PDF sharing, overdue push) are in `docs/business-decisions.md`, section Finance.

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
