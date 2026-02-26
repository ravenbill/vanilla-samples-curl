#!/usr/bin/env bash
set -euo pipefail
source "$(dirname "$0")/../lib/auth.sh"
vanilla_login

ACCOUNT_ID="$VANILLA_ACCOUNT_ID"

# Helper to run a GraphQL query/mutation
graphql() {
    local query="$1"
    local variables="${2:-{}}"

    vanilla_api POST "/gql" \
        -d "$(jq -n --arg q "$query" --argjson v "$variables" '{query: $q, variables: $v}')"
}

# 1. Query — list envelopes
echo "=== Query: List Envelopes ==="
graphql '
  query ListEnvelopes($accountId: ID!, $limit: Int) {
    envelopes(accountId: $accountId, limit: $limit) {
      id
      title
      status
      createdAt
      recipients { name email status }
    }
  }
' "$(jq -n --arg id "$ACCOUNT_ID" '{accountId: $id, limit: 5}')" | jq .

# 2. Query — account details
echo ""
echo "=== Query: Account Details ==="
graphql '
  query GetAccount($accountId: ID!) {
    account(id: $accountId) {
      id
      name
      plan
      usage { envelopesSent envelopesRemaining }
    }
  }
' "$(jq -n --arg id "$ACCOUNT_ID" '{accountId: $id}')" | jq .

# 3. Mutation — create an envelope
echo ""
echo "=== Mutation: Create Envelope ==="
graphql '
  mutation CreateEnvelope($input: CreateEnvelopeInput!) {
    createEnvelope(input: $input) {
      envelope { id title status }
      errors { field message }
    }
  }
' "$(jq -n --arg id "$ACCOUNT_ID" '{
    input: {
      accountId: $id,
      title: "GraphQL-Created Envelope",
      message: "Created via a GraphQL mutation."
    }
  }')" | jq .
