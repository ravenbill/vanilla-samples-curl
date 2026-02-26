#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/../lib/auth.sh"
vanilla_login

ACCOUNT_ID="$VANILLA_ACCOUNT_ID"

# 1. Find a completed envelope
ENVELOPES=$(vanilla_api GET "/api/accounts/${ACCOUNT_ID}/envelopes?status=completed")
ENVELOPE_ID=$(echo "$ENVELOPES" | jq -r '.data[0].id // empty')

if [[ -z "$ENVELOPE_ID" ]]; then
    echo "No completed envelopes found."
    exit 0
fi

echo "Downloading documents for envelope: ${ENVELOPE_ID}"

# 2. Create downloads directory
mkdir -p downloads

# 3. Download signed PDF
echo "Downloading signed PDF..."
curl -sf -o "downloads/${ENVELOPE_ID}-signed.pdf" \
    -H "Authorization: Bearer ${TOKEN}" \
    "${VANILLA_API_URL}/api/accounts/${ACCOUNT_ID}/envelopes/${ENVELOPE_ID}/documents/combined"
echo "  Saved: downloads/${ENVELOPE_ID}-signed.pdf"

# 4. Download signing certificate
echo "Downloading certificate..."
curl -sf -o "downloads/${ENVELOPE_ID}-certificate.pdf" \
    -H "Authorization: Bearer ${TOKEN}" \
    "${VANILLA_API_URL}/api/accounts/${ACCOUNT_ID}/envelopes/${ENVELOPE_ID}/documents/certificate"
echo "  Saved: downloads/${ENVELOPE_ID}-certificate.pdf"

echo ""
echo "Done! Files saved to downloads/"
ls -lh downloads/
