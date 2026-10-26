# Work package — delegation block and result contract `wp-result/v1`

Delegation block (the orchestrator fills it in):
```
WORK PACKAGE <WP-id> — <title>
Objective (verbatim): <...>
Role: <role>   Wave: <n>
OWNS (only paths you may edit): <globs>
READS: contracts/**, docs/blueprint/<slug>.md
Acceptance IDs: <ids with text>
Test commands: <cmds>
Contract rule: contracts are frozen; file a CCR instead of deviating.
```

Result (final message, JSON first):
```json
{
  "contract": "wp-result/v1",
  "wp": "WP-01",
  "status": "done|partial|blocked",
  "branch": "", "commit": "",
  "files_changed": [""],
  "tests_run": [ { "cmd": "", "exit_code": 0, "summary": "" } ],
  "acceptance": [ { "id": "AC-BE-1", "status": "met|partial|not_met", "evidence": "path:line or cmd" } ],
  "ccr": [],
  "unknowns": [""],
  "notes": ""
}
```
