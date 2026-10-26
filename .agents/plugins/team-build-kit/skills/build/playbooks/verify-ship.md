# Stage E — Verify & ship

1. Set `state.phase = "verify"`. Spawn these in parallel (≤ `parallel`) via `invoke_subagent`:
   - `security-architect` (`Workspace: "inherit"`, `Model: "flash"`) in review mode: ASVS requirement IDs from its brief → verified / failed / not-applicable, each with evidence (file:line or command output). Also dependency audit output (`npm audit --omit=dev` or the stack equivalent) and secret scan results (`git grep -nE '(api[_-]?key|secret|password)\s*[:=]'`, then a manual triage).
   - `test-engineer` (`Workspace: "branch"`, `Model: "flash"`): full test suite plus coverage, and a contract test re-run against the running app if feasible.
   - built-in `self` with `Model: "flash"` (`Workspace: "inherit"`) as adversarial reviewer: "Try to break it. Each finding needs a reproduction (command plus observed vs. expected). No speculative findings."
   - `docs-writer` (`Workspace: "branch"`, `Model: "flash"`): README, run instructions, API docs generated from the contract, on its own isolated branch workspace (merge it at the end).
2. Route fixes as in [build-fanout.md](build-fanout.md) (max `fix_loops`), then run one final checkpoint ([integration-checkpoint.md](integration-checkpoint.md)).
3. Spawn `product-owner` (`Workspace: "inherit"`, `Model: "pro"`) for final acceptance against **state.objective verbatim** and `definition_of_done`. Each item is met / not met, with evidence links. It writes `.po/<slug>/report.md` from [../templates/final-report.md](../templates/final-report.md).
4. Set `awaiting = "human"` and run STOP B from [../SKILL.md](../SKILL.md). After the user approves the merge (`permissionMode: request-review`): `phase = "done"`, delete `.po/ACTIVE`, terminate remaining subagents via `manage_subagents` (`Action: "kill_all"`), and list `team/<slug>/*` branches for optional deletion.
