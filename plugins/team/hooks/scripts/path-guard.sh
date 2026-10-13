#!/usr/bin/env bash
. "$(dirname "$0")/lib.sh"; read_input; need_jq
p="$(jget '.tool_input.file_path // .tool_input.notebook_path')"; role="$(role_of)"
[ -z "$p" ] && exit 0
abs="$(norm_path "$p")"
abs="$(realpath -m -- "$abs" 2>/dev/null || printf '%s' "$abs")"
podir="$(realpath -m -- "$(po)" 2>/dev/null || po)"

case "$abs" in
  */.env|*/.env.*) deny_pre "Blocked: writing secrets files." ;;
  */.git/*) deny_pre "Blocked: writing inside .git." ;;
esac

in_subagent || exit 0   # main session: the orchestrator applies approved CCRs

# Contract freeze: no subagent edits contracts/** (any checkout or worktree)
case "$abs" in */contracts/*) deny_pre "Contracts are frozen. File a contract change request (ccr/v1) in your result instead." ;; esac

case "$role" in
  product-owner|solution-architect|ux-designer|security-architect|researcher|integrator|drift-checker)
    case "$abs" in "$podir"/*) exit 0 ;; *) deny_pre "Role '$role' may write only under .po/." ;; esac ;;
  docs-writer)
    case "$abs" in */docs/*|*/README*|"$podir"/*) exit 0 ;; *) deny_pre "docs-writer may edit only README* and docs/**." ;; esac ;;
esac

# Implementers (and all others): never write into .po/ state; ownership is verified at checkpoints via git diff.
case "$role" in
  backend-developer|frontend-developer|test-engineer)
    case "$abs" in "$podir"/*) deny_pre "Implementers return JSON; only the orchestrator writes .po/." ;; esac ;;
esac
exit 0
