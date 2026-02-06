# URL Shortener Challenge

High-performance URL shortening system designed with **Indirection** architecture to scale redirections and analytics.

## 🚀 Architecture Stack

| Component | Technology | Technical Justification |
| --- | --- | --- |
| Backend | Ruby on Rails 8 (API) | Robust concurrency handling and a mature ORM for links and analytics. |
| Frontend | React + Vite (TypeScript) | Reactive SPA for a fluid user experience. |
| Storage | PostgreSQL | Atomic ID generation and ACID consistency. |
| Caching | Redis | O(1) lookup for high-traffic redirections. |

## 🧮 The Core Algorithm (Base62 Strategy)

We convert the numeric `ID` into Base62 to produce short, readable codes. To avoid predictability, we use a **Shuffled Alphabet** that keeps reversibility while obfuscating sequential patterns. See `docs/ALGORITHM_DEEP_DIVE.md` for the mathematical details.

## 🛠️ Prerequisites

- Docker
- Docker Compose

## ⚡ Quick Start (Onboarding < 2 min)

```bash
cp .env.example .env
docker-compose up --build
rails db:create db:migrate
```

## 📚 Documentation Index

| Document | Description |
| --- | --- |
| `docs/ARCHITECTURE.md` | Architecture and key design decisions. |
| `docs/API_REFERENCE.md` | Endpoint contracts and response codes. |
| `docs/REENTRY.md` | Reentry guide to restore context quickly. |

## 🧭 Project State

Status: Development
