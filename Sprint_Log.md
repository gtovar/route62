# Sprint Log

## 2026-02-07

### HU-01 — Create Short Link (Closed)
- Implemented `ShortenerService` with shuffled Base62 encode/decode.
- Added service specs for encode/decode and edge cases.
- Implemented `POST /links` create flow with strong params.
- Added `Link` model validations for `long_url` format and slug uniqueness.
- Added request specs for success, invalid URL, and collision error path.
- Added testing documentation (`docs/testing.md`) and Makefile test shortcuts in `ops/Makefile`.
