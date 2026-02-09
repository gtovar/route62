# ADR-003: Visit Tracking Strategy for HU-04

- Status: Accepted
- Date: 2026-02-09

## Context
HU-04 requires capturing click metadata (IP address, user agent, timestamp)
without adding noticeable latency to redirects.

## Decision
Use `TrackVisitJob` with `perform_later` from `RedirectsController#show` to
persist visit metadata asynchronously in the `visits` table.

## Rationale
- Preserves fast redirect response (`301`) on hot path.
- Keeps tracking logic isolated from controller response timing.
- Creates durable analytics data needed for HU-05 dashboard and stats.

## Consequences
- Requires active job processing infrastructure in deployed environments.
- Redirect success does not guarantee immediate visit row persistence.
