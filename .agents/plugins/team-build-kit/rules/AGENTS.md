# Team Build Kit — Workspace & Plugin Rules

When operating in a `team-build-kit` multi-agent workflow:

1. **Contract Discipline (Frozen Contracts)**:
   - Once **STOP A** (Blueprint Approval) completes, all files in `contracts/**` and `docs/blueprint/<slug>.md` are frozen and authoritative.
   - Subagents (`subagent: true`, `mainAgent: false`) must **never** edit `contracts/**` directly. If a contract is incomplete or contradictory, emit a Contract Change Request (`ccr/v1`) in the output payload.
   - Only the main orchestrator (`permissionMode: request-review`) may update `contracts/**` after an explicit `product-owner` ruling.

2. **Native Branch Workspace Isolation**:
   - Parallel wave implementers (`backend-developer`, `frontend-developer`, `test-engineer`, `docs-writer`) must always be invoked using Antigravity's native `workspace: "branch"` parameter (`Workspace: "branch"` on `invoke_subagent`), `model: "flash"`, and `commandExecutionPolicy: "sandbox"`.
   - Do not use legacy worktree simulation scripts or `.claude/worktrees/` paths.
   - Implementers may only modify files matching their assigned `owns` globs and must never write to `.po/`.

3. **Human-in-the-Loop Gates (`permissionMode: request-review`)**:
   - **STOP A**: Present the consolidated Solution Blueprint (`blueprint/v1`) and wait for explicit human approval before creating `team/<slug>/integration` or spawning wave builders.
   - **STOP B**: Present the final verification report (`final-report/v1`) and exact merge command, and require explicit human approval before merging into the original branch.
   - Never run `git push`, `git reset --hard`, or `sudo`.

4. **Deterministic Test & Adversarial Review Gate**:
   - Every commit (`git_commit` / `git commit`) is gated by `hooks.json` (`PreToolUse`), which executes the test and adversarial review verification gate before allowing the commit.
   - Every claim in research briefs, drift reports, security reviews, and acceptance checks must include verifiable evidence (`file:line`, command + exit code, or primary-source URL + access date). Mark unverified facts as `UNKNOWN`.
