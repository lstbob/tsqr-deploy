# TSQR Platform — Local Deployment

This project contains everything needed to run the full TSQR microservice architecture locally via Docker Compose.

## Architecture

```
Browser → tsqr-ui:3000 → tsqr-gateway:8080 → tsqr-tool-lib:8080 → postgres:5432
Browser → tsqr-support:4200 (static SPA via nginx)
```

| Service | Tech | Port (host) | Description |
|---------|------|-------------|-------------|
| `postgres` | PostgreSQL 16 | 5432 | Database |
| `tool-lib` | .NET 9 | — | Tool library API (internal) |
| `gateway` | .NET 9 | 5000 | API Gateway (auth, rate-limiting, proxy) |
| `ui` | Next.js 16 | 3000 | Main user interface |
| `support` | Angular 20 | 4200 | Support portal |

## Prerequisites

- [Docker](https://docs.docker.com/get-docker/)
- [Docker Compose](https://docs.docker.com/compose/install/) (v2+)

## Quick Start

```bash
# From the tsqr-deploy directory
cd tsqr-deploy

# Build and start all services
docker compose up --build

# Run in detached mode
docker compose up --build -d
```

## Access

| Service | URL |
|---------|-----|
| Main UI | http://localhost:3000 |
| Support Portal | http://localhost:4200 |
| Gateway API | http://localhost:5000 |
| Tool Library API (direct) | http://localhost:5000/api/tools (via gateway) |
| Health Check | http://localhost:5000/api/gateway/status |

## Stopping

```bash
# Stop all services
docker compose down

# Stop and remove volumes (deletes database data)
docker compose down -v
```

## Viewing Logs

```bash
# All services
docker compose logs -f

# Specific service
docker compose logs -f gateway
docker compose logs -f tool-lib
docker compose logs -f ui
```

## Configuration

Copy `.env.example` to `.env` and adjust values as needed:

```bash
cp .env.example .env
```

Key environment variables:

| Variable | Default | Description |
|----------|---------|-------------|
| `POSTGRES_PASSWORD` | postgres | Database password |
| `ConnectionStrings__DefaultConnection` | (set) | Tool-lib DB connection string |
| `ToolLibBaseUrl` | http://tool-lib:8080 | Gateway → Tool-lib URL |
| `API_URL` | http://gateway:8080 | Next.js → Gateway URL |

## Next Steps

- The gateway currently has basic `RequestHandlingMiddleware` and `GatewayController` stubs. Add JWT authentication and rate limiting before production use.
- The `tsqr-support` Angular app is served as static files — no backend integration is wired yet.
- For production, consider adding `restart: unless-stopped` to services and using a reverse proxy like Traefik or Caddy for TLS termination.
