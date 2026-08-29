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
readonly CERTIFICATES_DIR="${SW_CONSULTING_EDGE_CERTIFICATES_DIR:-/srv/sw-consulting-edge/certificates}"

for application in klinok sarafan; do
  certificate="$CERTIFICATES_DIR/$application/tls.crt"
  private_key="$CERTIFICATES_DIR/$application/tls.key"
  [[ -f "$certificate" && -f "$private_key" ]] || fail "TLS files tls.crt and tls.key are required in $CERTIFICATES_DIR/$application"
  openssl x509 -in "$certificate" -noout -checkhost "$application.sw.consulting" >/dev/null \
    || fail "Certificate does not cover $application.sw.consulting: $certificate"
done

readonly COMPOSE=(docker compose --project-name "$PROJECT_NAME" --env-file "$ENV_FILE" -f docker-compose.yml)
"${COMPOSE[@]}" config --quiet
"${COMPOSE[@]}" pull
"${COMPOSE[@]}" up -d --wait
"${COMPOSE[@]}" ps
