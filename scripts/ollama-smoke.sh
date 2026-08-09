#!/usr/bin/env sh
set -eu

compose_cmd="${COMPOSE_CMD:-docker compose}"
smoke_model="${OLLAMA_SMOKE_MODEL:-llama3.2:1b}"

$compose_cmd up -d ollama
$compose_cmd --profile smoke run --rm -e OLLAMA_SMOKE_MODEL="$smoke_model" ollama-smoke
