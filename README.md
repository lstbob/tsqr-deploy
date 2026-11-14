# TSQR Platform — Local Deployment

Docker Compose orchestration for the full TSQR microservice architecture.

## Architecture

```
                              ┌──────────────────────────────────────────────┐
                              │           tsqr-gateway (port 5000)          │
                              │     YARP Reverse Proxy (single entry)       │
                              └──┬──────────┬──────────┬──────────┬────────┘
                                 │          │          │          │
                          ┌──────▼──┐  ┌────▼────┐  ┌─▼──────┐  ┌▼──────────┐
                          │ /api/auth │  │ /api/... │  │ /api/   │  │ /* (SPA)  │
                          │  autheo   │  │ tool-lib │  │ support │  │  tsqr-ui  │
                          └──────┬──┘  └────┬────┘  └─┬──────┘  └───────────┘
                                 │          │          │
                              ┌──▼──────────▼──────────▼──┐
                              │      postgres:16           │
                              │  tsqr_tool_library        │
                              │  tsqr_autheo              │
                              │  tsqr_support             │
                              └───────────────────────────┘

  Browser → tsqr-support-ui:4200 (Angular SPA + nginx, proxied to tsqr-support backend)
```

| Service | Tech | Host Port | Internal | Description |
|---------|------|-----------|----------|-------------|
| `gateway` | .NET 10 + YARP | **5000** | 8080 | **Single entry point** — routes to autheo, tool-lib, support, UI |
| `ui` | Next.js 16 / React 19 | — | 3000 | Main user interface (internal, accessed via gateway) |
| `autheo` | .NET 10 / Dapper | — | 8080 | Authentication service — JWT issuance + refresh |
| `tool-lib` | .NET 10 / Dapper | — | 8080 | Tool library API (internal, not exposed) |
| `support` | .NET 10 / Dapper | — | 8080 | Support backend — tickets, uptime, contact (internal) |
| `support-ui` | Angular 20 / nginx | **4200** | 80 | Support portal frontend (standalone, proxies /api to support backend) |
| `postgres` | PostgreSQL 16 | 5432 | 5432 | Database — 3 databases (exposed for admin tools only) |

## Request Flow

```
Browser → localhost:5000/             → gateway spa → tsqr-ui:3000  → serves HTML
Browser → localhost:5000/api/auth/*   → gateway → autheo:8080       → tsqr_autheo DB
Browser → localhost:5000/api/tools    → gateway → tool-lib:8080     → tsqr_tool_library DB
Browser → localhost:5000/api/bff/*    → gateway BffController (aggregation)
Browser → localhost:4200              → nginx → tsqr-support-ui SPA
Browser → localhost:4200/api/*        → nginx proxy → tsqr-support:8080 → tsqr_support DB
```

## Prerequisites

- [Docker](https://docs.docker.com/get-docker/)
- [Docker Compose](https://docs.docker.com/compose/install/) (v2+)

## Quick Start

```bash
cd tsqr-deploy
./up.sh        # creates .env from template, builds, starts all services
```

Or manually:

```bash
cp .env.example .env   # then edit CHANGE_ME values
docker compose up --build -d
```

## CI

Each repository has a small `.github/workflows/ci.yml` caller that invokes one
of the reusable workflows in this repository:

- `dotnet-ci.yml` — restores, builds, and tests a .NET solution, packs
  `TSQR.Common` locally, and optionally builds/pushes a Docker image.
- `node-ci.yml` — installs, optionally lints/tests, builds a Node app, and
  optionally builds/pushes a Docker image.
- `ci.yml` — validates this repository's Docker Compose configuration.

Images are built on pull requests and pushed to GHCR only on pushes to each
repository's default branch for services that opt in with `push-image: true`.

## Access

| URL | What |
|-----|------|
| http://localhost:5000 | **Landing page** — public marketing portal |
| http://localhost:5000/login | Login page (admin@townssquare.local / ChangeMe!123) |
| http://localhost:5000/portal | **Portal hub** — authenticated tool library management |
| http://localhost:5000/api/auth/health | Autheo health check |
| http://localhost:4200 | **Support Portal** — tickets, uptime, contact (standalone) |
| http://localhost:5432 | PostgreSQL (direct, for admin tools) |

## Default admin account

- Email: `admin@townssquare.local`
- Password: `ChangeMe!123`
- Role: `Admin`

**Rotate this password after first login** via the portal's change-password feature.

## Upgrading an existing database volume

The files in `infra/` are PostgreSQL init scripts: they run only when the
`pgdata` volume is first created. If you already have a volume from an older
checkout, apply the idempotent retrofit scripts after `docker compose up`:

```bash
docker compose exec -T postgres sh -c '
  for f in \
    /docker-entrypoint-initdb.d/08-tool-library-community.sql \
    /docker-entrypoint-initdb.d/10-tool-library-loans-latefee.sql \
    /docker-entrypoint-initdb.d/11-tool-library-policies.sql \
    /docker-entrypoint-initdb.d/12-tool-library-outbox.sql \
    /docker-entrypoint-initdb.d/13-support-community.sql \
    /docker-entrypoint-initdb.d/14-communities-hardening.sql \
    /docker-entrypoint-initdb.d/15-identity-audit.sql \
    /docker-entrypoint-initdb.d/16-support-incidents.sql \
    /docker-entrypoint-initdb.d/17-support-tickets.sql; do
    psql -v ON_ERROR_STOP=1 -U "$POSTGRES_USER" -d postgres -f "$f"
  done
'
```

These scripts only add missing columns, indexes, constraints and tables and
seed missing default policies; they never drop data and can be run more than
once.

## Stopping

```bash
docker compose down       # stop services
docker compose down -v    # stop + delete database data
```

## Viewing Logs

```bash
docker compose logs -f              # all services
docker compose logs -f gateway       # specific service
docker compose logs -f tool-lib
docker compose logs -f autheo
docker compose logs -f support
docker compose logs -f ui
```

## Configuration

Key environment variables (set in `.env`):

| Variable | Description |
|----------|-------------|
| `POSTGRES_USER` / `POSTGRES_PASSWORD` | PostgreSQL superuser credentials |
| `TOOL_LIB_CONNECTION` | tool-lib → PostgreSQL connection string |
| `AUTHEO_CONNECTION` | autheo → PostgreSQL connection string |
| `SUPPORT_CONNECTION` | support → PostgreSQL connection string |
| `JWT_KEY` | Shared JWT signing key — **MUST be identical** across gateway, tool-lib, autheo, identity, support |
| `INTERNAL_API_KEY` | Shared service-to-service key for identity → autheo email-change calls |
| `API_URL` | Next.js → Gateway URL (internal Docker network) |
| `NEXT_PUBLIC_SUPPORT_URL` | Support portal URL for the Support tab link in tsqr-ui |