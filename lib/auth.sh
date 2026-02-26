#!/usr/bin/env bash
# Shared authentication and API helper functions.
# Source this file from any sample script: source "$(dirname "$0")/../lib/auth.sh"

set -euo pipefail

# Load .env if present
ENV_FILE="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/.env"
if [[ -f "$ENV_FILE" ]]; then
    set -a
    source "$ENV_FILE"
    set +a
fi

VANILLA_API_URL="${VANILLA_API_URL:-http://localhost:4000}"
VANILLA_EMAIL="${VANILLA_EMAIL:?Set VANILLA_EMAIL}"
VANILLA_PASSWORD="${VANILLA_PASSWORD:?Set VANILLA_PASSWORD}"
VANILLA_ACCOUNT_ID="${VANILLA_ACCOUNT_ID:?Set VANILLA_ACCOUNT_ID}"

TOKEN=""

vanilla_login() {
    local response
    response=$(curl -sf -X POST "${VANILLA_API_URL}/api/auth/sign-in" \
        -H "Content-Type: application/json" \
        -d "{\"email\":\"${VANILLA_EMAIL}\",\"password\":\"${VANILLA_PASSWORD}\"}")

    TOKEN=$(echo "$response" | jq -r '.token')

    if [[ -z "$TOKEN" || "$TOKEN" == "null" ]]; then
        echo "ERROR: sign-in failed" >&2
        echo "$response" >&2
        exit 1
    fi
    echo "Authenticated as ${VANILLA_EMAIL}"
}

vanilla_api() {
    local method="$1"
    local path="$2"
    shift 2

    curl -sf -X "$method" "${VANILLA_API_URL}${path}" \
        -H "Authorization: Bearer ${TOKEN}" \
        -H "Content-Type: application/json" \
        "$@"
}
