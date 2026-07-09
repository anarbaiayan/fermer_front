# Localization Rules

## Product Languages
- Russian (`ru`) is the default UI language.
- Kazakh (`kk`) is fully supported and must not lag behind new UI changes.

## Required Workflow
- Add every new UI string to:
  - `lib/l10n/app_ru.arb`
  - `lib/l10n/app_kk.arb`
- Regenerate localization classes after edits.
- Do not hardcode visible labels in widgets unless they are backend data.

## Special Cases
- If backend returns localized content (`name`, `nameKk`, etc.), use backend values.
- Event type labels must stay centralized through enum + localization, not copied inline across forms.
- Empty states, errors, dialogs, and button texts are also localization scope.
