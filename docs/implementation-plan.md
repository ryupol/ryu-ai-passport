# AI Passport implementation contract

Status: approved for slice-by-slice execution

Target executor: GPT-5.6 Luna

Target host: Linux Mint 22.3 Cinnamon, hostname `ryupol`, RTX 3060 12 GB,
16 GB RAM

This document is an execution contract, not a roadmap. Implement exactly one
slice, prove its exit criteria, update `HANDOFF.md`, and stop for operator
approval before starting the next slice.

## 1. Mandatory execution rules

1. Read `CONTEXT.md`, ADR 0002, the Linux Mint migration guide, this document,
   `HANDOFF.md`, and every file a
   slice says to modify before editing.
2. Do not revise accepted architecture silently. Correct facts in ADR 0002;
   propose a superseding ADR before changing a material architecture decision.
3. Do not commit, push, enable Funnel, create external applications, rotate real
   credentials, or delete persistent data unless the operator explicitly asks.
4. Keep work in the native Linux filesystem, such as `~/src/ryu-ai-passport`.
5. Use exact image and package versions. `latest`, `main`, floating major tags,
   and uncommitted lockfile changes are forbidden.
6. Keep all service ports on a private Docker network or bind them to
   `127.0.0.1`. PostgreSQL, Ollama, Adminer, Prometheus, Grafana, and all admin
   interfaces must never have a public route.
7. Never print, log, commit, or place a secret directly in `compose.yaml`.
   Mount ignored files through Compose secrets. Tracked `.example` files must
   contain placeholders only.
8. Do not log prompt text, generated text, Discord tokens, OAuth tokens, API
   keys, or database passwords. Observability is metadata-only.
9. Prefer an automated, idempotent configuration or test over an undocumented
   UI action. Mark unavoidable human actions explicitly.
10. If a hard gate fails, stop. Record the command, sanitized output, likely
    cause, and required decision in `HANDOFF.md`; do not improvise around it.
11. After every slice verification attempt and before claiming completion, use
    `.agents/skills/record-slice-progress/SKILL.md` to update `HANDOFF.md` in the same
    change. `HANDOFF.md` is the only progress record; do not create `memory.md`.
12. This is a manual-start personal PC. Every Compose service uses `restart: "no"`.
    Docker, `docker.socket`, Tailscale, and the stack must remain disabled/stopped
    after boot unless the operator uses the Start AI Passport launcher.

## 2. Approved implementation decisions

| Area | Decision |
| --- | --- |
| Delivery | One verified slice at a time with operator approval between slices |
| Database | One PostgreSQL container; separate database and login per application |
| Database UI | Optional Adminer `tools` profile on `127.0.0.1:8081` only |
| Backups | Daily `pg_dump`, seven daily plus four weekly copies, with restore test |
| Identity | Authentik blueprints plus manual external-secret checkpoints |
| Entitlement | Discord `AI Passport` role is the source of truth |
| Revocation | Discord gateway event plus full reconciliation every 30 seconds |
| Key delivery | `/passport-key` and `/passport-rotate`; ephemeral, show plaintext once |
| Bot runtime | TypeScript, Node.js 24 LTS, ESM, strict compiler settings |
| Bot structure | Controllers, models, services, repositories, clients, database, bootstrap |
| Database access | Drizzle ORM with checked-in, reviewable SQL migrations |
| Validation | Zod at environment and external API boundaries |
| Tests | Vitest unit/contract tests plus real PostgreSQL integration tests |
| Ingress | Localhost, then private Tailscale Serve, then separately approved Funnel |
| Monitoring | Prometheus and private Grafana; live usage only, no capacity prediction |
| Privacy | Metrics and sanitized metadata only; no prompts or responses in logs |
| Host lifecycle | Manual desktop launchers; no service or container autostart |

## 3. Target topology

The final stack contains:

- `ollama` using the RTX 3060 through the NVIDIA Container Toolkit.
- One `postgres` service containing `authentik`, `openwebui`, `litellm`, and
  `passport_bot` databases, each with a unique owner/password.
