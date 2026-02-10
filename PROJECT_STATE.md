# PROJECT_STATE — URL Shortener Challenge
[Last update: 2026-02-09 — HU-05 completed]

## 1. System Overview
Initial setup of the monolithic repo containing Rails 8 API and React Frontend, fully dockerized.

## 2. Current Technical State
- **Backend:** Rails 8.1.2 initialized. DB connection ready. `Link` model created with index on `slug`.
- **Frontend:** Vite React-TS initialized. Port 3001 configured.
- **Infra:** Docker Compose orchestrating 4 services (db, redis, backend, frontend).

## 3. User Story Status

### ✅ HU-01 — Create Short Link (DONE)
**Coordinates:**
- Branch: `feat/hu1-create-short-link`
- Key Files:
  - `backend-api/app/services/shortener_service.rb`
  - `backend-api/spec/services/shortener_service_spec.rb`
  - `backend-api/app/models/link.rb`
  - `backend-api/app/controllers/links_controller.rb`
  - `backend-api/spec/requests/links_spec.rb`
**Evidence:**
- Backend tests for HU-01 passing:
  - `spec/services/shortener_service_spec.rb` (11 examples, 0 failures)
  - `spec/requests/links_spec.rb` (passing in Docker)
- Endpoint implemented: `POST /links`
- Invalid URL validation implemented with message: `Invalid URL format`
- Shuffled Base62 alphabet implemented in `ShortenerService`
- Slug uniqueness enforced by DB index and model validation.

### ✅ HU-02 — Redirect Visitor (DONE)
**Coordinates:**
- Branch: `feat/hu2-redirect-visitor`
- Key Files:
  - `backend-api/app/controllers/redirects_controller.rb`
  - `backend-api/spec/requests/redirects_spec.rb`
  - `backend-api/config/routes.rb`
**Evidence:**
- `GET /:slug` implemented with:
  - `301 Moved Permanently` when slug exists.
  - `404 Not Found` when slug does not exist.
- Internal health check moved to `GET /_internal/up` to keep slug namespace clear.

### ✅ HU-03 — User Registration (DONE)
**Coordinates:**
- Branch: `feat/hu3-user-registration`
- Key Files:
  - `backend-api/app/models/user.rb`
  - `backend-api/app/controllers/users_controller.rb`
  - `backend-api/app/services/auth_token_service.rb`
  - `backend-api/spec/requests/users_spec.rb`
  - `backend-api/db/migrate/20260208000100_create_users.rb`
**Evidence:**
- Endpoint implemented: `POST /signup`
- Unique email constraint implemented at model and DB index level.
- Successful signup returns user payload + auth token (auto login).
- Request specs for valid signup and duplicate email path passing.

### ✅ HU-04 — Track Visit Metadata (DONE)
**Coordinates:**
- Branch: `feat/hu4-track-visit-metadata`
- Key Files:
  - `backend-api/db/migrate/20260209000100_create_visits.rb`
  - `backend-api/app/models/visit.rb`
  - `backend-api/app/jobs/track_visit_job.rb`
  - `backend-api/app/controllers/redirects_controller.rb`
  - `backend-api/spec/requests/redirects_spec.rb`
**Evidence:**
- On redirect, metadata is enqueued asynchronously with:
  - `ip_address`
  - `user_agent`
  - `visited_at`
- Redirect behavior remains `301` for valid slugs and `404` for missing slugs.
- Request specs validate both redirect behavior and async tracking enqueue.

### ✅ HU-05 — Link Dashboard & Stats (DONE)
**Coordinates:**
- Branch: `feat/hu5-link-dashboard-stats`
- Key Files:
  - `backend-api/app/controllers/links_stats_controller.rb`
  - `backend-api/spec/requests/links_stats_spec.rb`
  - `backend-api/db/migrate/20260209000200_add_user_to_links.rb`
  - `backend-api/app/models/user.rb`
  - `backend-api/app/models/link.rb`
  - `backend-api/app/controllers/application_controller.rb`
  - `backend-api/config/routes.rb`
**Evidence:**
- Endpoint implemented: `GET /links/stats` (auth required with Bearer token).
- Stats include:
  - `total_clicks`
  - `unique_visits`
  - `recurrent_visits`
- Results are limited to top 100 links.
- Request specs cover:
  - `401` when auth header is missing.
  - user scoping (only current user links returned).
  - result cap at 100 items.

## 8. Next Immediate Action (Single Step)
Close remaining global challenge gaps (auth for create links, links CRUD + pagination, API key, frontend dashboard UI).
