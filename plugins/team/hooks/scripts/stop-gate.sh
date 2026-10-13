#!/usr/bin/env bash
. "$(dirname "$0")/lib.sh"; read_input; need_jq
[ "$(jget '.stop_hook_active')" = "true" ] && exit 0
in_subagent && exit 0   # subagents are gated by SubagentStop
slug="$(active_slug)"; [ -z "$slug" ] && exit 0
sf="$(state_file "$slug")"; [ -f "$sf" ] || exit 0
phase="$(jq -r '.phase // ""' "$sf" | tr -d '\r')"; awaiting="$(jq -r '.awaiting // ""' "$sf" | tr -d '\r')"
case "$phase" in done|aborted) exit 0 ;; esac
case "$awaiting" in human|subagents) exit 0 ;; esac
jq -n --arg p "$phase" '{decision:"block",reason:("Team run is mid-phase (" + $p + ") and state.awaiting is empty. Either continue the phase, or update .po/<slug>/state.json: set awaiting to \"subagents\" or \"human\" before ending the turn.")}'
exit 0