- Authentik server/worker and Open WebUI.
- LiteLLM routing only to Ollama.
- A custom TypeScript provisioning bot.
- Prometheus, Grafana, Linux host/container metrics, PostgreSQL metrics, and an
  `nvidia-smi`-compatible GPU exporter.
- Optional Adminer in the `tools` profile.
- A local backup service/profile and restore verification tooling.
- Tailscale as a native Linux systemd service, normally stopped. Tailscale is not
  a Compose service.

No standalone Nginx, Caddy, Traefik, or public database UI is allowed unless a
proved Tailscale routing limitation results in a superseding ADR.

## 4. Configuration and secret contract

Tracked non-secret configuration belongs in `.env.example`. Every image variable
must contain an exact version in the implemented `.env`, for example
`POSTGRES_IMAGE=postgres:<exact-patch>-bookworm`; a floating example is not
acceptable in the completed slice.

Tracked secret references use this layout:

```text
secrets/
├── README.md
├── postgres_admin_password.txt.example
├── authentik_db_password.txt.example
├── authentik_secret_key.txt.example
├── authentik_bootstrap_password.txt.example
├── openwebui_db_password.txt.example
├── openwebui_secret_key.txt.example
├── openwebui_admin_password.txt.example
├── litellm_db_password.txt.example
├── litellm_master_key.txt.example
├── passport_bot_db_password.txt.example
├── discord_client_secret.txt.example
└── discord_bot_token.txt.example
```

Real files omit `.example` and are ignored. `secrets/README.md` must document how
to generate each value and how to set restrictive Linux permissions. Scripts may
check that a secret is non-empty but must not echo it.

Human-supplied values that may remain as placeholders until their slice:

| Value | Supplied by | First required |
| --- | --- | --- |
| Discord application/client ID | Operator, Discord Developer Portal | Slice 3 |
| Discord client secret | Operator, secret file | Slice 3 |
| Discord bot token | Operator, secret file | Slice 5 |
| Discord guild ID | Operator, `.env` | Slice 3 |
| `AI Passport` Discord role ID | Operator, `.env` | Slice 3 |
| Tailnet hostname | Tailscale after node enrollment | Slice 3 |
| Initial local admin credentials | Operator, secret files | Slice 2 |

## 5. Version-selection rule

At the start of each slice, verify supported stable versions from the upstream
official release page or documentation. Record the source and selection date in
the slice evidence in `HANDOFF.md`. Pin:

- container images to an exact immutable tag; record the pulled digest,
- Node.js to the Node 24 LTS exact patch in the bot Dockerfile,
- npm dependencies in `package.json` and committed `package-lock.json`, and
- configuration schemas to the selected application version.

Do not upgrade an unrelated component during a slice. Upgrades are separate work
with their own backup and rollback verification.

## Host migration and readiness gate

Before Slice 0, the operator follows `docs/linux-mint-migration-guide.md`. Luna
may inspect the resulting host and record sanitized evidence, but must not choose
a disk, flash media, enter credentials, change firmware, or approve disk erasure
for the operator.

The gate passes only when:

- the retained Windows USB boots to Windows Setup and the exact licensed edition
  is recorded privately;
- Mint is installed as `ryupol`, updated, and usable for network, display, audio,
  and normal desktop work;
- Secure Boot remains enabled and `nvidia-smi` shows the RTX 3060;
- the repository is on native Linux storage; and
- Docker can run a pinned GPU test, then `docker.service` and `docker.socket` are
  returned to disabled/inactive state.

Migration completion is an environment gate, not an implementation slice. Record
its sanitized outcome in the dedicated migration section of `HANDOFF.md`.

## 6. Slice 0 — Reconcile and prove local inference

### Goal

Turn the existing Ollama files into a pinned, verified native Linux baseline.
The current Compose code exists but has not been proved on the target host.

### Read and modify

