#!/usr/bin/env bash
# Shared helpers for Antigravity & legacy hook payloads.
# Hooks fail OPEN (exit 0) if jq is missing, with a stderr warning.
INPUT=""
read_input() { INPUT="$(cat)"; }

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
need_jq() { find_jq || { echo "team-build-kit: jq not found; hook skipped (guards are NOT enforced)" >&2; exit 0; }; }

jget() { printf '%s' "$INPUT" | jq -r "($1) // empty" 2>/dev/null | tr -d '\r'; }

norm_path() {
  local p="${1//\\//}"
  if command -v cygpath >/dev/null 2>&1; then
    case "$p" in [A-Za-z]:/*) p="$(cygpath -u "$p" 2>/dev/null || printf '%s' "$p")" ;; esac
  fi
  printf '%s' "$p"
}
proj() {
  local p
  if [ -n "${ANTIGRAVITY_PROJECT_DIR:-}" ]; then
    p="$ANTIGRAVITY_PROJECT_DIR"
  elif [ -n "${CLAUDE_PROJECT_DIR:-}" ]; then
    p="$CLAUDE_PROJECT_DIR"
  else
    p="$(jget '.workspacePaths[0] // .cwd')"
  fi
  [ -z "$p" ] && p="$(pwd)"
  norm_path "$p"
}
po() { printf '%s/.po' "$(proj)"; }
active_slug() { [ -f "$(po)/ACTIVE" ] && tr -d '[:space:]' < "$(po)/ACTIVE"; }
state_file() { printf '%s/%s/state.json' "$(po)" "$1"; }
in_subagent() { [ -n "$(jget '.agentId // .agent_id')" ] || [ "$(jget '.subagent')" = "true" ]; }
role_of() {
  local t
  t="$(jget '.agentType // .agent_type // .role')"
  printf '%s' "${t##*:}"
}
now() { date -u +%Y-%m-%dT%H:%M:%SZ; }
is_team_role() {
  case "$1" in
    product-owner|solution-architect|ux-designer|security-architect|backend-developer|frontend-developer|test-engineer|integrator|drift-checker|researcher|docs-writer|orchestrator) return 0;;
    *) return 1;;
  esac
}
allow_pre() { jq -n '{decision:"allow"}'; exit 0; }
deny_pre() {
  jq -n --arg r "$1" '{decision:"deny",reason:$r,hookSpecificOutput:{hookEventName:"PreToolUse",permissionDecision:"deny",permissionDecisionReason:$r}}'
  exit 0
}
