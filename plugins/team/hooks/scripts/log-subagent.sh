#!/usr/bin/env bash
. "$(dirname "$0")/lib.sh"; read_input; need_jq
mode="${1:-start}"; slug="$(active_slug)"; [ -z "$slug" ] && exit 0
role="$(role_of)"; aid="$(jget '.agent_id')"; sf="$(state_file "$slug")"
mkdir -p "$(po)/$slug/logs"
jq -cn --arg ts "$(now)" --arg ev "$mode" --arg r "$role" --arg a "$aid" '{ts:$ts,event:$ev,role:$r,agent_id:$a}' >> "$(po)/$slug/logs/agents.jsonl"

if [ "$mode" = "start" ]; then
  is_team_role "$role" || [ "$role" = "general-purpose" ] || exit 0
  obj="$(jq -r '.objective // ""' "$sf" 2>/dev/null | tr -d '\r')"; phase="$(jq -r '.phase // ""' "$sf" 2>/dev/null | tr -d '\r')"
  ctx="TEAM RUN '$slug' (phase: $phase). OBJECTIVE (verbatim, owned by product-owner): $obj
RULES: contracts/ are frozen (file ccr/v1 instead); cite URL + access date for every external claim; write UNKNOWN instead of guessing; stay inside your OWNS paths; never ask the human; end with your output-contract JSON block."
  jq -n --arg c "$ctx" '{hookSpecificOutput:{hookEventName:"SubagentStart",additionalContext:$c}}'
  exit 0
fi

# stop: output-contract gate (one retry only; respects stop_hook_active)
is_team_role "$role" || exit 0
[ "$(jget '.stop_hook_active')" = "true" ] && exit 0
msg="$(jget '.last_assistant_message')"
[ -z "$msg" ] && exit 0   # field absent on older versions: do not block
printf '%s' "$msg" | grep -q '"contract"' && exit 0
jq -n '{decision:"block",reason:"Return your output-contract JSON block now (see your template). Do not start new work."}'
exit 0