- `compose.yaml`
- `.env.example`
- `scripts/ollama-smoke.sh`
- `docs/slice-1-local-inference.md`
- `.gitignore`
- `HANDOFF.md`

### Required implementation

1. Replace the floating Ollama image with an exact stable tag in
   `.env.example`; make Compose fail clearly when the variable is absent.
2. Keep port `11434` bound to `127.0.0.1` only and retain the named model volume.
   Set its restart policy to `"no"`.
3. Make the health check prove the API responds, not merely that a process exists.
4. Make the smoke test verify all of the following: container health, API access,
   model pull, non-empty generation, GPU visibility inside the container, and no
   non-loopback published address.
5. Ensure cleanup removes only the one-shot smoke container, never the model
   volume.
6. Update the slice document with exact target-host commands and expected result
   shapes, without claiming success until run on the Linux Mint host.

### Verification on Linux Mint

```bash
docker compose config --quiet
docker compose pull ollama
docker compose up -d ollama
docker compose ps
curl --fail --silent http://127.0.0.1:11434/api/tags
docker compose exec ollama nvidia-smi
sh ./scripts/ollama-smoke.sh
docker compose port ollama 11434
```

Record `docker compose images`, the image digest, GPU name/VRAM, container health,
and smoke-test result. Sanitize host/user names if needed.

### Exit criteria

- Ollama is healthy after a restart.
- The RTX 3060 is visible from the Ollama container.
- The smoke prompt returns a non-empty response.
- `11434` is reachable at `127.0.0.1` and not through the LAN address.
- `HANDOFF.md` marks Slice 0 complete with evidence.
- `docker compose down` stops Ollama without deleting its named model volume.

Stop for operator approval.

## 7. Slice 1 — Persistence, inspection, and backups

### Goal

Create one private PostgreSQL service, isolated application databases, optional
Adminer, and a tested backup/restore path before storing real identity data.

### Files to create or modify

```text
compose.yaml
.env.example
.gitignore
secrets/README.md
secrets/*.txt.example
scripts/postgres/init-databases.sh
scripts/postgres/verify-isolation.sh
scripts/backup/postgres-backup.sh
scripts/backup/postgres-restore-test.sh
docs/database-runbook.md
HANDOFF.md
```

### Required implementation

1. Add an exact-version `postgres` service with a health check, named volume,
   private network, `POSTGRES_PASSWORD_FILE`, resource-conscious defaults, and no
   host port.
2. Add an idempotent one-shot initializer that creates the four databases and
   four least-privilege logins. It must work after a normal restart and fail on a
   missing secret.
3. Prove each application login can access only its own database.
4. Add Adminer under profile `tools`, bind only `127.0.0.1:8081`, and do not
   pre-fill a password.
5. Add daily logical backups outside the database volume, retain seven daily and
   four weekly backups, and document storage size/permissions.
6. Restore the newest dump into temporary database names, run basic row/database
   checks, then remove only those temporary databases.

### Verification

```bash
docker compose config --quiet
docker compose up -d postgres
docker compose ps postgres
sh ./scripts/postgres/init-databases.sh
sh ./scripts/postgres/verify-isolation.sh
docker compose --profile tools up -d adminer
curl --fail --silent http://127.0.0.1:8081 >/dev/null
sh ./scripts/backup/postgres-backup.sh
sh ./scripts/backup/postgres-restore-test.sh
```

Also prove PostgreSQL and Adminer are not listening on a non-loopback host address.

### Exit criteria

- Four isolated databases/users exist.
- Adminer works only when the `tools` profile is requested.
- Backup and restore test succeeds without exposing secrets.
- Normal `docker compose up -d` does not start Adminer.

Stop for operator approval.

## 8. Slice 2 — Local identity and chat skeleton

### Goal

Start pinned Authentik and Open WebUI services against the shared PostgreSQL
container, still without Discord or any public route.

### Files to create or modify

```text
compose.yaml
.env.example
authentik/blueprints/base.yaml
openwebui/README.md
scripts/verify/local-identity.sh
docs/identity-runbook.md
HANDOFF.md
```

