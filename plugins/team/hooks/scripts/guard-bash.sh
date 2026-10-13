#!/usr/bin/env bash
. "$(dirname "$0")/lib.sh"; read_input; need_jq
cmd="$(jget '.tool_input.command')"; role="$(role_of)"
[ -z "$cmd" ] && exit 0
m() { printf '%s' "$cmd" | grep -Eiq -- "$1"; }

m '(^|[;&|[:space:]])rm[[:space:]]+-[a-z]*[rf][a-z]*[[:space:]]+(/|~|\$HOME|\.\.?)([[:space:]/]|$)' && deny_pre "Blocked: recursive delete of root/home/parent."
m '(^|[;&|[:space:]])sudo([[:space:]]|$)'           && deny_pre "Blocked: sudo is not allowed in team runs."
m 'git[[:space:]]+push'                             && deny_pre "Blocked: pushing is a human-only action (STOP B)."
m 'git[[:space:]]+reset[[:space:]]+--hard'          && deny_pre "Blocked: git reset --hard destroys work; ask the orchestrator."
m 'git[[:space:]]+clean[[:space:]]+-[a-z]*f'        && deny_pre "Blocked: git clean -f."
m '(curl|wget)[^|]*\|[[:space:]]*(sudo[[:space:]]+)?(ba|z)?sh' && deny_pre "Blocked: piping downloads into a shell."
m 'chmod[[:space:]]+-R[[:space:]]+777|mkfs|dd[[:space:]].*of=/dev/|:\(\)[[:space:]]*\{' && deny_pre "Blocked: destructive system command."
m '(npm|pnpm|yarn)[[:space:]]+publish|docker[[:space:]]+system[[:space:]]+prune' && deny_pre "Blocked: publish/prune."
m '(cat|less|head|tail|grep|type|Get-Content)[^|;]*\.env([^a-z]|$)' && deny_pre "Blocked: reading .env secrets."

# Subagent-only restrictions (main session has no agent_id)
if in_subagent; then
  if [ "$role" != "integrator" ] && m 'git[[:space:]]+(merge|rebase|cherry-pick)'; then deny_pre "Blocked: only the integrator merges."; fi
  m 'git[[:space:]]+(checkout|switch)[[:space:]]+(main|master)([[:space:]]|$)' && deny_pre "Blocked: subagents may not switch to the default branch."
  m 'git[[:space:]]+branch[[:space:]]+-D' && deny_pre "Blocked: branch deletion is human-only."

  # drift-checker is read-only: no redirects into files, no mutating commands.
  if [ "$role" = "drift-checker" ]; then
    stripped="$(printf '%s' "$cmd" | sed -E 's#[0-9]*>>?[[:space:]]*/dev/null##g')"
    if printf '%s' "$stripped" | grep -Eiq '>[[:space:]]*[^&[:space:]]|(^|[;&|[:space:]])(tee|rm|mv|cp|touch|mkdir|chmod|truncate)([[:space:]]|$)|sed[[:space:]]+-i|git[[:space:]]+(add|commit|merge|rebase|checkout|switch|reset|stash|apply|restore|clean)'; then
      deny_pre "Blocked: drift-checker is read-only (inspection commands only)."
    fi
  fi
fi
exit 0
