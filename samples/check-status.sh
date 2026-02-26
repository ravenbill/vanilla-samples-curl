#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/../lib/auth.sh"
vanilla_login

ACCOUNT_ID="$VANILLA_ACCOUNT_ID"

# 1. List all envelopes
echo "All envelopes:"
ALL=$(vanilla_api GET "/api/accounts/${ACCOUNT_ID}/envelopes")
echo "$ALL" | jq '.data[] | {id, title, status}'

# 2. Filter by status
echo ""
echo "Sent envelopes:"
vanilla_api GET "/api/accounts/${ACCOUNT_ID}/envelopes?status=sent" \
    | jq '.data[] | {id, title, status}'

# 3. Get a specific envelope
ENVELOPE_ID=$(echo "$ALL" | jq -r '.data[0].id // empty')
if [[ -z "$ENVELOPE_ID" ]]; then
    echo "No envelopes found."
    exit 0
fi

echo ""
echo "Checking envelope: ${ENVELOPE_ID}"
DETAIL=$(vanilla_api GET "/api/accounts/${ACCOUNT_ID}/envelopes/${ENVELOPE_ID}")
STATUS=$(echo "$DETAIL" | jq -r '.data.status')
echo "Current status: ${STATUS}"

# 4. Poll until completed (max 5 attempts, 3s interval)
echo ""
echo "Polling for completion..."
for i in $(seq 1 5); do
    STATUS=$(vanilla_api GET "/api/accounts/${ACCOUNT_ID}/envelopes/${ENVELOPE_ID}" \
        | jq -r '.data.status')
    echo "  Attempt ${i}: status = ${STATUS}"

    if [[ "$STATUS" == "completed" ]]; then
        echo "Envelope is completed!"
        exit 0
    fi
    sleep 3
done

echo "Envelope not yet completed after polling."
