---
name: abort
description: Abort the active team run and clean up isolated branch workspaces, branches and run state. Manual only.
disable-model-invocation: true
argument-hint: "[slug]"
---

1. Read the slug from `$ARGUMENTS` or `.po/ACTIVE`. Read `.po/<slug>/state.json`.
2. Stop all running subagents for this run using `manage_subagents` (`Action: "list"` then `Action: "kill_all"`), which automatically terminates active subagents and cleans up their `workspace: "branch"` isolated workspaces. Tell the user which ones you stopped.
3. Print, then run after explicit user confirmation (`ask_question`):
   - `git merge --abort 2>/dev/null || true`
   - `git checkout <original_branch>`
   - list `team/<slug>/*` and subagent branches; delete them only on confirmation with `git branch -D <name>`.
4. Set `phase = "aborted"` in state, remove `.po/ACTIVE`, and keep `.po/<slug>/` for post-mortem.
