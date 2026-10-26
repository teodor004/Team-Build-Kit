# Stage C — Build fan-out (one wave at a time)

Preconditions:
- the current branch is `team/<slug>/integration`;
- `contracts/` is committed;
- Antigravity's native `workspace: "branch"` parameter branches directly from the active workspace state on `team/<slug>/integration`.

For wave W:
1. Set `state.phase = "build"` and `state.wave = W`. Select the packages with `wave == W` and status `pending`.
2. For each package, spawn its role subagent (`backend-developer`, `frontend-developer`, `test-engineer` or `docs-writer`) using `invoke_subagent` with `Workspace: "branch"` (`workspace: "branch"`) and `Model: "flash"`, ≤ `parallel` at once. Do not use legacy worktree shell scripts. The delegation prompt is the full work-package block from [../templates/work-package.md](../templates/work-package.md) plus:
   - "Contracts at `contracts/` and blueprint at `docs/blueprint/<slug>.md` are authoritative and frozen.
   - Edit only paths matching `owns`.
   - If a contract is wrong or insufficient, STOP that part and include a ccr/v1 object in `ccr[]`; do not work around it.
   - Run the package's test commands.
   - Commit all work on your isolated branch workspace (`workspace: "branch"`) with message `feat(<WP-id>): <title>`.
   - Return wp-result/v1 with `branch` (`git rev-parse --abbrev-ref HEAD`), `commit` (`git rev-parse HEAD`) and evidence for every acceptance ID."
3. Persist each result to `.po/<slug>/packages/<WP>.json` and record the branch and conversationId in state. Write any CCRs to `.po/<slug>/ccr/<id>.json` (shape: [../templates/contract-change-request.md](../templates/contract-change-request.md)) and message the PO to rule on them (approve / reject / defer). Approved CCRs are applied by the orchestrator to `contracts/` as a commit on the integration branch, and every affected package is marked `needs_recheck`.
4. Checkpoint trigger: when the wave completes, or when `checkpoint_every = N` and N packages have completed since the last checkpoint, go to [integration-checkpoint.md](integration-checkpoint.md). Do not start the next wave until the PO decides `continue`.
5. If a package returns partial or failing tests, message the same subagent via `send_message` with the failure output. This counts toward `fix_loops`, max 2. After 2, mark it `blocked` and escalate it to the checkpoint.
