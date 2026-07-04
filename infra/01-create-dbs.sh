#!/bin/bash
# Creates the three TSQR databases (tool library, autheo, support) on first
# run. The postgres official image runs every file in docker-entrypoint-initdb.d
# alphabetically; this script must sort first so the schema files can use the
# databases it creates.
set -e

echo "Creating TSQR databases..."

for db in tsqr_tool_library tsqr_autheo tsqr_support tsqr_identity; do
  psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname postgres <<-EOSQL
    SELECT 'CREATE DATABASE $db'
    WHERE NOT EXISTS (SELECT FROM pg_database WHERE datname = '$db')\gexec
    GRANT ALL PRIVILEGES ON DATABASE $db TO "$POSTGRES_USER";
EOSQL
done

echo "TSQR databases created."