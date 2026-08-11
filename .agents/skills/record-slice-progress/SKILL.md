---
name: record-slice-progress
description: Verify and record AI Passport implementation-slice outcomes in HANDOFF.md. Use automatically whenever an implementation slice is tested, passes, fails, becomes blocked, is presented for approval, or is accepted; also use before claiming a slice or the MVP is complete.
---

# Record Slice Progress

Keep `HANDOFF.md` as the only execution-progress record. Do not create or update a
second `memory.md`, status document, or private agent state.

## Workflow

1. Read `docs/implementation-plan.md`, `HANDOFF.md`, and the current slice's
   changed files.
2. Identify every command, hard gate, security check, and exit criterion for the
   current slice.
3. Run all checks that the required environment permits. Do not replace a target
   Windows/WSL, GPU, Discord, Tailscale, external-network, or cold-boot check with
   inspection or a test on another host.
4. Build an evidence matrix internally: one row per exit criterion with the
   command or observation that proves it.
5. Update `HANDOFF.md` in the same change before reporting the slice outcome.
6. Run `git diff --check` and verify the handoff does not contain secrets.

## Status rules

Use only these slice states:

- `not started` — no implementation attempt exists.
- `in progress` — implementation exists but required validation is incomplete.
- `blocked` — a hard gate or external dependency prevents completion.
- `passed — awaiting approval` — every exit criterion passed, but the operator
  has not accepted the slice.
- `accepted` — every exit criterion passed and the operator explicitly accepted
  the slice.

Never mark `passed — awaiting approval` from code review, Compose rendering, mocks,
or partial tests when the plan requires a real service or target-host check. Never
mark `accepted` on the operator's behalf.

## Required HANDOFF.md update

Update all affected sections, not only the evidence entry:

1. Set the `Updated` date.
2. Reconcile repository state and the `Not configured yet` list with observable
   facts.
3. Update the current row in `Slice status`.
4. Prepend one entry under `Verification history`; never erase prior entries.
5. Set `Next-session goal` according to the outcome:
   - incomplete or blocked: finish/unblock the current slice;
   - passed: ask the operator to review the current slice, with no later slice
     authorized;
   - accepted: name the next slice only; after Slice 8, state that the MVP is
     accepted.

Each verification-history entry must include:

```markdown
### YYYY-MM-DD — Slice N: name

- Status: <allowed status>
- Environment: <sanitized host/runtime>
- Versions/digests: <exact versions or not applicable>
- Commands/observations: <non-secret evidence>
- Exit criteria: <passed items and any missing item>
- Security checks: <bindings, routes, secret/log checks>
- Blocker or operator action: <one concrete action or none>
```

## Safety

- Sanitize hostnames, user names, tokens, keys, cookies, OAuth codes, passwords,
  prompt content, and generated content.
- Record a secret file's existence/permissions, never its value.
- Do not commit, push, enable Funnel, or advance to another slice through this
  skill.
- On failure, preserve the exact sanitized failure evidence and the doubtful
  assumption. Do not weaken an exit criterion to obtain a pass.
