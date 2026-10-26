# Stage D — Integration checkpoint protocol ("stop and check")

1. Set `state.phase = "checkpoint"`. No implementer may be running; wait for all background subagent results first.
2. Spawn `integrator` via `invoke_subagent` (`Workspace: "inherit"`) in the main checkout. Instructions:
   1. `git checkout team/<slug>/integration`.
   2. For each completed branch in dependency order, run `git merge --no-ff <branch>`. On conflict: `git merge --abort`, record the conflict, continue with the others.
   3. **Ownership check:** for each merged branch, compare `git diff --name-only <merge-base>..<branch>` against the package's `owns` globs. List violations.
   4. **Contract integrity:** run `sha256sum contracts/*` and compare against `state.contracts[]`. Any change not traceable to an approved CCR is a violation.
   5. Run the blueprint's build, lint, typecheck and contract-test commands. Capture each exit code and the last 40 lines of output.
   6. Return checkpoint/v1 ([../templates/checkpoint-report.md](../templates/checkpoint-report.md)).
3. In parallel, spawn one `drift-checker` per merged package (≤ `parallel`, read-only, `Workspace: "inherit"`, `Model: "flash"`), each with the package ID, contract paths and blueprint path. Each returns drift findings with `file:line` evidence. Merge them into the checkpoint report.
4. Persist `.po/<slug>/checkpoints/CP-<n>.json`.
5. Message `product-owner` with the objective, the checkpoint report and open CCRs. It returns po-decision/v1:
   - `continue`: next wave;
   - `adjust`: a list of fix tasks routed to the owning packages (counts toward `fix_loops`) and/or CCR rulings;
   - `stop`: go to Stage E with the current state, or abort.
6. Hard rule: a checkpoint with failing contract tests, ownership violations, or high-severity drift cannot be `continue`d.
7. Clean up completed subagents using `manage_subagents` (`Action: "kill"`) once merged. Keep branches until STOP B.
