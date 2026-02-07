# HU-03: User Registration

- Epic: Epic 2 - User Management
- Story: As a Visitor, I want to create an account providing name, email, and password, so that I can become an Active User.

## Acceptance Criteria

1. Scenario: Unique Email.
   - In case that the email is already taken, the system must block the registration `[Source 259]`.

2. Scenario: Successful Sign-up.
   - When data is valid, the system creates the user and logs them in automatically.
