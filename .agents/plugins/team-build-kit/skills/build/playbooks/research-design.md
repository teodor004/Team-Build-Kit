# Stage A — Research & Design

1. Set `state.phase = "research"`.
2. Build one delegation prompt per role from [../templates/role-brief.md](../templates/role-brief.md). Each prompt includes:
   - the objective verbatim;
   - the slug and today's date;
   - the role's focus questions (below);
   - the budget (≤ `search_budget` `search_web` calls, ≤ `fetch_budget` `read_url_content` calls);
   - "read `.po/research/` notes first; re-use cached sources";
   - the **seed URLs** below, and, when `search_web` is unavailable, "use `read_url_content` on these URLs instead of searching";
   - a brownfield hint (key dirs, if a codebase exists);
   - "Return ONLY the role-brief/v1 JSON block followed by a ≤300-word markdown rationale."
3. Spawn in batches of ≤ `parallel` via `invoke_subagent` (`Workspace: "inherit"`):
   - `solution-architect` (`Model: "pro"`);
   - `ux-designer` (`Model: "flash"`);
   - `security-architect` (`Model: "flash"`);
   - `backend-developer` and `frontend-developer` (`Model: "flash"`, `Workspace: "inherit"`, research mode: "Do not edit files");
   - built-in `self` with `Model: "flash"` as integration-risk generalist and devil's advocate.
   - For brownfield repos, first run `research` or `Explore` (`Model: "flash"`) to map the codebase, and pass the summary to all roles.
4. Focus questions:
   - **solution-architect:** stack choice with current LTS/versions from official docs, component boundaries, data model, API style, deployment, ADRs.
   - **ux-designer:** user flows, ASCII wireframes, component inventory, WCAG 2.2 AA success criteria that apply, empty/loading/error states.
   - **security-architect:** threat model (STRIDE per trust boundary), auth/session design, OWASP ASVS 5.0.0 requirement IDs at the chosen level (cite as `v5.0.0-<ch>.<sec>.<req>`), OWASP Top 10 mapping (verify the current edition online), secrets handling.
   - **backend-developer:** framework idioms, validation, error model (RFC 9457 problem details if adopted), persistence, migrations, test strategy.
   - **frontend-developer:** framework/router/state choices, API client generation from the contract, accessibility implementation, test strategy.
   - **self (devil's advocate):** cross-role conflicts, integration risks, what is most likely to drift, a missing-requirements list.
5. On each result, validate and persist to `.po/<slug>/briefs/<role>.md` (the JSON block first, then the rationale). A result marked partial is persisted with `"partial": true`.
6. When all briefs are in, set `state.phase = "consolidate"`.

Reject any brief that:
- has claims without `url` and `accessed`;
- guesses versions instead of writing `UNKNOWN`;
- has no acceptance criteria.

Message the subagent once via `send_message` with the specific defect. If it still fails, persist it as partial and flag it to the PO.

## Seed URLs (primary sources; fetch these when search is unavailable)

| Topic | URL |
|---|---|
| OWASP ASVS | https://owasp.org/www-project-application-security-verification-standard/ |
| OWASP Top 10 | https://owasp.org/www-project-top-ten/ |
| OWASP Cheat Sheets | https://cheatsheetseries.owasp.org/ |
| WCAG 2.2 | https://www.w3.org/TR/WCAG22/ |
| WAI-ARIA Authoring Practices | https://www.w3.org/WAI/ARIA/apg/ |
| OpenAPI 3.1 | https://spec.openapis.org/oas/v3.1.0 |
| JSON Schema | https://json-schema.org/specification |
| Problem Details (RFC 9457) | https://www.rfc-editor.org/rfc/rfc9457 |
| Node.js releases / LTS | https://nodejs.org/en/about/previous-releases |
| React | https://react.dev/ |
| Vite | https://vite.dev/guide/ |
| Express | https://expressjs.com/ |
| TypeScript | https://www.typescriptlang.org/docs/ |
| MDN Web Docs | https://developer.mozilla.org/ |
