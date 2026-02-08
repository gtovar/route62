# ADR-002: Authentication Strategy for HU-03

- Status: Accepted
- Date: 2026-02-08

## Context
HU-03 requires user signup and automatic login after successful registration in
an API-only Rails backend.

## Decision
Issue a JWT token after successful `POST /signup` instead of creating a
cookie-based session.

## Rationale
- API-only flow fits token-based auth naturally.
- Keeps signup response self-contained for frontend consumption.
- Avoids adding session middleware complexity at this stage.

## Consequences
- Clients must store and send the token in subsequent authenticated requests.
- Token expiration and refresh strategy will need expansion in future stories.
