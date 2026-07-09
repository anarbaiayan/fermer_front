# Frontend Rules

## Goal
Keep Flutter UI changes aligned with the current project structure and UX patterns.

## Required Conventions
- Add new code inside the nearest existing feature folder.
- Reuse `lib/core/widgets` before creating new generic widgets.
- Reuse `AppScaffold`, `FermerPlusAppBar`, `FermerPlusDrawer`, shared dialogs, and button components.
- Keep route registration centralized in `lib/core/router/app_router.dart`.
- Avoid business logic inside widgets when it belongs in providers/controllers.

## Screen-Level Checklist
- Route added or updated
- Strings added to both ARB files
- Success / error / empty states handled
- Back navigation and deep-link entry points checked
- Related provider invalidation covered after mutation

## UI Constraints
- Preserve current mobile-first layout style.
- Avoid introducing a second design language.
- Use the existing icon system in `assets/icons` and `lib/core/icons/app_icons.dart`.