### Required implementation

1. Follow the selected Authentik version's official small Compose topology. Do
   not add Redis unless that pinned version requires it.
2. Load Authentik secrets through mounted files using supported `file://` or a
   non-logging entrypoint wrapper.
3. Add Open WebUI as a single replica using its PostgreSQL database and a stable
   secret key. Keep password signup/login disabled only after OIDC has been
   proved; preserve a private recovery-admin path until then.
4. Store the reproducible, non-secret Authentik base configuration as a blueprint.
5. Bind Authentik and Open WebUI only to distinct localhost ports. Do not add
   Tailscale routes in this slice.
6. Add health checks and dependency conditions that tolerate first-run migrations.

### Verification

```bash
docker compose config --quiet
docker compose up -d postgres authentik-server authentik-worker open-webui
docker compose ps
sh ./scripts/verify/local-identity.sh
```

Perform one operator checkpoint in the browser: create/verify the recovery admin,
open the Authentik admin UI locally, and open Open WebUI locally. Record no secret
values or screenshots containing them.

### Exit criteria

- Authentik and Open WebUI survive container restarts with their state intact.
- Both use their isolated PostgreSQL databases.
- No Discord source and no Tailscale/Funnel route exists.
- Local recovery-admin access has been demonstrated.

Stop for operator approval.

## 9. Slice 3 — Private ingress, Discord OIDC, and chat-revocation gate

### Goal

Use the stable Tailscale hostname privately, configure Discord login through an
Authentik blueprint, and prove a logged-in user can be disabled within 60 seconds.

### Files to create or modify

```text
authentik/blueprints/discord-source.yaml
authentik/blueprints/openwebui-oidc.yaml
scripts/linux/configure-private-ingress.sh
scripts/linux/reset-ingress.sh
scripts/verify/private-routes.sh
scripts/verify/chat-revocation.sh
docs/identity-runbook.md
docs/tailscale-runbook.md
HANDOFF.md
```

### Human checkpoint

The operator creates the Discord application, enters the exact private callback
URI, supplies client/guild/role identifiers, writes the client secret file, and
installs/enrolls the Linux node in Tailscale. Luna must not automate Discord or
Tailscale account actions, and Tailscale must remain disabled at boot.

### Required implementation

1. Blueprint a Discord source requesting only required scopes, an Authentik group
   with the Discord role ID attribute, the role-check expression/policy, an OIDC
   provider/application for Open WebUI, and the required role claim mapping.
2. Configure Open WebUI from explicit OIDC environment variables. New users start
   `pending`; only the mapped role becomes `user`; no Discord role may map to
   `admin`.
3. Configure Tailscale Serve from a Linux shell script. The script must be
   idempotent, default to private Serve, show the proposed route table, and never
   call `tailscale funnel`. It must use the interactive administrative path
   approved by the operator and must not install passwordless sudo rules.
4. Route the root to Open WebUI and only the required Authentik/OIDC paths to
   Authentik on the one hostname. Validate longest-path behavior and callbacks.
5. Identify and contract-test the pinned Open WebUI supported admin API for
   changing a member from `user` to `pending`. Never update Open WebUI tables
   directly.
6. Prove a new chat request fails within 60 seconds of that change. An in-flight
   generation may finish, but no later request may start.

### Hard gate

If the supported API or session behavior cannot meet 60 seconds, stop. Document
the evidence and propose a superseding ADR. Do not add a proxy, patch vendor code,
or manipulate vendor database tables inside this slice.

### Exit criteria

- A role-holding test member signs in through Discord on the private hostname.
- A non-role member is denied.
- Demotion to `pending` blocks new chat within 60 seconds.
- Authentik/Open WebUI admin surfaces and all unrelated ports remain private.
- Funnel is still disabled.

Stop for operator approval.

## 10. Slice 4 — LiteLLM free-key compatibility gate

### Goal

