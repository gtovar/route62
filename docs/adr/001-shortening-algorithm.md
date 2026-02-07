# ADR-001: Shortening Algorithm for HU-01

- Status: Accepted
- Date: 2026-02-07

## Context
HU-01 requires converting database IDs into short URL slugs while reducing sequential predictability.

## Decision
Use a Base62 encoder/decoder implemented in `ShortenerService` with a fixed shuffled alphabet.

## Consequences
- Pros:
  - Fast and deterministic slug generation.
  - Reversible encoding for standard generated slugs.
  - Better obfuscation than standard ordered Base62 alphabet.
- Cons:
  - This is obfuscation, not cryptographic security.
  - Data integrity still depends on DB uniqueness constraints.

## Implementation Notes
- Service file: `backend-api/app/services/shortener_service.rb`
- Primary tests: `backend-api/spec/services/shortener_service_spec.rb`
