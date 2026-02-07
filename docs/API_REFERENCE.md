# API Reference

This document lists the **current** API routes plus the **planned** endpoints.

## Base URL
- Local development: `http://localhost:3000`

## Health

`GET /up`
- Purpose: liveness check
- Response: HTTP 200 when the Rails app boots successfully

## Planned Endpoints (Not Implemented Yet)

`POST /api/links`
- Body: `{ "long_url": "https://example.com" }`
- Response (planned):
  - `201 Created`
  - `{ "code": "Ab3", "short_url": "http://localhost:3000/Ab3" }`

`GET /:code`
- Redirects to the original URL
- Response (planned):
  - `302 Found` (or `301 Moved Permanently`)

`GET /api/links/:code`
- Returns metadata about a link
- Response (planned):
  - `200 OK`
  - `{ "code": "Ab3", "long_url": "...", "created_at": "..." }`

`GET /api/links/:code/stats`
- Returns analytics for a link
- Response (planned):
  - `200 OK`
  - `{ "code": "Ab3", "visits": 42 }`

## Notes
- When implementation begins, this file should be updated to reflect exact
  request/response schemas and error codes.