Add pinned LiteLLM with its isolated PostgreSQL database, route it only to Ollama,
and prove the complete virtual-key lifecycle is free and revocable.

### Files to create or modify

```text
compose.yaml
.env.example
litellm/config.yaml
scripts/verify/litellm-key-lifecycle.sh
docs/litellm-runbook.md
HANDOFF.md
```

### Required implementation

1. Bind the LiteLLM user API to localhost. Do not expose its admin UI or master
   key interface through Tailscale.
2. Load the master key and database password from mounted secret files without
   logging them.
3. Configure a single named model alias backed by Ollama. Benchmark-driven model,
   context, concurrency, and queue limits remain deferred; use a small verification
   model for this gate.
4. Through supported LiteLLM APIs: create a virtual key, make one inference call,
   query sanitized usage metadata, revoke/delete the key, and prove the same key
   immediately receives `401` on a new request.
5. The test must run with no `LITELLM_LICENSE` and no enterprise feature.

### Hard gate

If create/use/revoke requires payment or is broken in the selected stable version,
stop and propose a free alternative in a superseding ADR. Do not pin a known
vulnerable release solely to avoid a license check.

### Exit criteria

- OpenAI-compatible local inference succeeds through LiteLLM.
- A revoked key fails immediately.
- No paid feature or cloud model/API is used.
- Only `/v1` is a candidate for later public routing.

Stop for operator approval.

## 11. Slice 5 — TypeScript provisioning bot

### Goal

Implement role-driven entitlement, show-once key issuance/rotation, immediate
events, and 30-second reconciliation using the proved vendor APIs.

### Required project layout

```text
bot/
├── package.json
├── package-lock.json
├── tsconfig.json
├── eslint.config.js
├── Dockerfile
├── src/
│   ├── bootstrap/
│   ├── clients/
│   ├── config/
│   ├── controllers/
│   ├── database/
│   ├── models/
│   ├── repositories/
│   ├── services/
│   └── main.ts
├── test/
│   ├── contract/
│   ├── integration/
│   └── unit/
└── drizzle/
    └── <versioned SQL migrations>
```

### Layer boundaries

- Controllers translate Discord events/commands into typed service calls and
  ephemeral responses. They contain no entitlement or SQL logic.
- Models contain domain types, Zod schemas, enums, and errors. They do not make
  network or database calls.
- Services own reconciliation, entitlement, issuance, rotation, revocation, and
  transaction/compensation decisions.
- Repositories contain only persistence interfaces and Drizzle implementations.
- Clients wrap Discord, LiteLLM, Authentik, and Open WebUI APIs behind typed
  interfaces. Parse every external response with Zod.
- Bootstrap constructs concrete dependencies and owns startup/shutdown.

### TypeScript quality contract

- Node.js 24 LTS exact patch, ESM, npm, committed `package-lock.json`.
- `strict`, `noUncheckedIndexedAccess`, `exactOptionalPropertyTypes`, and
  `noImplicitOverride` enabled.
- No application `any`, unchecked type assertion, or non-null assertion without a
  documented boundary reason.
- Use dependency injection through interfaces; do not import concrete database or
  HTTP implementations into services.

### Persistence model

At minimum, model:

- member identity and current entitlement,
- LiteLLM key identifier/fingerprint and lifecycle state (never plaintext key),
- processed Discord event/idempotency record,
- reconciliation run/outcome, and
- sanitized audit event.

Database migrations are generated as SQL, reviewed, committed, and applied by a
one-shot migration command/service. Runtime startup must not silently push schema.

### Required behavior

1. Role addition marks the member entitled but does not create or send a key.
2. `/passport-key` checks live membership, returns the existing status or creates
   one key, and shows new plaintext once in an ephemeral response.
3. `/passport-rotate` creates a replacement and invalidates the previous key
   immediately; define and test compensation if either vendor call fails.
4. `/passport-usage` returns sanitized usage metadata, never another secret.
5. Role removal changes Open WebUI to `pending`, revokes the LiteLLM key, and
   records the outcome. New access must fail within 60 seconds.
