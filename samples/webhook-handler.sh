#!/usr/bin/env bash
set -euo pipefail

# Load env for VANILLA_WEBHOOK_SECRET
ENV_FILE="$(cd "$(dirname "$0")/.." && pwd)/.env"
if [[ -f "$ENV_FILE" ]]; then
    set -a
    source "$ENV_FILE"
    set +a
fi

PORT="${1:-8080}"
WEBHOOK_SECRET="${VANILLA_WEBHOOK_SECRET:-your-webhook-secret}"

echo "Webhook listener starting on port ${PORT}..."
echo "Press Ctrl+C to stop."
echo ""

while true; do
    # Use netcat to listen for one incoming HTTP request
    RESPONSE="HTTP/1.1 200 OK\r\nContent-Type: application/json\r\n\r\n{\"received\":true}"

    REQUEST=$(echo -e "$RESPONSE" | nc -l "$PORT" 2>/dev/null || true)

    if [[ -z "$REQUEST" ]]; then
        continue
    fi

    echo "--- Incoming webhook ---"

    # Extract the body (everything after the blank line)
    BODY=$(echo "$REQUEST" | sed '1,/^\r*$/d')

    if [[ -z "$BODY" ]]; then
        echo "  (empty body)"
        continue
    fi

    # Extract signature header
    SIGNATURE=$(echo "$REQUEST" | grep -i "X-Vanilla-Signature:" | awk '{print $2}' | tr -d '\r' || true)

    # Verify HMAC if signature present
    if [[ -n "$SIGNATURE" ]]; then
        COMPUTED=$(echo -n "$BODY" | openssl dgst -sha256 -hmac "$WEBHOOK_SECRET" | awk '{print $2}')
        if [[ "$SIGNATURE" == "$COMPUTED" ]]; then
            echo "  Signature: VALID"
        else
            echo "  Signature: INVALID"
        fi
    else
        echo "  Signature: not present"
    fi

    # Pretty-print the payload
    EVENT=$(echo "$BODY" | jq -r '.event // "unknown"' 2>/dev/null || echo "unknown")
    echo "  Event type: ${EVENT}"
    echo "$BODY" | jq . 2>/dev/null || echo "$BODY"
    echo ""
done
