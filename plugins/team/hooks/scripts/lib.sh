#!/usr/bin/env bash
# Shared helpers. Hooks fail OPEN (exit 0) if jq is missing, with a stderr warning.
# Subagent detection uses agent_id (agent_type is also set in `claude --agent` main sessions).
INPUT=""
read_input() { INPUT="$(cat)"; }

# jq lookup: PATH first, then the winget install location (a session started before the
# install does not see the updated PATH).
find_jq() {
  command -v jq >/dev/null 2>&1 && return 0
  local base p
  base="${LOCALAPPDATA:-}"
  [ -n "$base" ] || return 1
  base="$(cygpath -u "$base" 2>/dev/null || printf '%s' "$base")"
  for p in "$base"/Microsoft/WinGet/Packages/jqlang.jq*/; do
    if [ -x "${p}jq.exe" ]; then PATH="$PATH:${p%/}"; export PATH; return 0; fi
  done
  return 1
}
need_jq() { find_jq || { echo "team-kit: jq not found; hook skipped (guards are NOT enforced)" >&2; exit 0; }; }

jget() { printf '%s' "$INPUT" | jq -r "($1) // empty" 2>/dev/null | tr -d '\r'; }

# Normalise a path: backslashes to slashes, and C:/x to /c/x when cygpath exists (Windows Git Bash).
norm_path() {
  local p="${1//\\//}"
  if command -v cygpath >/dev/null 2>&1; then
    case "$p" in [A-Za-z]:/*) p="$(cygpath -u "$p" 2>/dev/null || printf '%s' "$p")" ;; esac
  fi
  printf '%s' "$p"
}
proj() {
  local p
  if [ -n "${CLAUDE_PROJECT_DIR:-}" ]; then p="$CLAUDE_PROJECT_DIR"; else p="$(jget '.cwd')"; fi
  norm_path "$p"
}
po() { printf '%s/.po' "$(proj)"; }
active_slug() { [ -f "$(po)/ACTIVE" ] && tr -d '[:space:]' < "$(po)/ACTIVE"; }
state_file() { printf '%s/%s/state.json' "$(po)" "$1"; }
in_subagent() { [ -n "$(jget '.agent_id')" ]; }
role_of() { local t; t="$(jget '.agent_type')"; printf '%s' "${t##*:}"; }   # strip plugin prefix "team:"
now() { date -u +%Y-%m-%dT%H:%M:%SZ; }
is_team_role() { case "$1" in product-owner|solution-architect|ux-designer|security-architect|backend-developer|frontend-developer|test-engineer|integrator|drift-checker|researcher|docs-writer) return 0;; *) return 1;; esac; }
deny_pre() { jq -n --arg r "$1" '{hookSpecificOutput:{hookEventName:"PreToolUse",permissionDecision:"deny",permissionDecisionReason:$r}}'; exit 0; }
