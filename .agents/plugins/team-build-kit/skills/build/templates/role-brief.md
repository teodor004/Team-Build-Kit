# Role brief — output contract `role-brief/v1`
Return exactly one fenced JSON block first, then a rationale of ≤300 words.

```json
{
  "contract": "role-brief/v1",
  "slug": "",
  "role": "",
  "partial": false,
  "standards": [
    { "id": "S1", "title": "", "publisher": "", "version": "", "url": "", "accessed": "YYYY-MM-DD", "supports": ["R1"] }
  ],
  "recommendation": [
    { "id": "R1", "text": "", "sources": ["S1"], "confidence": "high|medium|low" }
  ],
  "interfaces": [
    { "name": "", "kind": "http|event|ui-component|db|type", "sketch": "", "owner_role": "" }
  ],
  "risks": [ { "id": "K1", "text": "", "severity": "high|medium|low", "mitigation": "" } ],
  "open_questions": [""],
  "unknowns": ["UNKNOWN: <what> — <why not resolved>"],
  "acceptance_criteria": [ { "id": "AC-<ROLE>-1", "text": "", "verify_by": "test|review|command", "how": "" } ],
  "budget_used": { "searches": 0, "fetches": 0 }
}
```
Rules:
- every recommendation cites ≥1 standard;
- prefer official docs, standards and RFCs;
- never invent versions, URLs or IDs: write UNKNOWN.
