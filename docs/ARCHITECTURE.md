# Architecture

This system is a classic split-stack URL shortener:
- **Frontend**: React + Vite SPA
- **Backend**: Ruby on Rails API
- **Storage**: PostgreSQL
- **Cache**: Redis

## High-Level Flow

**Create short link**
1. Client submits a long URL to the API.
2. API persists the link in PostgreSQL, receives the numeric ID.
3. API encodes the ID into a Base62 code using the shuffled alphabet.
4. API returns the short code (and optionally the full short URL).

**Redirect**
1. Client requests `/:code`.
2. API checks Redis for `code -> long_url`.
3. On cache miss, API looks up the database, caches the result, and redirects.

## Components and Responsibilities

- **Rails API**
  - Link creation and lookup
  - Base62 encode/decode
  - Redirect responses
  - Analytics ingestion (planned)

- **PostgreSQL**
  - Source of truth for links and visits
  - Generates auto-increment IDs

- **Redis**
  - Hot-path redirect lookups
  - Optional counters / top links (planned)

- **React SPA**
  - User-facing form and results view
  - Talks to Rails API

## Data Model (Planned)

- `links`
  - `id` (PK)
  - `long_url`
  - `code` (optional stored, or computed)
  - `created_at`

- `visits` (optional)
  - `id` (PK)
  - `link_id` (FK)
  - `visited_at`
  - `ip`, `user_agent` (optional)

## Non-Goals
- Cryptographic secrecy of URLs
- Custom domains and vanity codes (future work)

## Current Status
- No API routes beyond health check.
- Models and controllers are not implemented yet.
