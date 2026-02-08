# URL Shortener Challenge

## Description
You can use this project to generate short links from long URLs with a Rails
API + React frontend stack. The goal is to provide fast link creation today and
prepare the system for scalable redirects and analytics.

## Technical Requirements
- Docker Engine (recommended: `24.x` or newer)
- Docker Compose plugin (recommended: `2.x` or newer)

## Quick Start (<= 2 minutes)
```bash
cp .env.example .env
docker compose up --build -d
docker compose exec backend bundle exec rails db:create db:migrate
```

## Basic Usage (Smoke Test)
Health check:
```bash
curl -i http://localhost:3000/_internal/up
```
Expected result: `HTTP/1.1 200 OK`.

Create short link:
```bash
curl -i -X POST http://localhost:3000/links \
  -H "Content-Type: application/json" \
  -d '{"link":{"long_url":"https://example.com/very/long/path"}}'
```

Run backend tests:
```bash
make -f ops/Makefile test-backend
```

## Extended Documentation
| Document | Description |
| --- | --- |
| `docs/ARCHITECTURE.md` | Architecture and key design decisions. |
| `docs/API_REFERENCE.md` | Endpoint contracts and response codes. |
| `docs/testing.md` | How to run backend tests with Docker and Makefile shortcuts. |
| `ops/Makefile` | Developer shortcuts for backend test commands. |
| `docs/adr/001-shortening-algorithm.md` | ADR for Base62 + shuffled alphabet decision. |
| `docs/adr/002-auth-strategy.md` | ADR for HU-03 authentication strategy (JWT on signup). |
| `docs/adr/003-visit-tracking-strategy.md` | ADR for HU-04 async visit tracking strategy. |
| `docs/REENTRY.md` | Reentry guide for fast context recovery. |
| `Sprint_Log.md` | Daily story closure and sprint progress log. |
| `PROJECT_STATE.md` | Current implementation status by user story. |

## Contributing
- Create feature branches from `develop` (example: `feat/hu1-create-short-link`).
- Use semantic commits (example: `feat(hu1): ...`).
- Open PRs targeting `develop`, never push directly to `main`.

## License
Private repository. All rights reserved unless explicitly stated otherwise.
