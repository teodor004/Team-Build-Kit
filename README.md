# team-kit

A Claude Code plugin (`team`) and a one-plugin marketplace (`team-kit`) that turn a coding task into a gated multi-agent process:

1. **Research & Design.** Role agents research in parallel and each returns a structured brief.
2. **Consolidate.** A product-owner agent merges the briefs into one Solution Blueprint with frozen interface contracts. **Human STOP.**
3. **Build.** Implementers run in git worktrees, in waves.
4. **Integration checkpoints.** After each wave: merge, build/lint/contract tests, drift check, PO decision.
5. **Verify & ship.** Security and adversarial review, final acceptance against the original objective. **Human STOP before the final merge.**

MIT-licensed, clean-room. Every Claude Code mechanism the kit relies on was checked against the official docs; see [docs/VERIFIED.md](docs/VERIFIED.md).

The default mode is an orchestrator skill in your main session fanning out custom subagents. Agent teams are an opt-in "live team mode" ([docs/live-team-mode.md](docs/live-team-mode.md)), and dynamic workflows are used only for an optional research fan-out, because workflows allow no mid-run input and agent teams auto-approve plans, so neither can host the human STOP gates.

## Install

Requires Claude Code ≥ 2.1.296, `git`, `bash` and [`jq`](https://jqlang.org/).

```
# from a clone of this repo
claude plugin marketplace add <path-to-team-kit>
claude plugin install team@team-kit
```

For development, load it for one session without installing:

```
claude --plugin-dir <path-to-team-kit>/plugins/team
```

Then, in the **target project**:

1. Copy [extras/settings.recommended.json](extras/settings.recommended.json) to `.claude/settings.json` (merge by hand if you already have one). **Accept the workspace-trust dialog** the first time you run `claude` in the project: until you do, Claude Code ignores the `permissions.allow` entries in project settings. **`worktree.baseRef: "head"` is essential**: by default, worktrees branch from the remote default branch and implementers would not see the committed blueprint.
2. Optional: copy [extras/project-alias/team-build](extras/project-alias/team-build) to `.claude/skills/team-build` for a bare `/team-build`. Plugin skills are namespaced, so the real command is `/team:build`.
3. Optional: copy [extras/project-agents/Explore.md](extras/project-agents/Explore.md) to `.claude/agents/` to run codebase exploration on haiku. The built-in Explore uses your main model.

## Quick start

```
/team:build Build a notes app with a REST API and a web UI --parallel 3
```

The orchestrator researches, then stops at **STOP A** with the blueprint. Only an explicit *Approve* proceeds. After the build and checkpoints it stops again at **STOP B** with the exact merge command. It never pushes and never merges without your approval.

A full worked example with ten checks lives in [sample/README.md](sample/README.md).

## Flags

| Flag | Default | Meaning |
|---|---|---|
| `--auto` | off | Skip STOP A (the blueprint is auto-approved and logged). **STOP B is never skipped.** |
| `--parallel N` | 4 | Maximum concurrent subagents. Keep `CLAUDE_CODE_MAX_CONCURRENT_SUBAGENTS` ≥ N. |
| `--checkpoint-every N\|wave` | `wave` | Run an integration checkpoint after each wave, or after every N completed packages. |
| `--roles a,b,...` | all research roles | Restrict Stage A roles. |
| `--resume <slug>` | — | Continue a run from `.po/<slug>/state.json`. |

## Run state

- `.po/<slug>/` in the target project (gitignored): `state.json`, `briefs/`, `packages/`, `checkpoints/`, `ccr/`, `logs/`, `budget/`, `report.md`. `.po/ACTIVE` holds the active slug and `.po/research/` caches sources.
- Committed on branch `team/<slug>/integration` after STOP A: `contracts/` and `docs/blueprint/<slug>.md`, so worktrees see them.
- Only the main session and the product-owner write `.po/`. All other subagents return their output-contract JSON and the orchestrator persists it. A hook enforces this.
- `.claude/worktrees/` is gitignored by the orchestrator.

## Hooks (what is enforced mechanically)

| Hook | Script | Enforces |
|---|---|---|
| PreToolUse `Bash\|PowerShell` | `guard-bash.sh` | No push, `sudo`, `rm -rf /`, hard reset, curl-to-shell, `.env` reads; only the integrator merges; drift-checker is read-only |
| PreToolUse `Write\|Edit\|NotebookEdit` | `path-guard.sh` | Contracts frozen for every subagent; role write scopes; no `.env` or `.git` writes |
| PreToolUse / PostToolUse `WebSearch\|WebFetch` | `research-budget.sh` | Per-agent search/fetch budget; source index in `.po/research/index.jsonl` |
| SubagentStart / SubagentStop | `log-subagent.sh` | Injects the verbatim objective into every team agent; requires an output-contract JSON before a team agent may stop |
| UserPromptSubmit | `trigger-phrase.sh` | Nudges "build with the team" phrases toward `team:build`; reminds of an active run |
| Stop | `stop-gate.sh` | Blocks ending a turn mid-run unless `state.awaiting` is `subagents` or `human` |

Hooks fail **open** with a stderr warning if `jq` is missing, so install `jq`. Subagents are detected by `agent_id`. Ownership of implementer edits and drift are verified at checkpoints rather than prevented live.

Run the hook tests (needs `jq`): `bash tests/hooks/run.sh`.

## Abort & cleanup

`/team:abort [slug]` stops the run's subagents, then, after your confirmation, aborts any merge, returns to the original branch, removes the run's worktrees and prunes. Branches (`team/<slug>/*`) are deleted only on explicit confirmation. `.po/<slug>/` is kept for post-mortem and `phase` is set to `aborted`.

## Cost controls

- Opus is used only by the product-owner and solution-architect; everything else is pinned to sonnet or haiku. Every agent pins `model`, `effort` and `maxTurns`. The values `fable`, `best` and `inherit` are never used, and the recommended settings add `Agent(model:fable|best|inherit)` deny rules as a backstop.
- Research is capped at 6 searches and 10 fetches per agent (3 and 4 for `researcher`), enforced by hook.
- `CLAUDE_CODE_MAX_CONCURRENT_SUBAGENTS=4` and `CLAUDE_CODE_MAX_SUBAGENT_SPAWN_DEPTH=1` in the recommended settings cap parallelism and turn nesting off.
- A full run is roughly: 6 research agents, 1–3 PO passes, about 2 agents per package, and 1 + N drift-checkers per checkpoint. Start with `--parallel 3` on the sample before real projects.

## Windows / WSL notes

Built and unit-tested on native Windows 11 with Git Bash; written to also run on Linux, macOS and WSL.

- Install jq on Windows with `winget install jqlang.jq`. The scripts also look for the winget install location, because a session started before the install does not see the updated PATH.
- Hooks use shell form (`bash "${CLAUDE_PLUGIN_ROOT}/…"`), not exec form with `args`. Exec form needs a real `.exe` on Windows, and `bash` can resolve to the WSL launcher (`C:\Windows\System32\bash.exe`).
- **Start Claude Code from the exact on-disk casing of the project path** (for example `C:/Users/you/Work/proj`, not `C:/Users/you/work/proj`). With a mismatched casing the Agent tool refuses worktree isolation ("resolves to a different path") and implementers cannot start.
- Tool paths arrive with backslashes on Windows. `path-guard.sh` normalises them (and converts drive paths with `cygpath` when present).
- Keep the repo on the Linux filesystem if you run under WSL (not `/mnt/c`). `.gitattributes` forces LF line endings.
- Amazon Bedrock has no WebSearch tool. Stage A then uses WebFetch against the seed URLs in [the research playbook](plugins/team/skills/build/playbooks/research-design.md); allow-list those domains in settings.

## Known limitations / UNVERIFIED

Authoritative list with doc quotes and fallbacks: [docs/VERIFIED.md](docs/VERIFIED.md#unverified-conservative-fallback-in-parentheses). In short:

1. Whether the Skill tool accepts `team:build` from the alias skill; the alias tells the user to type `/team:build` directly.
2. Whether absolute-path Edit/Write from a worktree subagent into the main checkout is blocked (never relied on).
3. Whether plugin hooks apply to dynamic-workflow agents, and whether `agentType: 'team:<role>'` resolves in `agent()`; the workflow is optional.
4. Which model `haiku` resolves to on Bedrock, and so whether `effort` applies to it.
5. **The full `/team:build` pipeline has not been run end to end.** Live tests covered the scoped agent spawn, hook enforcement in real subagents (objective anchor, contract freeze, research budget, read-only drift-checker) and worktree isolation. Stages A-E, the STOP gates and checkpoints are specified but untested live. See [docs/VERIFIED.md § Live results](docs/VERIFIED.md#live-results-phase-6-2026-10-13-claude-code-21296-windows--git-bash-amazon-bedrock).

Other limits: ownership and drift are checked at checkpoints rather than prevented live; plugin agents cannot declare their own hooks, `permissionMode` or `mcpServers`; `askUserQuestionTimeout` can only be set in user or managed settings, and the kit treats anything but an explicit *Approve* as not approved.

## License

[MIT](LICENSE)
