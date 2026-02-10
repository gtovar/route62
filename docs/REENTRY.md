# Reentry Guide

## What This Repo Is
URL shortener challenge with a Rails API + React SPA, backed by PostgreSQL and Redis.

## Key Locations
- Backend: `backend-api/`
- Frontend: `frontend-app/`
- Docker Compose: `docker-compose.yml`
- Docs: `docs/`

## Quick Start (Local)

```bash
cp .env.example .env
docker-compose up --build
```

Rails database setup (in another terminal):

```bash
docker-compose exec backend rails db:create db:migrate
```

## Local Ports
- Backend API: `http://localhost:3000`
- Frontend SPA: `http://localhost:3001`
- PostgreSQL: `localhost:5432`
- Redis: `localhost:6379`

## Run Tests (Docker)

### Option A: backend container is already running
```bash
docker compose exec -e RAILS_ENV=test backend bundle exec rspec spec/services/shortener_service_spec.rb
```

### Option B: backend container is not running
```bash
docker compose run --rm backend bundle exec rspec spec/services/shortener_service_spec.rb
```

### Run all backend tests
```bash
docker compose exec -e RAILS_ENV=test backend bundle exec rspec
```

- Use `exec` for daily development when services are up.
- Use `run --rm` only for one-off isolated runs.

## Current Status
- Health check: `GET /_internal/up`
- Link creation: `POST /links` (auth required: Bearer or ApiKey)
- Link management:
  - `GET /links` (paginated)
  - `PATCH /links/:id`
  - `DELETE /links/:id`
- Redirect: `GET /:slug`
- User signup: `POST /signup`
- User login: `POST /login`
- API key rotation: `POST /api_keys/rotate` (JWT required)
- Visit tracking: async enqueue on redirect via `TrackVisitJob`
- Link stats dashboard API: `GET /links/stats` (Bearer/ApiKey)
  - Includes device/OS/user-agent breakdowns with percentages
- Global Top 100 API: `GET /links/top` (public)

## Environment Notes
- No new env vars were required for HU-03.
- JWT tokens use `Rails.application.secret_key_base`.
- No new env vars were required for HU-04.
- No new env vars were required for HU-05.

## Next Likely Steps
- Final delivery hardening:
  - finalize delivery verification checklist,
  - run final CI gate before merge,
  - align repo docs with implemented frontend (`link-spark`) and API contracts.
