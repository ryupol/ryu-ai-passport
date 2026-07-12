# AI Passport handoff

## Next-session goal

Publish this repository privately to GitHub, clone it into Ubuntu 24.04 on the Windows host, create an implementation plan, then build the first reproducible Docker Compose slice. Do not enable Tailscale Funnel yet.

## Canonical project documents

- Domain language: [`CONTEXT.md`](./CONTEXT.md)
- Accepted architecture: [`docs/adr/0001-zero-cost-single-host-architecture.md`](./docs/adr/0001-zero-cost-single-host-architecture.md)

Do not duplicate or silently revise the accepted architecture. Amend ADR 0001 for factual corrections that do not change the architecture; create a superseding ADR for material architecture changes. Model choice, context length, KV-cache configuration, concurrency, and queue limits remain deliberately deferred to later benchmarks.

## Repository state

- Branch: `main`
- Existing root commit: `cde6df1 docs: record AI Passport architecture`
- `.gitignore` now excludes `.idea/`, local environment files, secrets, keys, and logs.
- `.idea/` is pre-existing local user content. Do not add, modify, or delete it.
- ADR 0001 was corrected from RTX 3060 8 GB to verified 12 GB dedicated VRAM.
- No Git remote exists yet. `ryupol/ryu-ai-passport` was checked and was available when this handoff was written.
- This environment cannot write `.git`; the user must run commit/publish commands from their shell.

Pending publish commands on the Mac:

```bash
git add .gitignore HANDOFF.md docs/adr/0001-zero-cost-single-host-architecture.md
git commit -m "chore: prepare private project repository"
gh repo create ryupol/ryu-ai-passport \
  --private \
  --source=. \
  --remote=origin \
  --push
```

## Verified Windows host state

- Windows 11 25H2 installed. Public-deployment OS gate is satisfied, subject to current security patches.
- GPU: NVIDIA GeForce RTX 3060 with 12,288 MiB dedicated VRAM.
- NVIDIA Windows driver reported as `581.29`.
- System RAM: 16 GB. Upgrade to 32 GB is recommended before the full stack, but not required for initial implementation.
- Windows reports another 8 GB as shared GPU memory. This is borrowed system RAM over PCIe, not dedicated VRAM.
- Ubuntu 24.04 runs under WSL2.
- Docker Desktop and its internal WSL distro were removed after confirming no required local Docker data.
- Docker Engine runs inside Ubuntu and reports active through `systemd`.
- Docker Compose reports version `5.3.1`.
- NVIDIA Container Toolkit is installed and configured for Docker.
- `docker run --rm --gpus all ubuntu nvidia-smi` succeeded and displayed the RTX 3060.

## Setup breadcrumb

Docker's apt source initially contained `https//download.docker.com/linux/ubuntu`, causing `E: Malformed entry 1 ... (URI parse)`. Adding the missing colon to make `https://download.docker.com/linux/ubuntu` fixed `apt update`. No other host setup error remains known.

## Not configured yet

- No Docker Compose project or implementation files exist.
- No Ollama model has been selected or benchmarked.
- No Tailscale installation, Serve configuration, or Funnel exposure has been enabled.
- No Discord application, bot, OAuth redirect, or secrets have been configured.
- No Authentik, Open WebUI, LiteLLM, Postgres, Prometheus, or Grafana containers exist.
- No production credentials or secrets exist in the repository.

## Immediate next steps

1. Publish the private GitHub repository using the commands above.
2. Clone it inside Ubuntu's Linux filesystem on the Windows host, not under `/mnt/c`.
3. Write a small implementation plan using verified vertical slices.
4. Start with Compose structure, secret-file conventions, health checks, and an Ollama GPU smoke test.
5. Keep every service private; do not enable Tailscale Funnel until routing, authentication, firewall, restart, and revocation checks pass.

## Suggested skills

- `implement` — execute the approved implementation plan.
- `codebase-design` — define stable boundaries for entitlement, credentials, ingress, inference, and observability.
- `tdd` — drive credential rotation, revocation, role-event, and queue behavior.
- `domain-modeling` — update glossary terms and create or supersede ADRs when decisions change.
- `diagnosing-bugs` — use when a real setup or runtime failure occurs.
- `verification-before-completion` — verify every host and container milestone before claiming success.
