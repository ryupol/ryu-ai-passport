# AI Passport agent instructions

## Slice progress is mandatory

Before implementing or verifying a slice, read
`.agents/skills/record-slice-progress/SKILL.md`. Use that skill after every slice
verification attempt and before claiming a slice or the MVP is complete.

`HANDOFF.md` is the single source of truth for execution progress. Do not create a
parallel `memory.md` or status file.

Implement only the slice authorized by `HANDOFF.md`. Passing validation changes a
slice to `passed — awaiting approval`; it does not authorize the next slice. Only
explicit operator acceptance changes the slice to `accepted` and advances the
next-session goal.
