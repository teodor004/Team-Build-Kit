#!/usr/bin/env bash
. "$(dirname "$0")/lib.sh"; read_input; need_jq
prompt="$(jget '.prompt')"
case "$prompt" in /*) exit 0 ;; esac   # explicit slash commands pass through
slug="$(active_slug)"
if [ -n "$slug" ]; then
  sf="$(state_file "$slug")"
  ph="$(jq -r '.phase // ""' "$sf" 2>/dev/null | tr -d '\r')"; aw="$(jq -r '.awaiting // ""' "$sf" 2>/dev/null | tr -d '\r')"
  case "$ph" in done|aborted|"") ;; *)
    echo "Active team run '$slug' (phase: $ph, awaiting: ${aw:-none}). Objective: $(jq -r '.objective' "$sf" 2>/dev/null | tr -d '\r'). Continue per the team:build skill protocol; do not re-plan from scratch."
  ;; esac
fi
if printf '%s' "$prompt" | grep -Eiq '(build|ship|do|make)[^.]{0,20}with (the|my) team|team[- ]build|fan[- ]out (the )?(team|agents)'; then
  echo "The user asked for the multi-agent team workflow. Invoke the team:build skill with the user's goal (verbatim) as its arguments."
fi
exit 0
