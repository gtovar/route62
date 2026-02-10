# Sprint Log

## 2026-02-07

### HU-01 — Create Short Link (Closed)
- Implemented `ShortenerService` with shuffled Base62 encode/decode.
- Added service specs for encode/decode and edge cases.
- Implemented `POST /links` create flow with strong params.
- Added `Link` model validations for `long_url` format and slug uniqueness.
- Added request specs for success, invalid URL, and collision error path.
- Added testing documentation (`docs/testing.md`) and Makefile test shortcuts in `ops/Makefile`.

## 2026-02-08

### HU-02 — Redirect Visitor (Closed)
- Added redirect endpoint `GET /:slug` in `RedirectsController#show`.
- Implemented `301` redirect for valid slugs and `404` JSON for missing slugs.
- Moved health check route to `GET /_internal/up` to avoid conflicts with public slugs.

### HU-03 — User Registration (Closed)
- Added `User` model with `has_secure_password`.
- Added unique email enforcement in model and DB index.
- Added `POST /signup` endpoint for registration.
- Added `AuthTokenService` for JWT issuance on successful signup.
- Added request specs for success and duplicate email scenarios.

### Decision Maker (G0–G3)
- Decision recorded as ADR: JWT token on signup (API-only flow) instead of cookie-based session for HU-03 scope.

## 2026-02-09

### HU-04 — Track Visit Metadata (Closed)
- Added `visits` table with `link_id`, `ip_address`, `user_agent`, and `visited_at`.
- Added `Visit` model and `Link has_many :visits` relation.
- Added `TrackVisitJob` for asynchronous metadata persistence.
- Updated redirect flow to enqueue visit tracking without blocking `301` redirect.
- Added request spec coverage for async job enqueue during redirect.

### Decision Maker (G0–G3)
- Decision recorded as ADR: async job-based visit tracking for redirect latency protection (HU-04 scope).

### HU-05 — Link Dashboard & Stats (Closed)
- Added authenticated stats endpoint: `GET /links/stats`.
- Added top-100 limit on returned links.
- Added per-link metrics: `total_clicks`, `unique_visits`, `recurrent_visits`.
- Added user-to-links relation with `user_id` on links.
- Added request specs for unauthorized access, user scoping, and top-100 cap.

### Decision Maker (G0–G3)
- No new ADR for HU-05. Decision considered routine extension of existing analytics model and query layer.

### Gap Closure — Links Management + Pagination (Closed)
- Expanded `links` routes from create-only to full management scope used by this phase:
  - `GET /links`
  - `PATCH /links/:id`
  - `DELETE /links/:id`
- Added paginated current-user listing with response metadata:
  - `page`, `per_page`, `total_count`, `total_pages`
- Enforced ownership on update/delete via `current_user.links.find`.
- Added request specs for:
  - auth required
  - pagination behavior
  - ownership protection (`404` for foreign links)
- Updated API reference with new endpoint contracts.

### Decision Maker (G0–G3)
- No new ADR for this gap closure; implemented as incremental API surface extension consistent with existing auth and ownership model.

## 2026-02-10

### Gap Closure — Login Endpoint (Closed)
- Added `POST /login` via `SessionsController#create`.
- Login now returns `{ user, token }` for valid credentials.
- Invalid credentials return `401` with a generic auth error.

### Gap Closure — API Key Flow (Closed)
- Added explicit API key authentication flow:
  - `Authorization: ApiKey <key>` + legacy `X-API-Key` compatibility.
- Added API key rotation endpoint:
  - `POST /api_keys/rotate` (JWT required).
- Added digest-based API key storage fields and migrations:
  - `api_key_digest`, `api_key_last4`, `api_key_rotated_at`.
- Added request specs for API key auth paths and rotate endpoint.

### Gap Closure — Stats Breakdown (Closed)
- Extended `GET /links/stats` with:
  - `breakdown_denominator`
  - `device_breakdown`
  - `os_breakdown`
  - `user_agent_breakdown` (Top 10 + `Other`)
- Added OS fallback parsing for stable classification across UA formats.
- Added request specs for percentage and breakdown behavior.

### Gap Closure — Public Global Top 100 (Closed)
- Added public endpoint:
  - `GET /links/top`
- Added request specs for:
  - public access without auth,
  - top-100 cap,
  - tie-break ordering by `created_at DESC`.
- Connected frontend Top 100 view to the global endpoint.

### Decision Maker (G0–G3)
- No new ADR created. Changes were implemented as incremental extensions of existing auth/analytics architecture.
