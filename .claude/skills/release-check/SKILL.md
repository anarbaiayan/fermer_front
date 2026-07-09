# Skill: Release Check

Use this before Play upload or when release-only behavior differs from debug.

## Checklist
1. Confirm `pubspec.yaml` version/build was bumped.
2. Verify Android signing config resolves the real keystore path.
3. Ensure release permissions are in `android/app/src/main/AndroidManifest.xml`.
4. Confirm package id and target SDK are correct.
5. Run:
   - `flutter build appbundle --release`
6. Record output artifact path.
7. If the issue only exists in Play build, compare release manifest and release runtime assumptions.

## Project Notes
- This project already had a real release issue caused by missing `INTERNET` permission in `main` manifest.
- Do not assume debug/profile manifests cover release behavior.
