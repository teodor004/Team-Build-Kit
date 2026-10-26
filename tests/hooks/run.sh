#!/usr/bin/env bash
# Usage: bash tests/hooks/run.sh   (run from the repo root)
# Pipes fixture JSON into each hook script and asserts stdout / exit code.
set -u
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
S="$ROOT/.agents/plugins/team-build-kit/hooks/scripts"; F="$ROOT/tests/hooks/fixtures"
. "$S/lib.sh"; find_jq || { echo "jq not found: install it (winget install jqlang.jq / apt install jq) to run the hook tests"; exit 2; }

pass=0; fail=0
T="$(mktemp -d)"; export CLAUDE_PROJECT_DIR="$T"; mkdir -p "$T/.po/demo"
echo demo > "$T/.po/ACTIVE"
reset_state() { echo '{"objective":"Build X","phase":"build","awaiting":"","budgets":{"search":1,"fetch":1}}' > "$T/.po/demo/state.json"; rm -rf "$T/.po/demo/budget"; }
reset_state

fixture() { sed "s#__PROJ__#$T#g" "$F/$1.json"; }
# check <name> <script> <arg> <fixture> <regex-the-stdout-must-match>   (regex '^$' = must print nothing)
check() {
  local name="$1" script="$2" arg="$3" fx="$4" expect="$5" out
  out="$(fixture "$fx" | bash "$S/$script" $arg 2>/dev/null)"
  if { [ "$expect" = '^$' ] && [ -z "$out" ]; } || { [ "$expect" != '^$' ] && printf '%s' "$out" | grep -Eq -- "$expect"; }; then
    pass=$((pass+1))
  else
    fail=$((fail+1)); echo "FAIL $name [$fx]: got: ${out:0:160}"
  fi
}

# guard-bash
check push-sub       guard-bash.sh "" bash-push        '"deny"'
check push-main      guard-bash.sh "" bash-push-main   '"deny"'
check rmrf           guard-bash.sh "" bash-rmrf        '"deny"'
check sudo           guard-bash.sh "" bash-sudo        '"deny"'
check curl-sh        guard-bash.sh "" bash-curlsh      '"deny"'
check read-env       guard-bash.sh "" bash-env         '"deny"'
check merge-sub      guard-bash.sh "" bash-merge-sub   'only the integrator merges'
check merge-integ    guard-bash.sh "" bash-merge-integ '^$'
check merge-main     guard-bash.sh "" bash-merge-main  '^$'
check npm-test       guard-bash.sh "" bash-npmtest     '^$'
check drift-redirect guard-bash.sh "" bash-drift-write 'read-only'
check drift-rm       guard-bash.sh "" bash-drift-rm    'read-only'
check drift-inspect  guard-bash.sh "" bash-drift-read  '^$'
# path-guard
check freeze         path-guard.sh "" path-freeze      'frozen'
check freeze-winpath path-guard.sh "" path-freeze-win  'frozen'
check freeze-main-ok path-guard.sh "" path-freeze-main '^$'
check env-write      path-guard.sh "" path-env         'secrets'
check po-writes-po   path-guard.sh "" path-po-ok       '^$'
check po-not-src     path-guard.sh "" path-po-bad      'only under .po'
check impl-no-po     path-guard.sh "" path-impl-po     'only the orchestrator'
check impl-src-ok    path-guard.sh "" path-impl-src    '^$'
check docs-not-src   path-guard.sh "" path-docs-bad    'README'
check docs-readme    path-guard.sh "" path-docs-ok     '^$'
# research-budget (limits: 1 search, 1 fetch per agent)
check budget-s1      research-budget.sh pre budget-search '^$'
check budget-s2      research-budget.sh pre budget-search 'exhausted'
check budget-f1      research-budget.sh pre budget-fetch  '^$'
check budget-f2      research-budget.sh pre budget-fetch  'exhausted'
check budget-main    research-budget.sh pre budget-main   '^$'
# log-subagent
check anchor         log-subagent.sh start sub-start       'OBJECTIVE'
check anchor-other   log-subagent.sh start sub-start-other '^$'
check ogate-block    log-subagent.sh stop  sub-stop-bad    '"block"'
check ogate-ok       log-subagent.sh stop  sub-stop-ok     '^$'
check ogate-loop     log-subagent.sh stop  sub-stop-active '^$'
# stop-gate
check stop-block     stop-gate.sh "" stop-main   '"block"'
check stop-active    stop-gate.sh "" stop-active '^$'
check stop-subagent  stop-gate.sh "" stop-sub    '^$'
# trigger-phrase
check trigger        trigger-phrase.sh "" prompt-trigger 'team:build'
check trigger-run    trigger-phrase.sh "" prompt-trigger 'Active team run'
check trigger-slash  trigger-phrase.sh "" prompt-slash   '^$'

# state-dependent: awaiting set -> stop allowed
echo '{"objective":"Build X","phase":"build","awaiting":"human","budgets":{}}' > "$T/.po/demo/state.json"
check stop-awaiting  stop-gate.sh "" stop-main '^$'

# side effects
[ -s "$T/.po/demo/logs/agents.jsonl" ] && pass=$((pass+1)) || { fail=$((fail+1)); echo "FAIL logs/agents.jsonl not written"; }
if find "$T" -type f -not -path "$T/.po/*" | grep -q .; then fail=$((fail+1)); echo "FAIL a script wrote outside .po/"; else pass=$((pass+1)); fi

# fail-open without jq (skipped when the system bash PATH already provides jq)
if [ ! -x /usr/bin/jq ] && [ ! -x /bin/jq ] && [ ! -x /usr/local/bin/jq ]; then
  err="$(printf '{}' | env PATH=/usr/bin:/bin LOCALAPPDATA= bash "$S/guard-bash.sh" 2>&1 >/dev/null)"; rc=$?
  if [ "$rc" -eq 0 ] && printf '%s' "$err" | grep -q 'jq not found'; then pass=$((pass+1)); else fail=$((fail+1)); echo "FAIL fail-open (rc=$rc): $err"; fi
else
  echo "skip fail-open test: jq is installed in a system bin dir"
fi

echo "passed=$pass failed=$fail"; rm -rf "$T"; [ "$fail" -eq 0 ]
