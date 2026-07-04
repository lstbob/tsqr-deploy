#!/usr/bin/env bash
set -euo pipefail

DIR="$(cd "$(dirname "$0")" && pwd)"
cd "$DIR"

if [ ! -f .env ]; then
  echo "Creating .env from .env.example..."
  echo "WARNING: Edit .env and replace all CHANGE_ME values before running again."
  cp .env.example .env
  exit 1
fi

echo "Starting all TSQR services..."
docker compose up --build -d

echo ""
echo "Services starting. Health check:"
echo "  Gateway:  http://localhost:5000"
echo "  Support:  http://localhost:4200"
echo "  Postgres: 127.0.0.1:5432"
echo ""
echo "Verify the gateway is up:"
echo "  curl -sf http://localhost:5000/  (should return the landing page)"
echo "  curl -sf http://localhost:5000/api/auth/health  (should return {status:ok})"
echo ""
echo "Default admin: admin@townssquare.local / ChangeMe!123"
echo "Log in at: http://localhost:5000/login"