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
key and accepts only the `kid` values listed in `JWT_PUBLIC_KEYS` (or the single
`JWT_PUBLIC_KEY_BASE64` when no ring is configured).

## Generating a JWT signing key pair

```sh
openssl genpkey -algorithm RSA -pkeyopt rsa_keygen_bits:2048 -out jwt-private.pem
openssl rsa -in jwt-private.pem -pubout -out jwt-public.pem
base64 -w0 jwt-private.pem > jwt-private.b64
base64 -w0 jwt-public.pem > jwt-public.b64
```

Paste the base64 contents into `.env`. Production should mount the private key
from a secret store instead of an environment variable.

## Rotating the JWT signing key

Autheo publishes every public key in the ring at
`https://<gateway>/.well-known/jwks.json`. Rotate without invalidating access
tokens that were issued just before the switch:

1. Generate the new key pair (`jwt-v2-private.pem` / `jwt-v2-public.pem`).
2. Add the new public key to `JWT_PUBLIC_KEYS` on every service, keeping the old
   one. Deploy the verifiers first:
   ```sh
   JWT_PUBLIC_KEYS="tsqr-autheo-v1=$(cat jwt-v1-public.b64);tsqr-autheo-v2=$(cat jwt-v2-public.b64)"
   ```
3. Change autheo's `JWT_PRIVATE_KEY_BASE64` to the new private key, set
   `JWT_KEY_ID=tsqr-autheo-v2`, and set `JWT_PUBLIC_KEY_BASE64` to the new public
   key. Keep both keys in `JWT_PUBLIC_KEYS`. Deploy autheo.
4. Verify:
   - New logins carry `kid=tsqr-autheo-v2`.
   - A token captured before the switch still authenticates.
   - `/.well-known/jwks.json` lists both keys.
5. After the 15-minute access-token lifetime, remove the old key from
   `JWT_PUBLIC_KEYS` and deploy the verifiers and autheo again.

Docker Compose passes `JWT_PUBLIC_KEYS` to autheo and every verifier as
`Jwt__PublicKeys`. An empty value uses the single-key compatibility path.

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
