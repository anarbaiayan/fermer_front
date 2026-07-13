# Skill: Add Feature

Use this when implementing a new frontend feature or extending an existing one.

## Workflow
1. Identify the owning feature module under `lib/features`.
2. Check whether the change is:
   - new screen
   - new backend endpoint
   - new mutation flow
   - new UI state
3. Update the proper layers in order:
   - DTO / datasource
   - entities if needed
   - providers/controller
   - presentation
   - router
   - localization
4. Reuse existing shared widgets before creating new ones.
5. Add success / error / empty-state handling.
6. Invalidate the exact providers affected by mutations.
7. If the feature changes app-level navigation, update the More screen, drawer rules, and the bottom-nav selected index together.

## Validation
- `dart format`
- `flutter gen-l10n` if strings changed
- `flutter analyze` on touched files
