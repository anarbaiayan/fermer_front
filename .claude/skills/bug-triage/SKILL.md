# Skill: Bug Triage

Use this when investigating runtime, release, or environment-specific bugs.

## Workflow
1. Classify the issue:
   - frontend logic
   - lifecycle/state bug
   - backend contract mismatch
   - platform/release config
   - environment/server issue
2. Check whether it reproduces in:
   - debug
   - profile/release
   - Play distributed build
3. Inspect the nearest likely sources:
   - `app_router.dart`
   - `network_providers.dart`
   - feature datasource/provider
   - manifest / build config
4. For backend-related failures, distinguish:
   - no network
   - wrong route
   - auth issue
   - server HTML error page
5. Patch the smallest correct layer, then rebuild/verify in the relevant mode.

## Project-Specific Examples
- `404 text/html` from nginx usually means backend routing or wrong base path, not Flutter parsing.
- Closed testing failures may be release-manifest issues even if debug works.
