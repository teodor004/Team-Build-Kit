# Checkpoint report — `checkpoint/v1` (+ PO decision `po-decision/v1`)
```json
{
  "contract": "checkpoint/v1",
  "id": "CP-1",
  "integration_commit": "",
  "merged": ["WP-01"], "conflicts": [ { "wp": "", "files": [""] } ],
  "checks": { "build": { "cmd": "", "exit_code": 0, "tail": "" }, "lint": {}, "typecheck": {}, "contract_tests": {} },
  "ownership_violations": [ { "wp": "", "file": "" } ],
  "contract_integrity": { "ok": true, "changed": [] },
  "drift": [ { "wp": "", "contract_id": "", "finding": "", "evidence": "file:line", "severity": "high|medium|low" } ],
  "recommendation": "continue|adjust|stop"
}
```
```json
{
  "contract": "po-decision/v1",
  "checkpoint": "CP-1",
  "decision": "continue|adjust|stop",
  "objective_alignment": "one sentence against the verbatim objective",
  "actions": [ { "wp": "", "task": "" } ],
  "ccr_rulings": [ { "id": "", "status": "approved|rejected|deferred", "rationale": "" } ]
}
```
