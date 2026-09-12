# AI Passport handoff

Updated: 2026-09-12

## Next-session goal

Complete the operator-run gates in
[`docs/linux-mint-migration-guide.md`](./docs/linux-mint-migration-guide.md).
After the sanitized migration record passes, execute **Slice 0 only**. Do not
start PostgreSQL or a later slice until the operator accepts Slice 0 evidence.

## Read first

1. [`CONTEXT.md`](./CONTEXT.md) — domain language.
2. [`docs/adr/0002-linux-mint-personal-desktop-host.md`](./docs/adr/0002-linux-mint-personal-desktop-host.md)
   — accepted architecture.
3. [`docs/linux-mint-migration-guide.md`](./docs/linux-mint-migration-guide.md)
   — operator-only destructive migration and rollback gates.
4. [`docs/implementation-plan.md`](./docs/implementation-plan.md) — approved
   execution contract and hard gates.
5. [`docs/slice-1-local-inference.md`](./docs/slice-1-local-inference.md) — current
   Slice 0 implementation notes.
6. [`.agents/skills/record-slice-progress/SKILL.md`](./.agents/skills/record-slice-progress/SKILL.md)
   — mandatory verification and progress-recording workflow.

Do not duplicate or silently revise the accepted architecture. Correct facts in
ADR 0002; propose a superseding ADR for material changes. ADR 0001 is retained
only as the superseded Windows/WSL decision.

## Repository state

- Branch: `main`
- Remote: `origin` points to private GitHub repository
  `ryupol/ryu-ai-passport`.
- Latest observed commit: `fdb648d commit change in window`.
- Existing implementation: `compose.yaml`, `.env.example`,
  `scripts/ollama-smoke.sh`, and `docs/slice-1-local-inference.md`.
- Existing first slice is code-complete only as a draft. It still uses a floating
  Ollama image and `restart: unless-stopped`; it has not been verified on Mint.
- `.idea/` is pre-existing local user content. Do not add, modify, or delete it.
- Do not commit or push unless the operator explicitly asks.

## Recorded pre-migration Windows facts

- Windows 11 25H2 was last recorded as installed.
- GPU: NVIDIA GeForce RTX 3060 with 12,288 MiB dedicated VRAM.
- Last recorded Windows NVIDIA driver: `581.29`.
- System RAM: 16 GB. Keep services resource-conscious; 32 GB remains recommended
  before sustained use of the full stack.
- Ubuntu 24.04 ran under WSL2.
- Docker Desktop was removed intentionally.
- Docker Engine ran inside Ubuntu through `systemd`.
- Last recorded Docker Compose version: `5.3.1`.
- NVIDIA Container Toolkit was installed and configured in WSL.
- `docker run --rm --gpus all ubuntu nvidia-smi` previously displayed the RTX
  3060. This does not prove the future Mint host; re-verify after migration.

## Migration gate status

- Status: operator execution started; migration gates are incomplete.
- Target: Linux Mint 22.3 Cinnamon, hostname `ryupol`, native Linux repository.
- Recovery: two USB drives; USB 1 must boot official Windows Setup and remain
  unchanged, while USB 2 holds the verified Mint installer.
- Required evidence: linked same-edition Windows digital license recorded
  privately; Mint hardware checks; Secure Boot enabled; host and container
  `nvidia-smi` pass; Docker returned to disabled/inactive after testing.
- An agent must not select disks, enter credentials, change firmware, or approve
  erasure for the operator.

### Current operator checkpoint

- The operator downloaded the Linux Mint 22.3 Cinnamon ISO and flashed it to the
  available 32 GB USB using balenaEtcher.
- The USB is ready for a live-session boot test; checksum/signature verification
  has not been recorded yet.
- Only one USB is currently available. A separate Windows recovery USB has not
  been created, so obtain a second USB before erasing the internal disk if that
  recovery option is required.
