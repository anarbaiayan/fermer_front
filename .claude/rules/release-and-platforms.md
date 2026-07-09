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

## Validation
- For store-bound changes, run release build validation, not only emulator/debug checks.
