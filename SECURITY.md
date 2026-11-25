# Security & secret rotation

All runtime secrets are now read from environment variables via an untracked
`.env` file (see `.env.example`). No secrets should live in committed source or
config. This document lists the secrets that were **previously committed in
plaintext** and therefore **must be rotated** — they are in git history and must
be treated as compromised.

## Secrets to rotate

| Secret | Was hardcoded in | Now sourced from | Action |
|---|---|---|---|
| JWT signing key (HMAC, retired) | `tsqr-gateway` `appsettings.json`, `tsqr-tool-lib` `appsettings.json`, `docker-compose.yml` | Replaced by RS256: `JWT_PRIVATE_KEY_BASE64` (autheo only) and `JWT_PUBLIC_KEY_BASE64` (all verifiers) | The old HMAC key is no longer used. The old value `ThisIsASecretKeyForTsqrIdentity_...` (and the compose `dev-key-not-for-production-use-32chars!`) are burned and must not be reused. |
| Postgres credentials | `docker-compose.yml`, `tsqr-tool-lib` `appsettings.json` | `POSTGRES_USER` / `POSTGRES_PASSWORD` / `TOOL_LIB_CONNECTION` env (`.env`) | Set a strong DB password in `.env`; rotate the DB role's password if the old `postgres/postgres` was ever used on a real instance. |

Autheo holds the only private key. Every other service validates with the public
key and enforces the active `kid` from `JWT_KEY_ID`.

## Generating a JWT signing key pair

```sh
openssl genpkey -algorithm RSA -pkeyopt rsa_keygen_bits:2048 -out jwt-private.pem
openssl rsa -in jwt-private.pem -pubout -out jwt-public.pem
base64 -w0 jwt-private.pem > jwt-private.b64
base64 -w0 jwt-public.pem > jwt-public.b64
```

Paste the base64 contents into `.env`. Production should mount the private key
from a secret store instead of an environment variable.

## First-time setup

```sh
cp .env.example .env
# edit .env: replace every CHANGE_ME value (DB password + RSA key pair)
docker compose up --build
```

`.env` is gitignored — never commit it.

## Notes / known follow-ups (not addressed here)

- Autheo fails fast on startup if the RSA private key is missing or invalid;
  verifiers fail fast if the RSA public key is missing or invalid. Tool-lib also
  fails fast when its connection string is missing — all intentional (fail
  closed).
- Postgres is published on `127.0.0.1:5432` only (host-local admin access), not
  on all interfaces.
- Pre-existing, out of scope for this security pass: the compose file has a
  `depends_on` cycle (`gateway → ui → gateway`) that blocks `docker compose up`;
  drop one side of the dependency to resolve.
- nginx terminates plain HTTP; TLS is expected to be terminated by an upstream
  ingress. Add HSTS there.