6. Gateway role events trigger immediately. A full guild reconciliation runs every
   30 seconds to recover missed events and is safe to repeat.
7. On partial failure, fail closed where possible, retry with bounded exponential
   backoff, expose a metric, and leave a reconcilable database state.

### Verification

```bash
cd bot
npm ci
npm run format:check
npm run lint
npm run typecheck
npm run test
npm run test:integration
npm run build
cd ..
docker compose build passport-bot
docker compose up -d passport-bot
docker compose ps passport-bot
```

Unit tests use fakes. Contract tests use recorded/synthetic sanitized payloads.
Integration tests start temporary PostgreSQL and apply real migrations. Tests do
not contact real Discord or production services by default.

### Exit criteria

- All quality commands pass.
- Issue, rotate, usage, removal, retry, idempotency, and reconciliation paths are
  tested.
- A real private test member completes the flow with operator approval.
- Plaintext personal keys exist only in LiteLLM's creation response and the one
  ephemeral Discord response.

Stop for operator approval.

## 12. Slice 6 — Metadata-only monitoring and private Grafana

### Goal

Provide live Linux host, container, database, GPU, inference, and bot health without
collecting prompt/response content or predicting unused capacity.

### Files to create or modify

```text
compose.yaml
monitoring/prometheus/prometheus.yml
monitoring/prometheus/rules/*.yml
monitoring/grafana/provisioning/datasources/*.yml
monitoring/grafana/provisioning/dashboards/*.yml
monitoring/grafana/dashboards/*.json
scripts/verify/monitoring.sh
docs/monitoring-runbook.md
HANDOFF.md
```

### Required signals

- Linux host: CPU, memory, disk free/I/O, network, uptime, and service health
  through a pinned node exporter with the narrowest required host access.
- Containers: CPU, memory, filesystem, network, restarts, and health through a
  pinned container exporter.
- GPU: utilization, dedicated VRAM used/free, temperature, power, clocks, and
  throttle reasons when exposed by the RTX 3060 driver.
- PostgreSQL: availability, connections, transactions, locks, and database size;
  no query text.
- Ollama/LiteLLM: request rate, active requests, latency, errors, queue depth, and
  token counts when supported; no content.
- Bot: reconciliation duration/outcome, entitlement transitions, vendor-call
  latency/errors, and revocation deadline violations.

Use a pinned `nvidia-smi`-compatible exporter through the NVIDIA Container
Toolkit. If it cannot expose a required signal on the selected driver, record the
missing signal rather than installing an unreviewed host daemon or silently
substituting DCGM.

### Dashboard contract

Provision dashboards and the Prometheus data source from tracked files. Grafana
binds to `127.0.0.1` only and has no Tailscale route. Show live usage and fixed
health thresholds only; do not display estimated remaining traffic capacity.
Member IDs, key IDs, request IDs, prompts, and error messages are forbidden as
Prometheus labels.

### Exit criteria

- Grafana survives restart with dashboards/data source intact.
- GPU, Linux host/container, PostgreSQL, inference, and bot panels contain live
  samples.
- Stopping a test service produces the expected private alert.
- No monitoring port is reachable from the LAN or public hostname.

Stop for operator approval.

## 13. Slice 7 — Personal-PC launchers and host hardening

### Goal

Provide explicit Start AI Passport and Stop AI Passport desktop actions while
proving that no project host service or container starts automatically after boot.

### Files to create or modify

```text
scripts/linux/start-ai-passport.sh
scripts/linux/stop-ai-passport.sh
scripts/linux/install-launchers.sh
scripts/linux/uninstall-launchers.sh
scripts/verify/manual-lifecycle.sh
desktop/ryu-ai-passport-start.desktop
desktop/ryu-ai-passport-stop.desktop
docs/linux-mint-runbook.md
HANDOFF.md
```

### Required implementation

