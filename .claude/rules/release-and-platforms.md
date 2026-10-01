# Release and Platform Rules

## Android
- Release-critical permissions belong in `android/app/src/main/AndroidManifest.xml`, not only debug/profile manifests.
- Before uploading to Play:
  - bump `pubspec.yaml` version/build
  - build release `.aab`
  - verify signing path
  - verify package id `kz.fermerplus.app`
- Closed testing bugs must be reproduced against release assumptions, not only debug behavior.

## iOS
- Keep launch screen and app icon settings consistent with Xcode project files.
- Platform-specific changes should not break Android paths and vice versa.

## Forced update
- `lib/features/app_update` blocks builds below the backend minimum (`GET /api/public/app-version`).
- Raise `APP_ANDROID_MIN_BUILD` / `APP_IOS_MIN_BUILD` on the backend only after build N is live in that store, otherwise users are sent to a store page without the update.
- The build number is the number after `+` in `pubspec.yaml`; iOS archives must carry it (build with `flutter build ipa`, not a bare Xcode archive).

## Validation
- For store-bound changes, run release build validation, not only emulator/debug checks.
