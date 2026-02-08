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
docker compose exec backend bundle exec rspec spec/services/shortener_service_spec.rb
```

### Option B: backend container is not running
```bash
docker compose run --rm backend bundle exec rspec spec/services/shortener_service_spec.rb
```

### Run all backend tests
```bash
docker compose run --rm backend bundle exec rspec
```

- Use `exec` when services are already up (`docker compose up`).
- Use `run --rm` for one-off test execution without depending on a running container.

## Current Status
- Internal health check route available at `GET /_internal/up`.

## Next Likely Steps
- Implement Link model and Base62 encoder.
- Add API routes for create + redirect.
- Wire frontend form to the API.
- Add cache lookups in Redis.
