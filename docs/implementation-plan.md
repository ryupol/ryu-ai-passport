# AI Passport implementation plan

This plan keeps the work in small vertical slices so each step is runnable before the next one starts.

## Slice 1: Local inference base

- Add a Compose stack with a single `ollama` service.
- Keep the service private on `127.0.0.1` only.
- Add a healthcheck so later services can wait on a healthy inference host.
- Define the local environment and secret-file conventions in tracked docs.
- Add a smoke test that proves the service can start, serve the API, and pull a model.

Exit criteria:

- `docker compose up -d` starts the stack without manual container setup.
- `docker compose ps` shows `ollama` as healthy.
- The smoke test completes from the Ubuntu host.

## Slice 2: Identity and routing skeleton

- Add Authentik, Open WebUI, and Postgres.
- Wire local-only service networking and health-gated startup.
- Keep public ingress disabled until the host gate is satisfied.

Exit criteria:

- Open WebUI can start against local Authentik and Postgres.
- No public route exists yet.

## Slice 3: Provisioning and API control

- Add the Discord provisioning bot.
- Add LiteLLM and its private Postgres state.
- Define role-driven entitlement, issuance, rotation, and revocation flows.

Exit criteria:

- Role changes produce the expected credential lifecycle behavior.
- New API requests fail quickly after revocation.

## Slice 4: Observability and hardening

- Add Prometheus and Grafana.
- Record container, host, and GPU metrics.
- Validate restart behavior, firewall boundaries, and cold-boot recovery.

Exit criteria:

- The stack recovers after host reboot without manual container surgery.
- Operator dashboards are private.

## Slice 5: Public ingress

- Enable Tailscale Windows service and Funnel only after the host gate is satisfied.
- Route the single hostname to Open WebUI, Authentik, and LiteLLM.

Exit criteria:

- Public access works only through the intended hostname and paths.
- Private ports remain private.
