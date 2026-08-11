# Slice 1: local inference base

This slice stands up a single private Ollama service on the Linux Mint host.
Docker is started manually during early implementation; the finished project uses
the Start AI Passport launcher and does not start Docker or containers at boot.

## Files

- `compose.yaml`
- `.env.example`
- `scripts/ollama-smoke.sh`

## Local configuration

1. Copy `.env.example` to `.env`.
2. Leave secrets out of git.
3. Reserve `secrets/` for mounted secret files when later slices need them.

## Bring it up

```sh
docker compose up -d ollama
docker compose ps
```

## Smoke test

```sh
sh ./scripts/ollama-smoke.sh
```

The smoke helper:

- starts `ollama` if needed,
- waits for the healthcheck to pass,
- pulls a small model through the running service,
- runs a single prompt against that model.

## Success criteria

- The `ollama` container stays healthy after startup.
- The service remains bound to `127.0.0.1:11434`.
- The smoke helper exits cleanly from the Linux Mint host.
- `docker compose down` stops the service without deleting the model volume.
