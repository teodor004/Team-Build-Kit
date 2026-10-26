#!/usr/bin/env bash
. "$(dirname "$0")/lib.sh"; read_input; need_jq
prompt="$(jget '.lastUserInput // .prompt')"
case "$prompt" in /*) exit 0 ;; esac
slug="$(active_slug)"
msg=""
if [ -n "$slug" ]; then
  sf="$(state_file "$slug")"
  ph="$(jq -r '.phase // ""' "$sf" 2>/dev/null | tr -d '\r')"; aw="$(jq -r '.awaiting // ""' "$sf" 2>/dev/null | tr -d '\r')"
  case "$ph" in done|aborted|"") ;; *)
    msg="Active team run '$slug' (phase: $ph, awaiting: ${aw:-none}). Objective: $(jq -r '.objective' "$sf" 2>/dev/null | tr -d '\r'). Continue per the team:build skill protocol; do not re-plan from scratch."
  ;; esac
fi
if printf '%s' "$prompt" | grep -Eiq '(build|ship|do|make)[^.]{0,20}with (the|my) team|team[- ]build|fan[- ]out (the )?(team|agents)'; then
  nudge="The user asked for the multi-agent team workflow. Invoke the team:build (team-build-kit:build) skill with the user's goal (verbatim) as its arguments."
  if [ -n "$msg" ]; then msg="$msg"$'\n'"$nudge"; else msg="$nudge"; fi
fi
if [ -n "$msg" ]; then
  if [ -n "$(jget '.invocationNum')" ]; then
    jq -n --arg m "$msg" '{injectSteps:[{ephemeralMessage:$m}]}'
  else
    printf '%s\n' "$msg"
  fi
fi
exit 0
