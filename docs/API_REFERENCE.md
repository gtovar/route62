# API Reference

## Base URL
- Local development: `http://localhost:3000`

## Health

`GET /_internal/up`
- Purpose: liveness check
- Response: `200 OK`

## Create Short Link

`POST /links`
- Request JSON:
  - `{ "link": { "long_url": "https://example.com/very/long/path" } }`
- Success response:
  - Status: `201 Created`
  - Body:
    - `{ "id": 1, "long_url": "...", "slug": "abc", "short_url": "http://localhost:3000/abc" }`
- Error response:
  - Status: `422 Unprocessable Content`
  - Body:
    - `{ "errors": ["Long url Invalid URL format"] }`
    - `{ "errors": ["Slug has already been taken"] }`

## Redirect by Slug

`GET /:slug`
- Success response:
  - Status: `301 Moved Permanently`
  - Header: `Location: <long_url>`
  - Side effect:
    - Enqueues `TrackVisitJob` with `link_id`, `ip_address`, `user_agent`, and `visited_at`.
- Not found response:
  - Status: `404 Not Found`
  - Body:
    - `{ "error": "Short link not found" }`

## User Registration

`POST /signup`
- Request JSON:
  - `{ "user": { "name": "Jane Doe", "email": "jane@example.com", "password": "secret123" } }`
- Success response:
  - Status: `201 Created`
  - Body:
    - `{ "user": { "id": 1, "name": "Jane Doe", "email": "jane@example.com" }, "token": "<jwt>" }`
- Error response:
  - Status: `422 Unprocessable Content`
  - Body:
    - `{ "errors": ["Email has already been taken"] }`
