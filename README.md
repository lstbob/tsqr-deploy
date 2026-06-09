# TSQR Platform — Local Deployment

Docker Compose orchestration for the full TSQR microservice architecture.

## Architecture

```
                         ┌──────────────────────────────────────────────┐
                         │           tsqr-gateway (port 5000)          │
                         │         YARP Reverse Proxy (single entry)   │
                         └──────┬──────────────────┬───────────────────┘
                                │                  │
                    ┌───────────▼────┐    ┌────────▼──────────┐
                    │   /api/*       │    │   /* (everything) │
                    │  → tool-lib    │    │   → tsqr-ui       │
                    └───────────┬────┘    └────────────────────┘
                                │
              ┌─────────────────▼──────────────────┐
              │         tsqr-tool-lib               │
              │   .NET 9 + Dapper + PostgreSQL      │
              └─────────────────┬───────────────────┘
                                │
                    ┌───────────▼────────────┐
                    │      postgres:16        │
                    │   tsqr_tool_library DB  │
                    └────────────────────────┘

Browser → tsqr-support:4200 (standalone static SPA via nginx)
```

| Service | Tech | Host Port | Internal | Description |
|---------|------|-----------|----------|-------------|
| `gateway` | .NET 10 + YARP | **5000** | 8080 | **Single entry point** — proxies `/api/*` to tool-lib, `/*` to UI |
| `ui` | Next.js 16 / React 19 | — | 3000 | Main user interface (internal, accessed via gateway) |
| `tool-lib` | .NET 9 / Dapper / MediatR | — | 8080 | Tool library API (internal, not exposed) |
| `postgres` | PostgreSQL 16 | 5432 | 5432 | Database (exposed for admin tools only) |
| `support` | Angular 20 / nginx | **4200** | 80 | Static support portal (standalone access) |

## Request Flow

```
Browser → localhost:5000/          → YARP spa → tsqr-ui:3000  → serves HTML page
Browser → localhost:5000/api/tools → YARP tool-api → tool-lib:8080 → postgres
  (server-side)                    → ui fetches API_URL=http://gateway:8080/api/...
Browser → localhost:4200           → tsqr-support:80 → nginx serves static SPA
```

## Prerequisites

- [Docker](https://docs.docker.com/get-docker/)
- [Docker Compose](https://docs.docker.com/compose/install/) (v2+)

## Quick Start

```bash
cd tsqr-deploy
docker compose up --build
```

## Access

| URL | What |
|-----|------|
| http://localhost:5000 | **Main UI** — full TSQR application (via gateway) |
| http://localhost:5000/api/tools | Tool library API (via gateway) |
| http://localhost:5000/api/dashboard/stats | Dashboard stats API (via gateway) |
| http://localhost:4200 | **Support Portal** — standalone static site |
| http://localhost:5432 | PostgreSQL (direct, for admin tools) |

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
docker compose logs -f ui
```

## Configuration

Key environment variables (set in `docker-compose.yml`):

| Variable | Description |
|----------|-------------|
| `ConnectionStrings__DefaultConnection` | Tool-lib → PostgreSQL connection |
| `ASPNETCORE_ENVIRONMENT` | Gateway config profile (set to `Docker`) |
| `Jwt__Key` | JWT signing key for gateway auth |
| `API_URL` | Next.js → Gateway URL for server-side API calls |
