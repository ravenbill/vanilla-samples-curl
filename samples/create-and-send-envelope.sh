#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/../lib/auth.sh"
vanilla_login

ACCOUNT_ID="$VANILLA_ACCOUNT_ID"

# 1. Create a draft envelope
echo "Creating draft envelope..."
ENVELOPE=$(vanilla_api POST "/api/accounts/${ACCOUNT_ID}/envelopes" \
    -d '{
        "title": "Sample Envelope from curl",
        "message": "Please review and sign this document."
    }')

ENVELOPE_ID=$(echo "$ENVELOPE" | jq -r '.data.id')
echo "Created draft envelope: ${ENVELOPE_ID}"

# 2. Add a recipient
echo "Adding recipient..."
vanilla_api POST "/api/accounts/${ACCOUNT_ID}/envelopes/${ENVELOPE_ID}/recipients" \
    -d '{
        "email": "signer@example.com",
        "name": "Jane Signer",
        "role": "signer"
    }' | jq .

# 3. Send the envelope
echo "Sending envelope..."
RESULT=$(vanilla_api PATCH "/api/accounts/${ACCOUNT_ID}/envelopes/${ENVELOPE_ID}" \
    -d '{"status": "sent"}')

echo "Envelope sent!"
echo "$RESULT" | jq .
