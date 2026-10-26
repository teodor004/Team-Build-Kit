---
name: team-build
description: Alias for the team-build-kit plugin orchestrator. Use when the user types /team-build or says "build with the team".
argument-hint: "<goal> [--auto] [--parallel N] [--checkpoint-every N|wave] [--resume <slug>]"
permissionMode: request-review
---
Invoke the `team-build-kit:build` skill now, passing these arguments verbatim: $ARGUMENTS

If that skill cannot be invoked from here, tell the user to type `/team-build-kit:build $ARGUMENTS` directly.
