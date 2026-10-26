#!/usr/bin/env bash
# Deterministic PreToolUse Test & Adversarial Review Gate for git_commit
# Runs local test shell scripts and contract/adversarial integrity checks before the AI can commit.
. "$(dirname "$0")/lib.sh"; read_input; need_jq

tool="$(jget '.toolCall.name // .tool_name')"
cmd="$(jget '.toolCall.args.CommandLine // .toolCall.args.command // .tool_input.command')"

# If invoked via run_command/Bash, only gate when the command actually performs a git commit
if [ "$tool" = "run_command" ] || [ "$tool" = "Bash" ] || [ "$tool" = "PowerShell" ]; then
  printf '%s' "$cmd" | grep -Eiq '(^|[;&|[:space:]])git[[:space:]]+commit([[:space:]]|$)' || exit 0
fi

ROOT="$(proj)"
PLUGIN_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"

# 1. Run local hook test suite if present in repository or plugin
if [ -f "$ROOT/tests/hooks/run.sh" ]; then
  out="$(bash "$ROOT/tests/hooks/run.sh" 2>&1)" || deny_pre "Test gate failed (tests/hooks/run.sh): $out"
elif [ -f "$PLUGIN_ROOT/hooks/scripts/run-tests.sh" ]; then
  out="$(bash "$PLUGIN_ROOT/hooks/scripts/run-tests.sh" 2>&1)" || deny_pre "Test gate failed (run-tests.sh): $out"
fi

# 2. If an active team run exists, enforce contract integrity & adversarial review gate
slug="$(active_slug)"
if [ -n "$slug" ]; then
  sf="$(state_file "$slug")"
  if [ -f "$sf" ]; then
    # Verify frozen contract SHA-256 hashes if contracts are tracked in state.json
    if [ -d "$ROOT/contracts" ] && command -v sha256sum >/dev/null 2>&1; then
      while IFS=$'\t' read -r cpath chash; do
        [ -z "$cpath" ] || [ -z "$chash" ] && continue
        target="$ROOT/$cpath"
        if [ -f "$target" ]; then
          actual="$(sha256sum "$target" | awk '{print $1}')"
          if [ "$actual" != "$chash" ] && in_subagent; then
            deny_pre "Adversarial/Contract Gate: Frozen contract '$cpath' hash mismatch ($actual != $chash). File a CCR instead."
          fi
        fi
      done < <(jq -r '.contracts[]? | select(.path != "" and .sha256 != "") | "\(.path)\t\(.sha256)"' "$sf" 2>/dev/null | tr -d '\r')
    fi

    # Adversarial review check: block staged TODO/FIXME stubs or leaked secrets in staged diff
    if command -v git >/dev/null 2>&1 && git -C "$ROOT" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
      staged="$(git -C "$ROOT" diff --cached -U0 2>/dev/null)"
      if printf '%s' "$staged" | grep -Eiq '^\+.*(BEGIN (RSA|OPENSSH|EC|PRIVATE) KEY|AWS_SECRET_ACCESS_KEY)'; then
        deny_pre "Adversarial Security Gate: Private key or secret material detected in staged changes."
      fi
    fi
  fi
fi

exit 0
