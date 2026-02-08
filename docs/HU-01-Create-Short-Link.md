# HU-01: Create Short Link

- Story: As an Active User, I want to input a long URL and receive a short URL, so that I can share it easily without taking up space.
- Value: Core value proposition. High priority.

## Acceptance Criteria

1. Scenario: Successful shortening.
   - Given I am logged in and submit `https://google.com/very/long/path`.
   - When I click `Shorten`.
   - Then the system generates a unique Base62 slug (e.g., `abc`) and returns the full short URL.

2. Scenario: Invalid URL.
   - Given I submit `not-a-url`.
   - When I click `Shorten`.
   - Then the system returns an error message `Invalid URL format`.

3. Technical Constraint (from Source 407):
   - The generated slug must use the `Shuffled Alphabet` configuration to ensure non-predictability.
