# Stage E — Verify & ship

1. Set `state.phase = "verify"`. Spawn these in parallel (≤ `parallel`):
   - `team:security-architect` in review mode: ASVS requirement IDs from its brief → verified / failed / not-applicable, each with evidence (file:line or command output). Also dependency audit output (`npm audit --omit=dev` or the stack equivalent) and secret scan results (`git grep -nE '(api[_-]?key|secret|password)\s*[:=]'`, then a manual triage).
   - `team:test-engineer`: full test suite plus coverage, and a contract test re-run against the running app if feasible.
   - built-in `general-purpose` with `model: "sonnet"` as adversarial reviewer: "Try to break it. Each finding needs a reproduction (command plus observed vs. expected). No speculative findings."
   - `team:docs-writer`: README, run instructions, API docs generated from the contract, on its own package branch (merge it at the end).
2. Route fixes as in [build-fanout.md](build-fanout.md) (max `fix_loops`), then run one final checkpoint ([integration-checkpoint.md](integration-checkpoint.md)).
3. Spawn `team:product-owner` for final acceptance against **state.objective verbatim** and `definition_of_done`. Each item is met / not met, with evidence links. It writes `.po/<slug>/report.md` from [../templates/final-report.md](../templates/final-report.md).
4. Set `awaiting = "human"` and run STOP B from [../SKILL.md](../SKILL.md). After the user approves the merge: `phase = "done"`, delete `.po/ACTIVE`, and print the cleanup commands (`git worktree prune`; list `team/<slug>/*` branches for deletion).
