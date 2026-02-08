# Testing Guide

## Run backend tests (Docker)

### Recommended (daily development): backend container already running
```bash
docker compose exec -e RAILS_ENV=test backend bundle exec rspec spec/services/shortener_service_spec.rb
```

### Fallback (fresh one-off container)
```bash
docker compose run --rm backend bundle exec rspec spec/services/shortener_service_spec.rb
```

### Run all backend tests (recommended)
```bash
docker compose exec -e RAILS_ENV=test backend bundle exec rspec
```

### Run all backend tests (fresh one-off container)
```bash
docker compose run --rm backend bundle exec rspec
```

- Use `exec` as default during feature development.
- Use `run --rm` when you need an isolated clean run.

## DX shortcut with Makefile

Location:

```bash
ops/Makefile
```

Run:

```bash
make -f ops/Makefile test-backend
```

Other useful targets:

```bash
make -f ops/Makefile test-shortener
```
