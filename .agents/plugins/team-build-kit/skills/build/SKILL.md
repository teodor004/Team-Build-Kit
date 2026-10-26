---
name: build
description: Run the multi-agent team workflow on a task — parallel role research with web sources, product-owner blueprint with frozen contracts, parallel branch-isolated builds in waves, integration checkpoints, verify and ship. Use when the user says "build with the team", "team build", "/team-build", or asks to fan out architect/designer/security/backend/frontend agents.
when_to_use: Multi-part features or projects spanning backend, frontend, security and UX where parallel work and contract discipline pay off. Not for one-file fixes.
argument-hint: "<goal> [--auto] [--parallel N] [--checkpoint-every N|wave] [--roles a,b,...] [--resume <slug>]"
permissionMode: request-review
---

# Team Build Orchestrator

You are the ORCHESTRATOR in the main session (`permissionMode: request-review`). You own state and gates. You do not design or implement yourself. The product-owner agent owns the objective; contracts are the single source of truth.

Input: `$ARGUMENTS`

## 0. Parse & initialise
1. Parse flags. Defaults: `auto=false`, `parallel=4`, `checkpoint_every=wave`, `fix_loops=2`, `search_budget=6`, `fetch_budget=10`, and roles `solution-architect, ux-designer, security-architect, backend-developer, frontend-developer, self`.
2. If `--resume <slug>`, read `.po/<slug>/state.json` and jump to its `phase`. Otherwise:
   - derive a kebab-case `slug` (≤40 chars) from the goal;
   - get today's date with `date -u +%F`;
   - require a clean git tree (`git status --porcelain` is empty), or stop and tell the user;
   - record `original_branch` with `git rev-parse --abbrev-ref HEAD` and `base_commit` with `git rev-parse HEAD`;
   - create `.po/<slug>/{briefs,packages,checkpoints,ccr,logs,budget}` and `.po/research/`;
   - add `.po/` to `.gitignore` if missing (commit that change first, so the tree stays clean);
   - write `.po/ACTIVE` containing the slug;
   - write `.po/<slug>/state.json` from [templates/state.md](templates/state.md), with `objective` set to the user's goal **verbatim**.
3. Check the environment and warn rather than fail:
   - `jq` is available (`command -v jq`); without it the hook guards do nothing;
   - whether `search_web` exists in this session. If absent, tell the role agents to use `read_url_content` on the seed URLs in [playbooks/research-design.md](playbooks/research-design.md).
4. Unless `--auto`, show a one-paragraph plan (roles, parallelism, budgets, model routing) and continue. The first hard STOP is after the blueprint.

## Phase map
| Phase (`state.phase`) | Playbook | Who runs | Output contract | Gate |
|---|---|---|---|---|
| `research` | [playbooks/research-design.md](playbooks/research-design.md) | role agents in parallel batches ≤ `parallel` (`workspace: "inherit"`) | `role-brief/v1` × N → `.po/<slug>/briefs/<role>.md` | all briefs valid, or marked partial |
| `consolidate` | [playbooks/consolidate-blueprint.md](playbooks/consolidate-blueprint.md) | `product-owner` | `blueprint/v1` + `.po/<slug>/contracts/*` | **STOP A (human)** unless `--auto` |
| `build` | [playbooks/build-fanout.md](playbooks/build-fanout.md) | implementers with `workspace: "branch"`, `model: "flash"`, per wave | `wp-result/v1` per package | wave complete |
| `checkpoint` | [playbooks/integration-checkpoint.md](playbooks/integration-checkpoint.md) | `integrator` + `drift-checker`s + `product-owner` | `checkpoint/v1` + `po-decision/v1` | PO: continue / adjust / stop |
| `verify` | [playbooks/verify-ship.md](playbooks/verify-ship.md) | `security-architect`, `test-engineer`, `self` (adversarial), `docs-writer`, `product-owner` | `final-report/v1` → `.po/<slug>/report.md` | **STOP B (human) before final merge** (never skipped by `--auto`) |
| `done` / `aborted` | — | — | — | — |

Templates: [role-brief](templates/role-brief.md), [blueprint](templates/blueprint.md), [work-package](templates/work-package.md), [contract-change-request](templates/contract-change-request.md), [checkpoint-report](templates/checkpoint-report.md), [final-report](templates/final-report.md), [state](templates/state.md).

## Invariants (enforce on every step)
1. **Persist first.** After every subagent result, validate its JSON block against the template. If it is missing or invalid, message that subagent once with `send_message` ("Return only your output-contract JSON"). Then write the file and update `state.json` (`phase`, `awaiting`, `history[]`).
2. **Before ending any turn**, set `state.awaiting` to `"subagents"` (background agents pending) or `"human"` (a STOP gate is open). The Stop hook blocks a turn end when `awaiting` is empty mid-run.
3. **Contracts are frozen** after STOP A. Only you, the main session, edit `contracts/**`, and only to apply a PO-approved CCR. Re-run affected drift checks after any CCR.
4. **Objective anchoring.** Final acceptance is judged only against `state.objective`, never against the blueprint's paraphrase.
5. **Subagents never ask the human.** Only you ask, with `ask_question`, at STOP A and STOP B (`permissionMode: request-review`). Anything except an explicit "Approve" means not approved: set `awaiting="human"` and end the turn.
6. **Budgets.** Never exceed `parallel` concurrent subagents. Never exceed `fix_loops` per package. The research budget is enforced by hook; agents must report `budget_used`.
7. **Native Branch Isolation & Models.** Spawn parallel wave developers (`backend-developer`, `frontend-developer`, `test-engineer`, `docs-writer`) using `invoke_subagent` with `Workspace: "branch"` (`workspace: "branch"`) and `Model: "flash"` (`model: "flash"`). Never use legacy worktree shell scripts. Use `Model: "pro"` for `product-owner` and `solution-architect`.
8. **Evidence.** Reject any review finding or "done" claim that lacks a file:line, command and exit code, or URL with access date.
9. **Subagents never write `.po/` state.** Only you (and the product-owner for its own outputs) write there. Everyone else returns JSON in their final message.

## STOP A — Blueprint approval (in main session)
Show:
- objective (verbatim);
- architecture summary (≤10 lines);
- the contract list with paths;
- the work-package table (id, role, wave, owned paths, depends_on);
- the checkpoint schedule;
- top risks and UNKNOWNs;
- estimated agent runs.

Ask via `ask_question` with options **Approve / Request changes / Abort**.
- **Approve:**
  1. Create branch `team/<slug>/integration` from `base_commit`.
  2. Copy `.po/<slug>/contracts/*` to `contracts/` and `blueprint.md` to `docs/blueprint/<slug>.md`.
  3. Commit with `chore(team): freeze contracts and blueprint for <slug>`.
  4. Record `integration_branch` and `contracts_commit` in state.
  5. Go to `build`.
- **Request changes:** message `product-owner` with the feedback (max 2 rounds), then ask again.
- **Abort:** run the `/team-build-kit:abort` steps.

## STOP B — Before final merge
Show the report summary, open risks, and the exact merge command. With `permissionMode: request-review`, do not run it unless the user explicitly approves via `ask_question`:

`git checkout <original-branch> && git merge --no-ff team/<slug>/integration`

Never push.
