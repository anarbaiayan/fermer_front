# Skill: API Contract Change

Use this when backend endpoints, request bodies, response fields, or business semantics change.

## Workflow
1. Verify the latest backend contract via GitHub MCP if available.
2. Locate every affected frontend layer:
   - datasource
   - DTOs
   - entity mapping
   - providers
   - screens using the data
3. Check whether the change affects:
   - loading state
   - empty state
   - error state
   - route behavior
   - localization wording
4. Update provider invalidation logic after mutations.
5. Update docs when the business behavior changes.

## Watch-outs in this Project
- Rations have special behavior depending on entry point.
- Notifications rely on pagination and unread/archive semantics.
- Auth endpoints may need `skipAuth`.
