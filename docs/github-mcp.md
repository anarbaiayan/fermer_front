# GitHub MCP Usage for This Project

## Purpose
GitHub MCP should be treated as the source for up-to-date backend truth when local frontend code may be stale.

## Local Repository Context
- The backend repository is expected to live next to this frontend project in sibling folder `../fp-backend`.
- If GitHub MCP is unavailable, local backend inspection should start from `../fp-backend`.

## Use GitHub MCP For
- current backend endpoints
- request/response schemas
- enum changes
- business logic notes from pull requests and commits
- release notes / operational issues
- API docs stored in GitHub repositories or docs

## Recommended Workflow
1. Before editing feature API code, check whether the backend recently changed.
2. If route or payload is unclear, query GitHub MCP first.
3. If GitHub MCP and frontend code disagree, assume frontend may be outdated.
4. After adapting code, update project docs if business semantics changed.

## Priority Areas
- auth contracts
- rations / feed stock endpoints
- notifications endpoints and pagination
- cattle event type mappings

## Recommended Server Choices
- Remote GitHub MCP server:
  - `https://api.githubcopilot.com/mcp/`
- Local Docker image:
  - `ghcr.io/github/github-mcp-server`

## Why This Matters Here
This project already experienced multiple backend contract changes, especially around:
- rations
- notifications
- account flows
- release/distribution behavior

Using GitHub MCP early reduces wasted frontend fixes against stale assumptions.
