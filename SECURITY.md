# Security & secret rotation

All runtime secrets are now read from environment variables via an untracked
`.env` file (see `.env.example`). No secrets should live in committed source or
config. This document lists the secrets that were **previously committed in
plaintext** and therefore **must be rotated** — they are in git history and must
be treated as compromised.

## Secrets to rotate

| Secret | Was hardcoded in | Now sourced from | Action |
|---|---|---|---|
| JWT signing key (HMAC) | `tsqr-gateway` `appsettings.json`, `tsqr-tool-lib` `appsettings.json`, `docker-compose.yml` | `JWT_KEY` env (`.env`) → `Jwt__Key` for both gateway and tool-lib | **Generate a new random key** (>= 32 bytes) and set it in `.env`. The old value `ThisIsASecretKeyForTsqrIdentity_...` (and the compose `dev-key-not-for-production-use-32chars!`) are burned. |
| Postgres credentials | `docker-compose.yml`, `tsqr-tool-lib` `appsettings.json` | `POSTGRES_USER` / `POSTGRES_PASSWORD` / `TOOL_LIB_CONNECTION` env (`.env`) | Set a strong DB password in `.env`; rotate the DB role's password if the old `postgres/postgres` was ever used on a real instance. |

The gateway and tool-lib share one symmetric signing key, so `JWT_KEY` must be
**identical** for both services (the compose file wires both from the same var).

## Generating a JWT key

```sh
openssl rand -base64 48
```

## First-time setup

```sh
cp .env.example .env
# edit .env: replace every CHANGE_ME value (DB password + JWT_KEY)
docker compose up --build
```

`.env` is gitignored — never commit it.

## Notes / known follow-ups (not addressed here)

- Both .NET services fail fast on startup if `Jwt__Key` (and tool-lib's
  connection string) are not provided — this is intentional (fail closed).
- Postgres is published on `127.0.0.1:5432` only (host-local admin access), not
  on all interfaces.
- Pre-existing, out of scope for this security pass: the compose file has a
  `depends_on` cycle (`gateway → ui → gateway`) that blocks `docker compose up`;
  drop one side of the dependency to resolve.
- nginx terminates plain HTTP; TLS is expected to be terminated by an upstream
  ingress. Add HSTS there.
