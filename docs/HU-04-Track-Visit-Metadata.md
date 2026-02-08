# HU-04: Track Visit Metadata

- Epic: Epic 3 - Analytics & Management
- Story: As an Active User, I want the system to record details of every click on my links, so that I can analyze my audience.
- Value: Business intelligence.

## Acceptance Criteria

1. Technical Check: Upon redirection, the system must asynchronously record:
   - IP Address.
   - User Agent (Browser/OS).
   - Timestamp.

2. Performance Constraint:
   - Tracking must not add significant latency to the redirect (use Sidekiq/Background Job) `[Source 417]`.
