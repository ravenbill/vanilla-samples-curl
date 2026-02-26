#!/usr/bin/env bash
# NOTE: Templates feature is not yet implemented in Vanilla Esign.
# This sample demonstrates the planned API design and may change.
set -euo pipefail
source "$(dirname "$0")/../lib/auth.sh"
vanilla_login

ACCOUNT_ID="$VANILLA_ACCOUNT_ID"

# 1. List available templates
echo "Listing templates..."
TEMPLATES=$(vanilla_api GET "/api/accounts/${ACCOUNT_ID}/templates")
echo "$TEMPLATES" | jq '.data[] | {id, title}'

TEMPLATE_ID=$(echo "$TEMPLATES" | jq -r '.data[0].id // empty')
if [[ -z "$TEMPLATE_ID" ]]; then
    echo "No templates found. Create one in the UI first."
    exit 0
fi

TEMPLATE_NAME=$(echo "$TEMPLATES" | jq -r '.data[0].title')
echo ""
echo "Using template: ${TEMPLATE_NAME} (${TEMPLATE_ID})"

# 2. Create envelope from template
echo "Creating envelope from template..."
ENVELOPE=$(vanilla_api POST "/api/accounts/${ACCOUNT_ID}/envelopes" \
    -d "{
        \"template_id\": \"${TEMPLATE_ID}\",
        \"title\": \"From Template: ${TEMPLATE_NAME}\",
        \"message\": \"Created from a template via curl.\"
    }")

ENVELOPE_ID=$(echo "$ENVELOPE" | jq -r '.data.id')
echo "Created envelope: ${ENVELOPE_ID}"

# 3. Add recipient
echo "Adding recipient..."
vanilla_api POST "/api/accounts/${ACCOUNT_ID}/envelopes/${ENVELOPE_ID}/recipients" \
    -d '{"email": "real-signer@example.com", "name": "Real Signer", "role": "signer"}' | jq .

# 4. Send
echo "Sending..."
vanilla_api PATCH "/api/accounts/${ACCOUNT_ID}/envelopes/${ENVELOPE_ID}" \
    -d '{"status": "sent"}' | jq .

echo "Envelope sent!"
