# Live team mode (experimental agent teams)

Use this only for Stage C/D, after STOP A has approved the blueprint, when you want to watch and message builders live. It is opt-in; the default `/team:build` mode does not use it.

1. In `.claude/settings.local.json` set `"env": {"CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1"}`. Run an interactive session; teams don't spawn with `-p`.
2. Use the default in-process display. Split panes need tmux or iTerm2 and aren't supported in Windows Terminal or the VS Code terminal.
3. On the integration branch, prompt the lead:
   "Create an agent team for run <slug>. Spawn teammates from agent types team:backend-developer (name: backend), team:frontend-developer (name: frontend), team:test-engineer (name: tests). Use Sonnet. Create one task per work package from .po/<slug>/blueprint.md with depends_on as task dependencies, plus a task 'CP-<n> integration checkpoint' per wave that depends on that wave's packages and is assigned to the lead. Teammates must not edit outside their OWNS paths or contracts/. Wait for teammates; do not implement yourself."
4. At each CP task, the lead runs `playbooks/integration-checkpoint.md` (integrator + drift-checkers as ordinary subagents) and the PO decision.

Known constraints (each verified in [VERIFIED.md](VERIFIED.md) §6):
- Teammates share one working tree. Disjoint `owns` is mandatory, and merges are replaced by per-wave commits.
- Teammates receive a definition's `tools`, `model`, `effort` and body, but not `skills`. `disallowedTools` and `effort` apply to in-process teammates only. Passing `isolation` on the spawn call launches a plain subagent instead of a teammate.
- Plan approval requests are auto-approved by the lead without review, so they are not a human gate; STOP A/B remain in the lead.
- No `/resume` for in-process teammates. One team per session; no nested teams. Token cost grows with teammate count. The docs say to "Start with 3-5 teammates for most workflows", with 5-6 tasks per teammate.
- While teams are enabled, any subagent Claude *names* launches as a teammate, so do not run `/team:build` in default mode in the same session.
- Optional gates: a `TaskCompleted` hook (exit 2 blocks completion, e.g. when tests weren't run) and `TeammateIdle` (exit 2 keeps a teammate working). Their input fields are verified in [VERIFIED.md](VERIFIED.md) §4, but this kit ships no script for them.
- Turn teams back off (`"0"`) afterwards.
