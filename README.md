# Team Build Kit (Antigravity CLI Plugin)

A native Google Antigravity CLI plugin (`team-build-kit`) located at `.agents/plugins/team-build-kit/` that turns a coding task into a gated multi-agent process:

1. **Research & Design.** Role subagents research in parallel and each returns a structured brief (`role-brief/v1`).
2. **Consolidate.** A `product-owner` agent merges the briefs into one Solution Blueprint with frozen interface contracts (`blueprint/v1`). **Human STOP A (`permissionMode: request-review`).**
3. **Build.** Parallel wave developers (`backend-developer`, `frontend-developer`, `test-engineer`, `docs-writer`) run in isolated branch workspaces (`workspace: "branch"`, `model: "flash"`, `commandExecutionPolicy: "sandbox"`), in waves.
4. **Integration checkpoints.** After each wave: merge, build/lint/contract tests, read-only drift check, PO decision.
5. **Verify & ship.** Security and adversarial review, final acceptance against the original objective. **Human STOP B (`permissionMode: request-review`) before the final merge.**

## Plugin Architecture (`.agents/plugins/team-build-kit/`)

```text
.agents/plugins/team-build-kit/
├── plugin.json         # Manifest ($schema: https://antigravity.google/schemas/v1/plugin.json)
├── hooks.json          # Deterministic PreToolUse (git_commit, run_command, write_file) & lifecycle gates
├── mcp_config.json     # External MCP connectors using serverUrl
├── agents/             # Subagents & main orchestrator with Antigravity YAML frontmatter
│   ├── orchestrator.md         # mainAgent: true, permissionMode: request-review
│   ├── product-owner.md        # subagent: true, model: pro, permissionMode: request-review
│   ├── solution-architect.md   # subagent: true, model: pro, commandExecutionPolicy: sandbox
│   ├── backend-developer.md    # subagent: true, model: flash, workspace: branch, commandExecutionPolicy: sandbox
│   ├── frontend-developer.md   # subagent: true, model: flash, workspace: branch, commandExecutionPolicy: sandbox
│   ├── test-engineer.md        # subagent: true, model: flash, workspace: branch, commandExecutionPolicy: sandbox
│   ├── docs-writer.md          # subagent: true, model: flash, workspace: branch, commandExecutionPolicy: sandbox
│   ├── security-architect.md   # subagent: true, model: flash, commandExecutionPolicy: sandbox
│   ├── ux-designer.md          # subagent: true, model: flash, commandExecutionPolicy: sandbox
│   ├── integrator.md           # subagent: true, model: flash, permissionMode: request-review
│   ├── drift-checker.md        # subagent: true, model: flash, commandExecutionPolicy: sandbox
│   ├── researcher.md           # subagent: true, model: flash, commandExecutionPolicy: sandbox
│   └── Explore.md              # subagent: true, model: flash, commandExecutionPolicy: sandbox
├── rules/
│   └── AGENTS.md       # Always-on plugin rules for contract freeze, branch isolation & review gates
├── skills/
│   ├── build/          # Primary orchestrator skill (/team-build-kit:build) + playbooks & templates
│   ├── abort/          # Cleanup skill (/team-build-kit:abort)
│   └── team-build/     # Convenience alias skill (/team-build)
└── workflows/
    └── research.py     # Native Antigravity Python workflow for Stage A parallel research
```

## Quick Start

```text
/team-build-kit:build Build a notes app with a REST API and a web UI --parallel 3
```

The orchestrator researches, then halts at **STOP A** with the blueprint (`permissionMode: request-review`). Only an explicit *Approve* proceeds. Wave implementers are spawned with Antigravity's native `workspace: "branch"` isolation. After the build and checkpoints, it halts again at **STOP B** with the exact merge command. It never pushes and never merges without your approval.

## Deterministic Hooks (`hooks.json`)

| Hook Name | Event & Matcher | Script | Enforces |
|---|---|---|---|
| `commit-test-and-adversarial-gate` | `PreToolUse` (`git_commit`) | `test-gate.sh` | Runs local test shell scripts (`tests/hooks/run.sh`), verifies frozen contract SHA-256 hashes, and scans staged diffs before the AI can commit |
| `bash-command-guard` | `PreToolUse` (`run_command\|Bash\|PowerShell`) | `guard-bash.sh` | Blocks `git push`, `sudo`, `rm -rf /`, `git reset --hard`, curl-to-shell, `.env` reads; only `integrator` merges; `drift-checker` is read-only; routes `git commit` through `test-gate.sh` |
| `path-and-contract-freeze-guard` | `PreToolUse` (`write_file\|edit_file\|Write\|Edit\|NotebookEdit`) | `path-guard.sh` | Freezes `contracts/**` for all subagents; enforces role write scopes; blocks `.env` and `.git` writes |
| `research-budget-gate` | `PreToolUse` / `PostToolUse` (`search_web\|read_url_content\|WebSearch\|WebFetch`) | `research-budget.sh` | Enforces per-agent search/fetch budgets and logs sources in `.po/research/index.jsonl` |
| `session-and-invocation-gate` | `SessionStart`, `PreInvocation`, `Stop` | `log-subagent.sh`, `trigger-phrase.sh`, `stop-gate.sh` | Injects verbatim objective, nudges team-build phrases, and prevents premature turn termination mid-run |

## License

[MIT](LICENSE)
