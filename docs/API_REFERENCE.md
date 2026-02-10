# API Reference

## Base URL
- Local development: `http://localhost:3000`
- CORS (local dev):
  - `http://localhost:8080`
  - `http://localhost:3001`

## Health

`GET /_internal/up`
- Purpose: liveness check
- Response: `200 OK`

## Create Short Link

`POST /links`
- Auth:
  - Required header: `Authorization: Bearer <jwt>` **or** `Authorization: ApiKey <api_key>`
  - Legacy compatibility (deprecated): `X-API-Key: <api_key>`
- Request JSON:
  - `{ "link": { "long_url": "https://example.com/very/long/path" } }`
- Success response:
  - Status: `201 Created`
  - Body:
    - `{ "id": 1, "long_url": "...", "slug": "abc", "short_url": "http://localhost:3000/abc" }`
- Error response:
  - Status: `401 Unauthorized`
  - Body:
    - `{ "errors": ["Unauthorized"] }`
  - Status: `422 Unprocessable Content`
  - Body:
    - `{ "errors": ["Long url Invalid URL format"] }`
    - `{ "errors": ["Slug has already been taken"] }`

## List My Links (Paginated)

`GET /links`
- Auth:
  - Required header: `Authorization: Bearer <jwt>` **or** `Authorization: ApiKey <api_key>`
  - Legacy compatibility (deprecated): `X-API-Key: <api_key>`
- Query params:
  - `page` (default: `1`)
  - `per_page` (default: `10`, max: `100`)
- Success response:
  - Status: `200 OK`
  - Body:
    - `{ "links": [ { "id": 1, "long_url": "...", "slug": "abc", "short_url": "http://localhost:3000/abc" } ], "pagination": { "page": 1, "per_page": 10, "total_count": 1, "total_pages": 1 } }`
- Error response:
  - Status: `401 Unauthorized`
  - Body:
    - `{ "errors": ["Unauthorized"] }`

## Update My Link

`PATCH /links/:id`
- Auth:
  - Required header: `Authorization: Bearer <jwt>` **or** `Authorization: ApiKey <api_key>`
  - Legacy compatibility (deprecated): `X-API-Key: <api_key>`
- Request JSON:
  - `{ "link": { "long_url": "https://example.com/updated/path" } }`
- Success response:
  - Status: `200 OK`
  - Body:
    - `{ "id": 1, "long_url": "...", "slug": "abc", "short_url": "http://localhost:3000/abc" }`
- Error response:
  - Status: `404 Not Found`
  - Body:
    - `{ "errors": ["Link not found"] }`
  - Status: `422 Unprocessable Content`
  - Body:
    - `{ "errors": ["Long url Invalid URL format"] }`

## Delete My Link

`DELETE /links/:id`
- Auth:
  - Required header: `Authorization: Bearer <jwt>` **or** `Authorization: ApiKey <api_key>`
  - Legacy compatibility (deprecated): `X-API-Key: <api_key>`
- Success response:
  - Status: `204 No Content`
- Error response:
  - Status: `404 Not Found`
  - Body:
    - `{ "errors": ["Link not found"] }`

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
    - `{ "user": { "id": 1, "name": "Jane Doe", "email": "jane@example.com", "api_key": "rk_...", "api_key_last4": "abcd" }, "token": "<jwt>" }`
  - Note:
    - Full `api_key` is returned only once at signup.
- Error response:
  - Status: `422 Unprocessable Content`
  - Body:
    - `{ "errors": ["Email has already been taken"] }`

## User Login

`POST /login`
- Request JSON:
  - `{ "user": { "email": "jane@example.com", "password": "secret123" } }`
- Success response:
  - Status: `200 OK`
  - Body:
    - `{ "user": { "id": 1, "name": "Jane Doe", "email": "jane@example.com", "api_key_last4": "abcd" }, "token": "<jwt>" }`
  - Note:
    - Login never returns the full `api_key`.
- Error response:
  - Status: `401 Unauthorized`
  - Body:
    - `{ "errors": ["Invalid email or password"] }`

## Link Stats Dashboard

`GET /links/stats`
- Auth:
  - Required header: `Authorization: Bearer <jwt>` **or** `Authorization: ApiKey <api_key>`
  - Legacy compatibility (deprecated): `X-API-Key: <api_key>`
- Purpose:
  - Return current user's most frequently accessed links (up to 100) with click metrics and traffic breakdowns.
  - Breakdown percentages are calculated over logged visit records for that link.
  - `user_agent_breakdown` is capped to top 10 entries; remaining entries are grouped under `Other`.
- Success response:
  - Status: `200 OK`
  - Body:
    - `{ "links": [ { "id": 1, "long_url": "...", "slug": "abc", "created_at": "...", "total_clicks": 10, "unique_visits": 4, "recurrent_visits": 6, "breakdown_denominator": 10, "device_breakdown": [ { "name": "Desktop", "count": 6, "percentage": 60.0 }, { "name": "Mobile", "count": 4, "percentage": 40.0 } ], "os_breakdown": [ { "name": "Windows", "count": 5, "percentage": 50.0 }, { "name": "iOS", "count": 3, "percentage": 30.0 }, { "name": "Android", "count": 2, "percentage": 20.0 } ], "user_agent_breakdown": [ { "name": "Mozilla/5.0 (...)", "count": 3, "percentage": 30.0 }, { "name": "curl/8.0.1", "count": 2, "percentage": 20.0 } ] } ] }`
- Error response:
  - Status: `401 Unauthorized`
  - Body:
    - `{ "errors": ["Unauthorized"] }`

## Global Top 100 Links

`GET /links/top`
- Auth:
  - Public endpoint (no auth required).
- Purpose:
  - Return the top 100 most frequently accessed links across all users.
- Success response:
  - Status: `200 OK`
  - Body:
    - `{ "links": [ { "id": 1, "slug": "abc", "long_url": "...", "created_at": "...", "total_clicks": 10, "unique_visits": 4 } ] }`

## API Key Rotation

`POST /api_keys/rotate`
- Auth:
  - Required header: `Authorization: Bearer <jwt>`
  - Note: `Authorization: ApiKey` is not accepted for this endpoint.
- Purpose:
  - Rotate current user API key and return the new key once.
- Success response:
  - Status: `200 OK`
  - Body:
    - `{ "api_key": "rk_...", "api_key_last4": "abcd" }`
  - Note:
    - Full `api_key` is returned only once in this response.
- Error response:
  - Status: `401 Unauthorized`
  - Body:
    - `{ "errors": ["Unauthorized"] }`
