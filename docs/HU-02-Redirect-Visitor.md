# HU-02: Redirect Visitor (The Lookup)

- Epic: Epic 1 - URL Shortening Core
- Story: As a Visitor, I want to be redirected to the original URL when I visit a short link, so that I can access the content seamlessly.
- Value: The functionality that makes the link work.

## Acceptance Criteria

1. Scenario: Valid Redirect.
   - Given a short link `http://app.com/abc` exists.
   - When I navigate to it.
   - Then the system responds with HTTP `301` and the `Location` header set to the original URL.

2. Scenario: 404 Not Found.
   - Given a short link `http://app.com/xyz` does not exist.
   - When I navigate to it.
   - Then the system shows a custom `404` error page.