- Next action: boot the target PC from the Mint USB, choose **Start Linux Mint**,
  and test networking, display, input, audio, disk identity, and NVIDIA visibility.
  Do not install or erase the disk until all migration gates pass.

## Approved decisions

- Implement one verified slice at a time and stop for approval.
- One PostgreSQL container will host isolated databases/users for Authentik, Open
  WebUI, LiteLLM, and the provisioning bot.
- Adminer is an optional local-only `tools` profile.
- The provisioning bot uses TypeScript, Node 24 LTS, strict types, Zod, Drizzle,
  controllers/models/services/repositories/clients, and unit plus PostgreSQL
  integration tests.
- Discord role events plus a 30-second reconciliation loop enforce entitlement.
- Personal keys are issued/rotated on demand and shown once through an ephemeral
  Discord response.
- Authentik uses tracked blueprints; real secrets are ignored Compose secret files
  with tracked `.example` references.
- Images and dependencies are pinned exactly; floating tags are prohibited.
- Tailscale Serve is validated privately before separately approved Funnel.
- Open WebUI 60-second chat revocation and free LiteLLM key lifecycle are hard
  compatibility gates.
- Prometheus/Grafana collect metadata-only live GPU, Linux host/container, database,
  inference, and bot health. No prompt logging or capacity prediction.
- Automatic desktop login is enabled, but administrative changes require the
  account password; credentials are never hard-coded.
- Docker/socket, Tailscale, and containers stay disabled/stopped at boot. Start
  and Stop desktop launchers request graphical authorization and control them.
- No full-disk encryption or Timeshift initially. Secure Boot stays enabled unless
  a verified NVIDIA or boot-signature failure requires an exception.

## Not configured yet

- Slice 0 has not been verified on the target host.
- No PostgreSQL, Adminer, Authentik, Open WebUI, LiteLLM, provisioning bot,
  Prometheus, or Grafana implementation exists.
- No Tailscale Serve/Funnel route is configured by this repository.
- No Discord application, bot, OAuth callback, guild ID, or role ID is configured.
- No production secret belongs in this repository.
- No Ollama model, context length, concurrency, or queue limit has been selected by
  benchmark. Those choices remain deliberately deferred.

## Known setup breadcrumb

Historical WSL-only note: Docker's apt source once contained
`https//download.docker.com/linux/ubuntu`, causing a malformed URI error. Adding
the missing colon (`https://download.docker.com/linux/ubuntu`) fixed `apt update`.
This does not establish the future Mint configuration.

## Luna start instructions

1. Check the migration gate above. If it is not passed, help only with the
   operator guide and sanitized recording; do not execute Slice 0.
2. Read all documents in **Read first** and every Slice 0 file before editing.
3. After migration, confirm `hostname` is `ryupol`, the repository is on native
   Linux storage, and inspect `git status --short` without changing unrelated work.
4. Verify current stable Ollama from its official release source and pin an exact
   version; do not choose a model for the final service.
5. Implement only Slice 0, run its verification on the Linux Mint host,
   and append sanitized evidence below.
6. Stop and ask for operator acceptance. Do not begin Slice 1 automatically.

## Slice status

| Slice | Name | Status |
| --- | --- | --- |
| 0 | Reconcile and prove local inference | not started |
| 1 | Persistence, inspection, and backups | not started |
| 2 | Local identity and chat skeleton | not started |
| 3 | Private ingress, Discord OIDC, and chat-revocation gate | not started |
| 4 | LiteLLM free-key compatibility gate | not started |
| 5 | TypeScript provisioning bot | not started |
| 6 | Metadata-only monitoring and private Grafana | not started |
| 7 | Personal-PC launchers and host hardening | not started |
| 8 | Public Funnel release | not started |

## Verification history

No slice verification has been recorded under the approved implementation
contract. After every verification attempt, use
`.agents/skills/record-slice-progress/SKILL.md` to update the status table and prepend a
sanitized evidence entry here.
