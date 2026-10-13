# Run state — `.po/<slug>/state.json`
```json
{
  "contract": "state/v1",
  "slug": "",
  "objective": "<verbatim user goal>",
  "created": "YYYY-MM-DD",
  "phase": "research",
  "awaiting": "",
  "auto": false,
  "original_branch": "",
  "base_commit": "",
  "integration_branch": "",
  "contracts_commit": "",
  "contracts": [ { "path": "", "sha256": "" } ],
  "budgets": { "parallel": 4, "search": 6, "fetch": 10, "fix_loops": 2, "checkpoint_every": "wave" },
  "wave": 0,
  "packages": { "WP-01": { "status": "pending|running|done|partial|blocked|needs_recheck", "branch": "", "worktree": "", "fix_loops": 0 } },
  "checkpoints": [],
  "ccrs": [],
  "history": [ { "ts": "", "event": "" } ]
}
```
