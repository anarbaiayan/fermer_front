# Frontend Architecture

## Structure
The app uses feature-based organization under `lib/features/<feature>/`.

Each feature usually contains:
- `data/`
- `domain/`
- `application/`
- `presentation/`

## Layer Responsibilities

### data
- API datasources
- DTOs
- request/response mapping

### domain
- entities
- enums
- feature-specific business representations

### application
- Riverpod providers
- state notifiers / async notifiers
- orchestration and invalidation

### presentation
- screens
- widgets
- dialogs
- form logic

## Shared Core
`lib/core` contains:
- network setup
- router
- localization helpers
- reusable widgets
- theme
- config

## Backend Repository Location
- The backend for this mobile app is expected to live next to the frontend repository in sibling folder `../fp-backend`.
- When investigating API mismatches locally, compare frontend DTOs/datasources with backend implementation in `../fp-backend`.

## Networking
- `network_providers.dart` defines base URL and Dio setup.
- `auth_interceptor.dart` handles authenticated request flow.
- `token_repository.dart` stores and refreshes tokens.

## Navigation
- Centralized in `lib/core/router/app_router.dart`.
- Routes cover auth flow, herd screens, ration screens, notifications, profile, settings, support.

## State Management
- Riverpod is the standard for:
  - async loading
  - caching
  - invalidation after mutation
  - feature-scoped state
- Auth is handled by `AuthController`.
- Notifications pagination is handled by an async notifier family.

## Localization
- Source files: `lib/l10n/app_ru.arb`, `lib/l10n/app_kk.arb`
- Generated localization classes are committed to repo.
- Language choice is persisted via SharedPreferences.

## Validation Convention
- format touched files
- regenerate localization when needed
- run targeted analysis
- run release build when touching store/release-critical code
