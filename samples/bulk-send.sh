#!/usr/bin/env bash
# NOTE: Bulk Send feature is not yet implemented in Vanilla Esign.
# This sample demonstrates the planned API design and may change.
set -euo pipefail
source "$(dirname "$0")/../lib/auth.sh"
vanilla_login

ACCOUNT_ID="$VANILLA_ACCOUNT_ID"
CSV_FILE="$(cd "$(dirname "$0")/.." && pwd)/data/recipients.csv"

if [[ ! -f "$CSV_FILE" ]]; then
    echo "CSV file not found: ${CSV_FILE}"
    exit 1
fi

echo "Reading recipients from ${CSV_FILE}"
COUNT=0

# Skip header line, then process each row
tail -n +2 "$CSV_FILE" | while IFS=',' read -r NAME EMAIL ROLE; do
    NAME=$(echo "$NAME" | xargs)
    EMAIL=$(echo "$EMAIL" | xargs)
    ROLE=$(echo "${ROLE:-signer}" | xargs)

    if [[ -z "$NAME" || -z "$EMAIL" ]]; then
        continue
    fi

    # Create envelope
    ENVELOPE=$(vanilla_api POST "/api/accounts/${ACCOUNT_ID}/envelopes" \
        -d "{\"title\": \"Bulk Envelope for ${NAME}\", \"message\": \"Please sign this document.\"}")
    ENVELOPE_ID=$(echo "$ENVELOPE" | jq -r '.data.id')

    # Add recipient
    vanilla_api POST "/api/accounts/${ACCOUNT_ID}/envelopes/${ENVELOPE_ID}/recipients" \
        -d "{\"name\": \"${NAME}\", \"email\": \"${EMAIL}\", \"role\": \"${ROLE}\"}" > /dev/null

    # Send
    vanilla_api PATCH "/api/accounts/${ACCOUNT_ID}/envelopes/${ENVELOPE_ID}" \
        -d '{"status": "sent"}' > /dev/null

    COUNT=$((COUNT + 1))
    echo "  Sent envelope ${ENVELOPE_ID} to ${NAME} <${EMAIL}>"
done

echo ""
echo "Done! Sent envelopes from CSV."
