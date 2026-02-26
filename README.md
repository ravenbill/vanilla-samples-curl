# Vanilla API — curl / Bash Samples

Runnable shell scripts demonstrating the Vanilla e-signature API using `curl` and `jq`.

## Prerequisites

- bash 4+
- [curl](https://curl.se/)
- [jq](https://jqlang.github.io/jq/)
- netcat (`nc`) — only for the webhook sample

## Feature Status

Most samples work with the current Vanilla Esign API. The following samples demonstrate **planned features** that are not yet implemented:

- `samples/use-templates.sh` — Templates (planned)
- `samples/bulk-send.sh` — Bulk Send (planned)

## Setup

```bash
git clone <repo-url> && cd vanilla-samples-curl
```

Copy the environment template and fill in your credentials:

```bash
cp .env.example .env
# Edit .env with your values
```

Or export the variables directly:

```bash
export VANILLA_API_URL="https://demo.ravenbill.com"  # or https://www.ravenbill.com for production
export VANILLA_EMAIL="you@example.com"
export VANILLA_PASSWORD="your-password"
export VANILLA_ACCOUNT_ID="your-account-id"
```

Make the scripts executable (one-time):

```bash
chmod +x samples/*.sh lib/*.sh
```

## Run a sample

```bash
bash samples/create-and-send-envelope.sh
```

| Script | Description |
|---|---|
| `samples/create-and-send-envelope.sh` | Create a draft envelope and send it |
| `samples/add-recipients.sh` | Add recipients and signature tabs |
| `samples/use-templates.sh` | List and use templates |
| `samples/check-status.sh` | Query envelope status and poll |
| `samples/download-documents.sh` | Download signed PDF and certificate |
| `samples/webhook-handler.sh` | Local listener for webhook events |
| `samples/bulk-send.sh` | Read CSV and send envelopes in bulk |
| `samples/graphql-queries.sh` | GraphQL queries and mutations |

## License

MIT — Copyright 2026 Ravenbill
