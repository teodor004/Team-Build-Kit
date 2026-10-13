# Sample: Pocket Notes

Setup (Git Bash on Windows, or Linux/macOS/WSL):
```
mkdir ~/pocket-notes && cd ~/pocket-notes && git init && git commit --allow-empty -m init
mkdir -p .claude && cp <team-kit>/extras/settings.recommended.json .claude/settings.json
git add .claude && git commit -m "chore: claude settings"
claude --plugin-dir <team-kit>/plugins/team
```

Goal:
`/team:build Build "Pocket Notes": npm-workspaces monorepo with an Express+TypeScript REST API (SQLite), React+Vite+TypeScript web app, email+password auth with httpOnly session cookies, CRUD notes with tags and full-text search, OpenAPI 3.1 contract, WCAG 2.2 AA UI, OWASP ASVS 5.0.0 Level 1 controls, contract tests, and a README. --parallel 4`

Checks:
- T1 Stage A writes 6 briefs; each standard has a url and accessed date; `.po/research/index.jsonl` grows.
- T2 Budget: `.po/<slug>/budget/*.json` never exceeds 6/10. Force-test by setting `budgets.search` to 1 in state.json and watching for the "exhausted" denial. (On Amazon Bedrock there is no WebSearch tool; set `budgets.fetch` to 1 and watch WebFetch instead.)
- T3 STOP A halts with Approve / Request changes / Abort; nothing is built before approval.
- T4 After approval: `team/<slug>/integration` exists with `contracts/` and `docs/blueprint/<slug>.md` committed.
- T5 Wave 1 includes the contract-test package; implementers run in `.claude/worktrees/*` (`git worktree list`).
- T6 Contract freeze: ask an implementer to "also add a field to openapi.yaml"; path-guard denies it and a CCR appears.
- T7 Drift injection: after wave 1, manually rename a response field on a package branch, then rerun the checkpoint. The drift-checker reports it with path:line, contract tests fail, and the PO cannot choose `continue`.
- T8 Fix loop stops at 2 and the package is marked `blocked`.
- T9 STOP B shows the merge command and does not run it; `report.md` quotes the objective verbatim.
- T10 `/team:abort` removes worktrees (`git worktree list` is clean after prune) and sets `phase: aborted`.
