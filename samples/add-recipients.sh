#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/../lib/auth.sh"
vanilla_login

ACCOUNT_ID="$VANILLA_ACCOUNT_ID"

# 1. Create envelope
echo "Creating envelope..."
ENVELOPE=$(vanilla_api POST "/api/accounts/${ACCOUNT_ID}/envelopes" \
    -d '{"title": "Multi-Recipient Envelope", "message": "Multiple signers needed."}')

ENVELOPE_ID=$(echo "$ENVELOPE" | jq -r '.data.id')
echo "Created envelope: ${ENVELOPE_ID}"

# 2. Add first recipient
echo "Adding Alice..."
R1=$(vanilla_api POST "/api/accounts/${ACCOUNT_ID}/envelopes/${ENVELOPE_ID}/recipients" \
    -d '{"email": "alice@example.com", "name": "Alice", "role": "signer", "order": 1}')
R1_ID=$(echo "$R1" | jq -r '.data.id')
echo "  Recipient ID: ${R1_ID}"

# 3. Add second recipient
echo "Adding Bob..."
R2=$(vanilla_api POST "/api/accounts/${ACCOUNT_ID}/envelopes/${ENVELOPE_ID}/recipients" \
    -d '{"email": "bob@example.com", "name": "Bob", "role": "signer", "order": 2}')
R2_ID=$(echo "$R2" | jq -r '.data.id')
echo "  Recipient ID: ${R2_ID}"

# 4. Add signature tab for Alice
echo "Adding signature tab for Alice..."
vanilla_api POST "/api/accounts/${ACCOUNT_ID}/envelopes/${ENVELOPE_ID}/recipients/${R1_ID}/tabs" \
    -d '{"type": "signature", "page": 1, "x": 200, "y": 400}' | jq .

# 5. Add date-signed tab for Bob
echo "Adding date_signed tab for Bob..."
vanilla_api POST "/api/accounts/${ACCOUNT_ID}/envelopes/${ENVELOPE_ID}/recipients/${R2_ID}/tabs" \
    -d '{"type": "date_signed", "page": 1, "x": 200, "y": 500}' | jq .

# 6. List all recipients
echo ""
echo "All recipients:"
vanilla_api GET "/api/accounts/${ACCOUNT_ID}/envelopes/${ENVELOPE_ID}/recipients" | jq .
