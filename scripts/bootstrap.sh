#!/usr/bin/env bash

set -euo pipefail

readonly ENV_FILE="${SW_CONSULTING_EDGE_ENV_FILE:-edge.env}"

fail() { printf '%s\n' "$1" >&2; exit 1; }
[[ -f "$ENV_FILE" ]] || fail "Environment file not found: $ENV_FILE"

set -a
# shellcheck disable=SC1090
source "$ENV_FILE"
set +a

readonly PROJECT_NAME="${COMPOSE_PROJECT_NAME:-sw-consulting-edge}"
readonly CERTIFICATE_DIR="${SW_CONSULTING_EDGE_CERTIFICATE_DIR:-/srv/sw-consulting-edge/certificate}"
readonly CERTIFICATE="$CERTIFICATE_DIR/s.crt"
readonly PRIVATE_KEY="$CERTIFICATE_DIR/s.key"

[[ -f "$CERTIFICATE" && -f "$PRIVATE_KEY" ]] \
  || fail "Wildcard TLS files s.crt and s.key are required in $CERTIFICATE_DIR"

for hostname in klinok.sw.consulting sarafan.sw.consulting; do
  openssl x509 -in "$CERTIFICATE" -noout -checkhost "$hostname" >/dev/null \
    || fail "Certificate does not cover $hostname: $CERTIFICATE"
done

readonly COMPOSE=(docker compose --project-name "$PROJECT_NAME" --env-file "$ENV_FILE" -f docker-compose.yml)
"${COMPOSE[@]}" config --quiet
"${COMPOSE[@]}" pull
"${COMPOSE[@]}" up -d --wait
"${COMPOSE[@]}" ps
