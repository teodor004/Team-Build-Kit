# Stage B — Consolidate into the Solution Blueprint

1. Spawn `team:product-owner` in the foreground with:
   - the objective verbatim;
   - the paths of all briefs;
   - [../templates/blueprint.md](../templates/blueprint.md), [../templates/work-package.md](../templates/work-package.md), `parallel` and `checkpoint_every`.

   Instruction: "Merge briefs into one blueprint. Resolve conflicts explicitly in `decisions[]` (option chosen, rejected options, brief IDs). Write `.po/<slug>/blueprint.md` and draft contracts in `.po/<slug>/contracts/`:
   - `openapi.yaml` (OpenAPI 3.1);
   - `types.ts` or `schemas/*.json` (JSON Schema 2020-12);
   - `events.md` if any.

   Return blueprint/v1 JSON."
2. Validate mechanically. Reject and resume the PO (max 2 rounds) if:
   - any `owns` glob overlaps another package's `owns` (compare literal prefixes; when unsure, treat as overlap);
   - a package lacks acceptance IDs or test commands;
   - `depends_on` has a cycle;
   - wave numbers don't respect dependencies;
   - any contract path is missing on disk;
   - `definition_of_done` doesn't trace to the objective;
   - there are more than `parallel` packages in one wave (split into waves);
   - the first wave lacks a test-engineer package that writes contract tests from the contracts (test-first).
3. Compute `sha256sum` of each contract file and store it in `state.contracts[]`.
4. Set `state.phase = "consolidate"` and `awaiting = "human"`, then run STOP A from [../SKILL.md](../SKILL.md). With `--auto`, skip the question and proceed as if approved, but log `"auto_approved": true`.
