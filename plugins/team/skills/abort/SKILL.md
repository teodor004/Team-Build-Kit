---
name: abort
description: Abort the active team run and clean up worktrees, branches and run state. Manual only.
disable-model-invocation: true
argument-hint: "[slug]"
---

1. Read the slug from `$ARGUMENTS` or `.po/ACTIVE`. Read `.po/<slug>/state.json`.
2. Stop all running subagents for this run (`/tasks` lists them; stop them by ID). Tell the user which ones you stopped.
3. Print, then run after explicit user confirmation:
   - `git merge --abort 2>/dev/null || true`
   - `git checkout <original_branch>`
   - `git worktree list`, then for each worktree under `.claude/worktrees/` belonging to this run: `git worktree remove <path>` (add `--force` only if the user confirms that discarding changes is fine)
   - `git worktree prune`
   - list `team/<slug>/*` and worktree branches; delete them only on confirmation with `git branch -D <name>`.
4. Set `phase = "aborted"` in state, remove `.po/ACTIVE`, and keep `.po/<slug>/` for post-mortem.
