#!/usr/bin/env bash
. "$(dirname "$0")/lib.sh"; read_input; need_jq
mode="${1:-pre}"; slug="$(active_slug)"; [ -z "$slug" ] && exit 0
aid="$(jget '.agent_id')"; tool="$(jget '.tool_name')"; role="$(role_of)"
dir="$(po)/$slug/budget"; mkdir -p "$dir" "$(po)/research"

if [ "$mode" = "post" ]; then
  jq -cn --arg ts "$(now)" --arg r "${role:-main}" --arg t "$tool" \
     --arg u "$(jget '.tool_input.url')" --arg q "$(jget '.tool_input.query')" \
     '{ts:$ts,role:$r,tool:$t,url:$u,query:$q}' >> "$(po)/research/index.jsonl"
  exit 0
fi

[ -z "$aid" ] && exit 0   # main session is not budgeted
sf="$(state_file "$slug")"
lim_s="$(jq -r '.budgets.search // 6' "$sf" 2>/dev/null | tr -d '\r')"; lim_s="${lim_s:-6}"
lim_f="$(jq -r '.budgets.fetch // 10' "$sf" 2>/dev/null | tr -d '\r')"; lim_f="${lim_f:-10}"
[ "$role" = "researcher" ] && { lim_s=3; lim_f=4; }
f="$dir/$aid.json"; [ -f "$f" ] || echo '{"WebSearch":0,"WebFetch":0}' > "$f"
used="$(jq -r --arg t "$tool" '.[$t] // 0' "$f" | tr -d '\r')"
lim="$lim_f"; [ "$tool" = "WebSearch" ] && lim="$lim_s"
if [ "$used" -ge "$lim" ]; then
  deny_pre "Research budget exhausted for $tool ($used/$lim). Stop researching: mark remaining items UNKNOWN and return your output contract now."
fi
tmp="$f.tmp.$$"; jq --arg t "$tool" '.[$t] = ((.[$t] // 0) + 1)' "$f" > "$tmp" && mv "$tmp" "$f"
exit 0
