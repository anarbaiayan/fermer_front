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
- On the More screen, use `context.go` for primary bottom-navigation destinations and `context.push` for nested sections, so Back returns to More.
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
