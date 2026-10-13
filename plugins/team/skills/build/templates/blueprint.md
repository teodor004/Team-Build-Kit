# Solution Blueprint — output contract `blueprint/v1`
Write `.po/<slug>/blueprint.md` with these sections:
1. Objective (verbatim)
2. Scope / Out of scope
3. Architecture (diagram in ASCII, components, data model)
4. Decisions (ADR-style)
5. Contracts (paths)
6. Work packages
7. Checkpoints
8. Definition of done
9. Risks & UNKNOWNs

Return:

```json
{
  "contract": "blueprint/v1",
  "slug": "",
  "objective": "<verbatim>",
  "in_scope": [""], "out_of_scope": [""],
  "stack": { "backend": "", "frontend": "", "db": "", "test": "", "versions_source": ["S-ids"] },
  "contracts": [ { "id": "C-API", "path": ".po/<slug>/contracts/openapi.yaml", "kind": "openapi-3.1" } ],
  "decisions": [ { "id": "ADR-1", "choice": "", "rejected": [""], "from_briefs": ["solution-architect:R2"] } ],
  "work_packages": [
    { "id": "WP-01", "title": "", "role": "test-engineer|backend-developer|frontend-developer|docs-writer",
      "wave": 1, "owns": ["tests/contract/**"], "reads": ["contracts/**"], "depends_on": [],
      "acceptance": ["AC-BE-1"], "test_commands": ["npm test -w tests"] }
  ],
  "checkpoints": [ { "id": "CP-1", "after_wave": 1, "commands": { "build": "", "lint": "", "typecheck": "", "contract_tests": "" } } ],
  "definition_of_done": [ { "id": "DOD-1", "text": "", "traces_to_objective": "<quoted fragment>" } ],
  "risks": [""], "unknowns": [""]
}
```
