# API and State Rules

## Source of Truth
- Local frontend code shows the current consumer side.
- Local backend repository is expected in sibling folder `../fp-backend`.
- GitHub MCP should be used for up-to-date backend contracts whenever API behavior is unclear or recently changed.

## Data Flow Rules
- API calls belong in `data/datasources`.
- Request/response shapes belong in DTOs.
- UI should consume providers/entities, not raw JSON maps.
- If frontend behavior looks inconsistent with server behavior, inspect `../fp-backend` before assuming the mobile code is wrong.
- Contract changes must be reflected across:
  - DTOs
  - API methods
  - provider invalidation
  - UI handling

## Dio Rules
- Main base URL is configured in `lib/core/network/network_providers.dart`.
- Protected endpoints use the authenticated Dio path.
- Login / refresh / restore-account style endpoints can use `skipAuth`.
- Do not duplicate auth logic already handled by interceptor + token repository.

## Mutation Rules
- Any create/update/delete/regenerate flow must explicitly invalidate affected providers.
- Prefer precise invalidation over broad app-wide resets.
- Keep backend error messages when they are meaningful for the user.