1. Install project-owned `.desktop` launchers for the current user without
   hard-coding the username, password, or repository path in tracked files.
2. Start requests administrative authorization graphically, starts `tailscaled`,
   Docker, and `docker.socket`, waits for readiness, runs the exact Compose
   project, verifies health, and opens the local dashboard.
3. Stop runs `docker compose down` without `--volumes`, then requests graphical
   authorization to stop Docker/socket and Tailscale. It preserves named volumes.
4. Use `pkexec` or the distribution's normal graphical policy mechanism. Never
   store a password and never install passwordless sudo/polkit authorization.
5. The installer/uninstaller is idempotent and touches only project-owned launcher
   files. Uninstalling does not remove Docker, Tailscale, exporters, or volumes.
6. Disable `docker.service`, `docker.socket`, and `tailscaled.service` at boot.
   Every Compose service must use `restart: "no"`.
7. Verify the Linux firewall and published bindings do not expose private ports.

### Manual-lifecycle test

The operator performs two real Linux restarts. After automatic desktop login but
before using a launcher, prove Tailscale, Docker/socket, and every project
container are inactive. Use Start, enter the password, and prove the full private
stack and routes become healthy. Use Stop and prove containers and host services
become inactive while named-volume data survives the next Start.

### Exit criteria

- Two consecutive boots leave every project service/container stopped.
- Start makes the private stack and Tailscale Serve routes healthy; Stop makes
  them inactive without deleting data.
- No private/admin port is exposed to the LAN.
- Launchers show a password prompt for privileged changes and store no password.
- The uninstall script removes only project-owned launcher files.

Stop for operator approval.

## 14. Slice 8 — Public Funnel release

### Goal

Expose only authenticated chat, required OIDC paths, and key-protected `/v1` after
all earlier gates pass.

### Files to create or modify

```text
scripts/linux/enable-funnel.sh
scripts/linux/disable-funnel.sh
scripts/verify/public-boundary.sh
docs/tailscale-runbook.md
HANDOFF.md
```

### Human approval gate

Do not implement or run the enable action until the operator explicitly approves
public exposure after reviewing the route table and Slice 0–7 evidence. The script
must require an explicit confirmation parameter and print routes before applying.

### Required verification

- Root chat route requires Discord/Authentik authentication.
- Required Authentik login/callback paths work on the same hostname.
- `/v1` rejects missing, invalid, rotated, and revoked keys.
- `/v1` accepts a current personal key and streams a response.
- Adminer, Grafana, Prometheus, PostgreSQL, Ollama, LiteLLM admin routes, Authentik
  admin/recovery routes, Docker, and exporter endpoints are unreachable publicly.
- Role removal blocks new browser and API requests within 60 seconds.
- Disable script removes Funnel exposure without destroying private Serve config or
  application data.

### Exit criteria

- The intended hostname and paths are the only public boundary.
- Revocation and rotation deadlines pass from an external network.
- After a Stop/Start cycle, only the approved public routes return; a reboot alone
  leaves Funnel and the stack offline.
- The operator has the disable command and has tested it once.

Stop. The MVP is complete only after the operator accepts the evidence.

## 15. Per-slice progress recording

Use `.agents/skills/record-slice-progress/SKILL.md` after every verification attempt.
Maintain the status table and prepend this structure under `Verification history`:

```markdown
### YYYY-MM-DD — Slice N: name

- Status: not started | in progress | blocked | passed — awaiting approval | accepted
- Environment: <sanitized host/runtime>
- Versions/digests: <exact versions and image digests>
- Commands/observations: <non-secret evidence>
- Exit criteria: <passed items and any missing item>
- Security checks: <bindings/routes/secret scan>
- Blocker or operator action: <one concrete action or none>
```

Never mark a slice passed from configuration inspection alone when its exit
criteria require the Linux Mint host, Discord, Tailscale, GPU, or a real reboot.
Passing validation does not authorize the next slice. Record
`passed — awaiting approval`, stop, and wait for explicit operator acceptance.
