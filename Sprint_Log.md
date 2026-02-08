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
