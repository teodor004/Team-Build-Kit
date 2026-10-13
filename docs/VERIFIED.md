# Verification log (Phase 0)

- **Access date:** 2026-10-13 (all rows).
- **Installed Claude Code:** 2.1.296. That is at or above every version-gated feature below.
- **Method:**
  - Raw markdown was fetched with `curl https://code.claude.com/docs/en/<page>.md` from the 22 pages listed in Rule 2, plus `changelog`, `plugins/cli-reference`, `plugins/loading`, `plugins/create`, `plugins/install` and `plugins/troubleshooting`.
  - Every quote below is an exact substring of one line of the fetched page. A script checked all of them with `grep -F`.
  - In table cells, `\|` stands for a literal `|` in the source.
- **Status values:**
  - `VERIFIED`: the docs match the build prompt.
  - `PARTIAL`: the docs match with a caveat; see Deviations.
  - `DEVIATION`: the docs or the environment differ from the prompt, and the docs win; see Deviations.
  - `UNVERIFIED`: not found in the docs.

## Environment observations (measured on this machine, not from docs)

| Observation | Command | Result |
|---|---|---|
| OS / shell | `uname -a` | `MINGW64_NT-10.0-26100` (Git Bash on native Windows 11), not WSL2 |
| WSL distros | `wsl.exe -l -q` | only `docker-desktop`; no Ubuntu |
| API provider | `echo $CLAUDE_CODE_USE_BEDROCK $AWS_REGION` | `1 <region>`, i.e. Amazon Bedrock |
| WebSearch tool | session tool list | absent (consistent with the Bedrock row below) |
| `jq` | `command -v jq` | **missing** |
| other runtimes | `--version` | git 2.55.0.windows.3, node v26.6.0, python 3.13.14, winget 1.29, GNU coreutils `realpath`/`sha256sum` |
| `bash` resolution from Windows PATH | `where bash` | `C:\Program Files\Git\usr\bin\bash.exe`, then **`C:\Windows\System32\bash.exe` (WSL launcher)** |
| schemastore URLs | `curl -L` | `json.schemastore.org/claude-code-{settings,marketplace,plugin-manifest}.json` → 301 → 200 |

## 1. Subagents

| mechanism | doc URL | access date | verbatim quote (≤25 words) | status |
|---|---|---|---|---|
| Frontmatter: required fields | https://code.claude.com/docs/en/sub-agents#supported-frontmatter-fields | 2026-10-13 | "Only `name` and `description` are required." | VERIFIED |
| Frontmatter: unknown fields | https://code.claude.com/docs/en/sub-agents#supported-frontmatter-fields | 2026-10-13 | "Claude Code ignores a field it doesn't recognize without reporting an error." | VERIFIED |
| Plugin agents: supported fields | https://code.claude.com/docs/en/plugins/components#frontmatter-fields-in-plugin-agents | 2026-10-13 | "**Supported fields**: `name`, `description`, `model`, `effort`, `maxTurns`, `tools`, `disallowedTools`, `skills`, `memory`, `background`, `omitClaudeMd`, `isolation`, `color`" | VERIFIED |
| Plugin agents: ignored fields | https://code.claude.com/docs/en/plugins/components#frontmatter-fields-in-plugin-agents | 2026-10-13 | "**Ignored fields**: `permissionMode`, `hooks`, `mcpServers`, and `initialPrompt`." | VERIFIED |
| Plugin agents: ignored fields (sub-agents page) | https://code.claude.com/docs/en/sub-agents#choose-the-subagent-scope | 2026-10-13 | "plugin subagents don't support the `hooks`, `mcpServers`, or `permissionMode` frontmatter fields" | VERIFIED |
| `isolation` values (plugin agents) | https://code.claude.com/docs/en/plugins/components#frontmatter-fields-in-plugin-agents | 2026-10-13 | "The only valid `isolation` value is `"worktree"`." | VERIFIED |
| `isolation: worktree` default base | https://code.claude.com/docs/en/sub-agents#supported-frontmatter-fields | 2026-10-13 | "branched by default from your [default branch](/docs/en/worktrees#choose-the-base-branch) rather than the parent session's `HEAD`" | VERIFIED |
| `tools` format | https://code.claude.com/docs/en/sub-agents#supported-frontmatter-fields | 2026-10-13 | "as a comma-separated string such as `Read, Grep, Bash` or a YAML list" | VERIFIED |
| `model` values | https://code.claude.com/docs/en/sub-agents#choose-a-model | 2026-10-13 | "`sonnet`, `opus`, `haiku`, `fable`, a full model ID such as `claude-opus-5-5`, or `inherit`" | VERIFIED |
| `model` resolution: per-invocation first | https://code.claude.com/docs/en/sub-agents#choose-a-model | 2026-10-13 | "1. The per-invocation `model` parameter" | VERIFIED |
| `model` resolution: changed in v2.1.251 | https://code.claude.com/docs/en/sub-agents#choose-a-model | 2026-10-13 | "Before v2.1.251, `CLAUDE_CODE_SUBAGENT_MODEL` came first in this order" | VERIFIED |
| Per-invocation `model` on Agent call | https://code.claude.com/docs/en/sub-agents#choose-a-model | 2026-10-13 | "When Claude invokes a subagent, it can also pass a `model` parameter for that specific invocation." | VERIFIED |
| `effort` values | https://code.claude.com/docs/en/sub-agents#supported-frontmatter-fields | 2026-10-13 | "Options: `low`, `medium`, `high`, `xhigh`, `max`; available levels depend on the model." | VERIFIED |
| Effort support per model (Haiku) | https://code.claude.com/docs/en/model-config#adjust-effort-level | 2026-10-13 | "Models not listed here do not support effort:" | PARTIAL |
| Effort default for 5.5 models | https://code.claude.com/docs/en/model-config#adjust-effort-level | 2026-10-13 | "except that Opus 5.5, Sonnet 5.5, and Haiku 5.5 default to `medium`" | VERIFIED |
| `maxTurns` → partial output, resumable | https://code.claude.com/docs/en/sub-agents#supported-frontmatter-fields | 2026-10-13 | "When the subagent reaches the limit, Claude Code returns its output marked as partial" | VERIFIED |
| `color` values | https://code.claude.com/docs/en/sub-agents#supported-frontmatter-fields | 2026-10-13 | "Accepts `red`, `blue`, `green`, `yellow`, `purple`, `orange`, `pink`, or `cyan`" | VERIFIED |
| Subagents run in background by default | https://code.claude.com/docs/en/tools-reference#agent-tool-behavior | 2026-10-13 | "Claude Code runs subagents in the background by default" | VERIFIED |
| Background subagent tool set | https://code.claude.com/docs/en/sub-agents#available-tools | 2026-10-13 | "a background subagent keeps every MCP tool but only these built-in tools: `Read`, `Grep`, `Glob`, `LSP`, `Bash`" | DEVIATION |
| `AskUserQuestion` removed from every subagent (list item at sub-agents.md:432) | https://code.claude.com/docs/en/sub-agents#available-tools | 2026-10-13 | "the first removes a short list of tools from every subagent" | VERIFIED |
| Background permission prompts surface in main session | https://code.claude.com/docs/en/sub-agents#run-subagents-in-foreground-or-background | 2026-10-13 | "Claude Code surfaces the prompt in your main session and names the subagent that is asking." | VERIFIED |
| Concurrent cap 20, no retry | https://code.claude.com/docs/en/sub-agents#concurrent-subagent-limit | 2026-10-13 | "spawning another with the Agent tool fails with `Concurrent subagent limit reached`, and the error tells Claude not to retry." | VERIFIED |
| `CLAUDE_CODE_MAX_CONCURRENT_SUBAGENTS` | https://code.claude.com/docs/en/env-vars | 2026-10-13 | "before the Agent tool refuses to spawn another (default: 20)" | VERIFIED |
| `CLAUDE_CODE_MAX_SUBAGENT_SPAWN_DEPTH` | https://code.claude.com/docs/en/env-vars | 2026-10-13 | "allowed below the main conversation (default: 3)." | VERIFIED |
| Nesting on by default | https://code.claude.com/docs/en/sub-agents#let-subagents-spawn-their-own-subagents | 2026-10-13 | "By default, a subagent can spawn subagents of its own, up to three layers below the main conversation." | VERIFIED |
| No total-spawn limit | https://code.claude.com/docs/en/sub-agents#concurrent-subagent-limit | 2026-10-13 | "There's no limit on the total number of subagents Claude can spawn over a session." | VERIFIED |
| Plugin agent naming `plugin:name` | https://code.claude.com/docs/en/plugins/components#agents | 2026-10-13 | "The name form is `<plugin>:<name>`, where `<name>` comes from the frontmatter `name` field" | VERIFIED |
| Same-name priority | https://code.claude.com/docs/en/sub-agents#choose-the-subagent-scope | 2026-10-13 | "When multiple subagents share the same name, Claude Code uses the one from the higher-priority location." | VERIFIED |
| Built-in Explore model | https://code.claude.com/docs/en/sub-agents#built-in-subagents | 2026-10-13 | "**Model**: the main conversation's model." | VERIFIED |
| Project `Explore` override | https://code.claude.com/docs/en/sub-agents#built-in-subagents | 2026-10-13 | "named `Explore` overrides the built-in and keeps its own `model` field" | VERIFIED |
| Worktree subagent: Bash confined to worktree | https://code.claude.com/docs/en/sub-agents#write-subagent-files | 2026-10-13 | "A subagent with `isolation: worktree` runs its Bash and PowerShell commands inside its worktree." | VERIFIED |
| Worktree: shell writes into main checkout not refused | https://code.claude.com/docs/en/worktrees#how-claude-code-enforces-isolation | 2026-10-13 | "such as `cp` or a shell redirect, isn't refused by them." | VERIFIED |
| `/tasks` lists background subagents | https://code.claude.com/docs/en/sub-agents#run-subagents-in-foreground-or-background | 2026-10-13 | "A background subagent that completes stays listed in [`/tasks`](/docs/en/commands)" | VERIFIED |
| Grep/Glob tools on Linux/macOS/WSL | https://code.claude.com/docs/en/tools-reference | 2026-10-13 | "Absent by default on macOS, Linux, and WSL." | DEVIATION |
| PowerShell tool on Windows | https://code.claude.com/docs/en/tools-reference#powershell-tool | 2026-10-13 | "**Windows with Git Bash installed**: the tool is on by default for claude.ai and Console accounts" | DEVIATION |
| Bash deny rule turns PowerShell off | https://code.claude.com/docs/en/tools-reference#powershell-tool | 2026-10-13 | "On Windows with Git Bash installed, denying Bash also turns the PowerShell tool off for the session." | VERIFIED |

## 2. Skills

| mechanism | doc URL | access date | verbatim quote (≤25 words) | status |
|---|---|---|---|---|
| Listing cap (`description` + `when_to_use`) | https://code.claude.com/docs/en/skills#frontmatter-reference | 2026-10-13 | "is truncated at 1,536 characters in the skill listing" | VERIFIED |
| SKILL.md length | https://code.claude.com/docs/en/skills#add-supporting-files | 2026-10-13 | "Keep `SKILL.md` under 500 lines." | VERIFIED |
| `allowed-tools` format | https://code.claude.com/docs/en/skills#frontmatter-reference | 2026-10-13 | "Accepts a space- or comma-separated string, or a YAML list." | VERIFIED |
| `allowed-tools` lifetime (invoking turn only) | https://code.claude.com/docs/en/skills#frontmatter-reference | 2026-10-13 | "The grant clears when you send your next message." | VERIFIED |
| `$ARGUMENTS` substitution | https://code.claude.com/docs/en/skills#available-string-substitutions | 2026-10-13 | "All arguments passed when invoking the skill." | VERIFIED |
| `context: fork` | https://code.claude.com/docs/en/skills#frontmatter-reference | 2026-10-13 | "Set to `fork` to run in a forked subagent context." | VERIFIED |
| `disable-model-invocation` | https://code.claude.com/docs/en/skills#control-who-invokes-a-skill | 2026-10-13 | "Claude can't invoke the skill on its own." | VERIFIED |
| Plugin skill namespacing | https://code.claude.com/docs/en/skills#where-skills-live | 2026-10-13 | "plugin skills are namespaced as `/plugin-name:skill-name`" | VERIFIED |
| Supporting files (playbooks/templates) | https://code.claude.com/docs/en/skills#add-supporting-files | 2026-10-13 | "Reference supporting files from `SKILL.md` so Claude knows what each file contains and when to load it:" | VERIFIED |
| `${CLAUDE_SKILL_DIR}` | https://code.claude.com/docs/en/skills#available-string-substitutions | 2026-10-13 | "The directory containing the skill's `SKILL.md` file." | VERIFIED |
| Skill tool accepts a namespaced name (`team:build`) | https://code.claude.com/docs/en/skills#manage-skill-permissions | 2026-10-13 | "Permission syntax: `Skill(name)` for exact match, `Skill(name *)` for prefix match with any arguments." | PARTIAL |

## 3. Plugin packaging and CLI

| mechanism | doc URL | access date | verbatim quote (≤25 words) | status |
|---|---|---|---|---|
| Manifest location | https://code.claude.com/docs/en/plugins/manifest-reference | 2026-10-13 | "Save the manifest at `.claude-plugin/plugin.json` under the plugin root." | VERIFIED |
| Manifest: only `name` required | https://code.claude.com/docs/en/plugins/manifest-reference#fields | 2026-10-13 | "`name` is the only required key." | VERIFIED |
| Manifest: `displayName` exists | https://code.claude.com/docs/en/plugins/manifest-reference#displayname | 2026-10-13 | "Name shown in UI in place of `name`" | VERIFIED |
| Manifest: unknown fields | https://code.claude.com/docs/en/plugins/manifest-reference#unrecognized-fields | 2026-10-13 | "the field is stripped and the plugin loads." | VERIFIED |
| Components at plugin root | https://code.claude.com/docs/en/plugins/manifest-reference | 2026-10-13 | "Put every other plugin file at the plugin root, not inside `.claude-plugin/`." | VERIFIED |
| Plugin `workflows/` namespacing | https://code.claude.com/docs/en/workflows#distribute-a-workflow-in-a-plugin | 2026-10-13 | "Plugin workflows are namespaced by the plugin name." | VERIFIED |
| Marketplace file location | https://code.claude.com/docs/en/plugins/marketplace-reference#marketplace-file | 2026-10-13 | "Save the marketplace file at `.claude-plugin/marketplace.json` in your marketplace's directory." | VERIFIED |
| Marketplace required fields | https://code.claude.com/docs/en/plugins/marketplace-reference#top-level-fields | 2026-10-13 | "`name`, `owner`, and `plugins` are required." | VERIFIED |
| Plugin entry required fields | https://code.claude.com/docs/en/plugins/marketplace-reference#plugin-entries | 2026-10-13 | "`name` and `source` are required." | VERIFIED |
| Relative `source` | https://code.claude.com/docs/en/plugins/marketplace-reference#relative-path-plugin-source | 2026-10-13 | "{ "name": "formatter", "source": "./plugins/formatter" }" | VERIFIED |
| Marketplace `$schema` | https://code.claude.com/docs/en/plugins/marketplace-reference#top-level-fields | 2026-10-13 | "JSON Schema URL for editor autocomplete. Ignored at load time" | PARTIAL |
| Reserved marketplace names (`team-kit` is not one) | https://code.claude.com/docs/en/plugins/marketplace-reference#reserved-names | 2026-10-13 | "You can't give your marketplace any of the following names:" | VERIFIED |
| `claude plugin validate` | https://code.claude.com/docs/en/plugins/cli-reference#plugin-validate | 2026-10-13 | "claude plugin validate <path> [options]" | VERIFIED |
| `validate` accepts a directory | https://code.claude.com/docs/en/plugins/cli-reference#plugin-validate | 2026-10-13 | "The `<path>` is a manifest file or a directory." | VERIFIED |
| `claude plugin marketplace add` | https://code.claude.com/docs/en/plugins/cli-reference#plugin-marketplace-add | 2026-10-13 | "claude plugin marketplace add <source> [options]" | VERIFIED |
| `claude plugin install` | https://code.claude.com/docs/en/plugins/cli-reference#plugin-install | 2026-10-13 | "claude plugin install <plugin> [options]" | VERIFIED |
| `--plugin-dir` (session-only, repeatable) | https://code.claude.com/docs/en/plugins/cli-reference | 2026-10-13 | "Two `claude` flags load a plugin for one session only, without installing it. Both are repeatable." | VERIFIED |
| Install copies plugin to cache | https://code.claude.com/docs/en/plugins/loading#in-place-and-copied-plugins | 2026-10-13 | "Claude Code copies the plugin into `cache/<marketplace>/<plugin>/<version>/` at install and loads that copy." | VERIFIED |
| Files outside plugin dir not copied | https://code.claude.com/docs/en/plugins/loading#in-place-and-copied-plugins | 2026-10-13 | "Files outside the plugin directory aren't copied" | VERIFIED |
| Plugin default `settings.json` keys | https://code.claude.com/docs/en/plugins/components#default-settings | 2026-10-13 | "Two keys take effect, `agent` and `subagentStatusLine`, and every other key is dropped." | VERIFIED |
| `${CLAUDE_PLUGIN_DATA}` | https://code.claude.com/docs/en/plugins/components#path-variables-and-persistent-data | 2026-10-13 | "a directory that survives updates, for `node_modules`, virtual environments, and caches" | VERIFIED |
| Pinned `version` controls updates | https://code.claude.com/docs/en/plugins/loading#how-claude-code-computes-the-version | 2026-10-13 | "keeps every user on the cached copy" | VERIFIED |

## 4. Hooks

| mechanism | doc URL | access date | verbatim quote (≤25 words) | status |
|---|---|---|---|---|
| `PreToolUse` / `PostToolUse` | https://code.claude.com/docs/en/hooks#hook-lifecycle | 2026-10-13 | "on every tool call inside the agentic loop: `PreToolUse` and `PostToolUse`" | VERIFIED |
| `UserPromptSubmit` / `Stop` | https://code.claude.com/docs/en/hooks#hook-lifecycle | 2026-10-13 | "per turn: `UserPromptSubmit`, `Stop`, and `StopFailure`" | VERIFIED |
| `SubagentStart` event | https://code.claude.com/docs/en/hooks#hook-lifecycle | 2026-10-13 | "`SubagentStart` \| When a subagent is spawned" | VERIFIED |
| `TaskCreated` event | https://code.claude.com/docs/en/hooks#hook-lifecycle | 2026-10-13 | "`TaskCreated` \| When a task is being created via `TaskCreate`" | VERIFIED |
| `TeammateIdle` event | https://code.claude.com/docs/en/hooks#hook-lifecycle | 2026-10-13 | "`TeammateIdle` \| When an [agent team](/docs/en/agent-teams) teammate is about to go idle" | VERIFIED |
| Input `agent_id` | https://code.claude.com/docs/en/hooks#common-input-fields | 2026-10-13 | "Unique identifier for the subagent or in-process teammate the hook fires in." | VERIFIED |
| Input `agent_type` presence | https://code.claude.com/docs/en/hooks#common-input-fields | 2026-10-13 | "Present when the session uses `--agent` or the hook fires inside a subagent." | DEVIATION |
| `agent_type` for plugin agents | https://code.claude.com/docs/en/hooks#subagentstart | 2026-10-13 | "the agent type is the plugin-scoped identifier such as `my-plugin:reviewer`, not the bare frontmatter name" | VERIFIED |
| `PreToolUse` input fields | https://code.claude.com/docs/en/hooks#pretooluse-input | 2026-10-13 | "PreToolUse hooks receive `tool_name`, `tool_input`, and `tool_use_id`." | VERIFIED |
| Windows `file_path` separators | https://code.claude.com/docs/en/hooks#pretooluse-input | 2026-10-13 | "On Windows, the path arrives with backslash separators, even when your hook runs under Git Bash" | DEVIATION |
| NotebookEdit input field | https://code.claude.com/docs/en/permissions#match-by-input-parameter | 2026-10-13 | "`notebook_path` for NotebookEdit" | VERIFIED |
| WebSearch input `query` | https://code.claude.com/docs/en/hooks#websearch | 2026-10-13 | "`query` \| string \| `"react hooks best practices"` \| Search query" | VERIFIED |
| WebFetch input `url` | https://code.claude.com/docs/en/hooks#webfetch | 2026-10-13 | "`url` \| string \| `"https://example.com/api"` \| URL to fetch content from" | VERIFIED |
| `permissionDecision` values | https://code.claude.com/docs/en/hooks#pretooluse-decision-control | 2026-10-13 | "`permissionDecision` (allow/deny/ask/defer), `permissionDecisionReason`" | VERIFIED |
| Conflicting decisions: deny wins | https://code.claude.com/docs/en/hooks#pretooluse-decision-control | 2026-10-13 | "When multiple PreToolUse hooks return different decisions, precedence is `deny` > `defer` > `ask` > `allow`." | VERIFIED |
| Exit 2 blocks `PreToolUse` | https://code.claude.com/docs/en/hooks#exit-code-2-behavior-per-event | 2026-10-13 | "`PreToolUse` \| Yes \| Blocks the tool call" | VERIFIED |
| Exit 1 is non-blocking | https://code.claude.com/docs/en/hooks#other-exit-codes | 2026-10-13 | "Without valid JSON on stdout, Claude Code treats exit code 1 as a non-blocking error" | VERIFIED |
| `Stop` input | https://code.claude.com/docs/en/hooks#stop-input | 2026-10-13 | "Stop hooks receive `stop_hook_active`, `last_assistant_message`, `background_tasks`, and `session_crons`." | VERIFIED |
| `SubagentStop` input | https://code.claude.com/docs/en/hooks#subagentstop-input | 2026-10-13 | "SubagentStop hooks receive `stop_hook_active`, `agent_id`, `agent_type`, `agent_transcript_path`, and `last_assistant_message`." | VERIFIED |
| `{"decision":"block"}` on Stop/SubagentStop | https://code.claude.com/docs/en/hooks#stop-decision-control | 2026-10-13 | "prevents Claude from stopping. Omit to allow Claude to stop" | VERIFIED |
| Stop block cap (8) | https://code.claude.com/docs/en/hooks#stop-input | 2026-10-13 | "after stop hooks have continued the turn eight times in a row, Claude Code overrides the next block and ends the turn" | VERIFIED |
| `SubagentStart` can't block, can inject context | https://code.claude.com/docs/en/hooks#subagentstart-input | 2026-10-13 | "SubagentStart hooks can't block subagent creation, but they can inject context into the subagent." | VERIFIED |
| `SubagentStart` matcher on agent type | https://code.claude.com/docs/en/hooks#subagentstart | 2026-10-13 | "Supports matchers to filter by agent type name." | VERIFIED |
| `UserPromptSubmit` plain stdout → context | https://code.claude.com/docs/en/hooks#userpromptsubmit-decision-control | 2026-10-13 | "**Plain text stdout**: Claude Code adds stdout it [treats as plain text](#exit-code-0) to Claude's context" | VERIFIED |
| `UserPromptSubmit` default timeout | https://code.claude.com/docs/en/hooks#userpromptsubmit | 2026-10-13 | "`UserPromptSubmit` hooks have a default timeout of 30 seconds for `command`, `http`, and `mcp_tool` types" | VERIFIED |
| Exec form vs shell form | https://code.claude.com/docs/en/hooks#exec-form-and-shell-form | 2026-10-13 | "A command hook runs as exec form when `args` is set, and shell form when `args` is omitted." | VERIFIED |
| Exec form on Windows | https://code.claude.com/docs/en/hooks#exec-form-and-shell-form | 2026-10-13 | "On Windows, exec form requires `command` to resolve to a real executable such as a `.exe`." | DEVIATION |
| Shell form interpreter | https://code.claude.com/docs/en/hooks#exec-form-and-shell-form | 2026-10-13 | "`sh -c` on macOS and Linux, Git Bash on Windows, or PowerShell when Git Bash isn't installed." | VERIFIED |
| Placeholders substituted in `args` | https://code.claude.com/docs/en/hooks#exec-form-and-shell-form | 2026-10-13 | "path placeholders like `${CLAUDE_PLUGIN_ROOT}` are substituted into `command` and into each `args` element as plain strings" | VERIFIED |
| Placeholders exported as env vars | https://code.claude.com/docs/en/hooks#exec-form-and-shell-form | 2026-10-13 | "both export them as the environment variables `CLAUDE_PROJECT_DIR`, `CLAUDE_PLUGIN_ROOT`, and `CLAUDE_PLUGIN_DATA` on the spawned process" | VERIFIED |
| `${CLAUDE_PROJECT_DIR}` in worktrees | https://code.claude.com/docs/en/hooks#reference-scripts-by-path | 2026-10-13 | "`${CLAUDE_PROJECT_DIR}` stays put**: it still points at the project root where the session started" | VERIFIED |
| `timeout` unit | https://code.claude.com/docs/en/hooks#common-fields | 2026-10-13 | "Seconds before canceling." | VERIFIED |
| Matcher alternation | https://code.claude.com/docs/en/hooks#matcher-patterns | 2026-10-13 | "`Edit\|Write` and `Edit, Write` each match either tool exactly" | VERIFIED |
| Matcher on no-matcher events | https://code.claude.com/docs/en/hooks#matcher-patterns | 2026-10-13 | "If you add a `matcher` field to an event without matcher support, it is silently ignored." | VERIFIED |
| Plugin `hooks/hooks.json` with `"hooks"` wrapper | https://code.claude.com/docs/en/plugins/components#hooks | 2026-10-13 | "Save the plugin's hooks in `hooks/hooks.json` at the plugin root, under a top-level `"hooks"` key" | VERIFIED |
| `hooks.json` `description` | https://code.claude.com/docs/en/hooks#reference-scripts-by-path | 2026-10-13 | "Define plugin hooks in `hooks/hooks.json` with an optional top-level `description` field." | VERIFIED |
| Hooks fire for subagent tool calls | https://code.claude.com/docs/en/hooks#hook-locations | 2026-10-13 | "When a subagent calls a tool, tool events such as `PreToolUse` and `PostToolUse` fire the same configured hooks as in the main conversation" | VERIFIED |
| Plugin hooks apply inside subagents | https://code.claude.com/docs/en/sub-agents#define-hooks-for-subagents | 2026-10-13 | "Hooks from [settings files, managed policy settings, and plugins](/docs/en/hooks#hook-locations) all apply inside subagents" | VERIFIED |
| Matching hooks run in parallel | https://code.claude.com/docs/en/hooks#hook-handler-fields | 2026-10-13 | "All matching hooks run in parallel." | VERIFIED |
| Bash-only matcher misses PowerShell | https://code.claude.com/docs/en/hooks#powershell | 2026-10-13 | "A hook that matches only `Bash` never fires there." | DEVIATION |
| `TaskCompleted` input fields | https://code.claude.com/docs/en/hooks#taskcompleted-input | 2026-10-13 | "TaskCompleted hooks receive `task_id`, `task_subject`, and optionally `task_description`, `teammate_name`, and `team_name`." | VERIFIED |
| `TaskCompleted` exit 2 | https://code.claude.com/docs/en/hooks#taskcompleted-decision-control | 2026-10-13 | "the task is not marked as completed and the stderr message is fed back to the model as feedback." | VERIFIED |

## 5. Settings, permissions, worktrees, web tools

| mechanism | doc URL | access date | verbatim quote (≤25 words) | status |
|---|---|---|---|---|
| `worktree.baseRef: "fresh"` | https://code.claude.com/docs/en/worktrees#choose-the-base-branch | 2026-10-13 | "`"fresh"` (default): branch from the repository's default branch on the remote, usually `main`" | VERIFIED |
| `worktree.baseRef: "head"` | https://code.claude.com/docs/en/worktrees#choose-the-base-branch | 2026-10-13 | "`"head"`: branch from your current local `HEAD`, so the worktree carries your unpushed commits" | VERIFIED |
| `baseRef` is not a branch name | https://code.claude.com/docs/en/worktrees#choose-the-base-branch | 2026-10-13 | "You can't set `worktree.baseRef` to a branch name." | VERIFIED |
| `baseRef` applies to subagent worktrees | https://code.claude.com/docs/en/worktrees#isolate-subagents-with-worktrees | 2026-10-13 | "Subagent worktrees use the same [base branch](#choose-the-base-branch) as `--worktree`" | VERIFIED |
| Subagent worktree auto-removal | https://code.claude.com/docs/en/worktrees#isolate-subagents-with-worktrees | 2026-10-13 | "Each subagent gets a temporary worktree that Claude Code removes automatically when the subagent finishes without changes" | VERIFIED |
| Worktree location / branch name | https://code.claude.com/docs/en/worktrees#start-claude-in-a-worktree | 2026-10-13 | "the worktree is created under `.claude/worktrees/<name>/` at your repository root, on a new branch named `worktree-<name>`" | PARTIAL |
| Gitignore worktrees | https://code.claude.com/docs/en/worktrees#start-claude-in-a-worktree | 2026-10-13 | "Add `.claude/worktrees/` to your `.gitignore` so worktree contents don't appear as untracked files in your main checkout." | VERIFIED |
| `worktree.symlinkDirectories` | https://code.claude.com/docs/en/settings-reference#worktree-symlinkdirectories | 2026-10-13 | "Symlink directories from the main repository into each worktree so you don't duplicate large directories on disk." | VERIFIED |
| `.worktreeinclude` | https://code.claude.com/docs/en/worktrees#copy-gitignored-files-into-worktrees | 2026-10-13 | "This applies to every worktree Claude Code creates with git:" | VERIFIED |
| WebSearch rule syntax | https://code.claude.com/docs/en/tools-reference#websearch-tool-behavior | 2026-10-13 | "WebSearch permission rules take no specifier. A bare `WebSearch` entry in `allow` or `deny` is the only form." | VERIFIED |
| WebFetch domain rule | https://code.claude.com/docs/en/permissions#webfetch | 2026-10-13 | "`WebFetch(domain:example.com)` matches requests to `example.com` only." | VERIFIED |
| WebFetch wildcard rule | https://code.claude.com/docs/en/permissions#webfetch | 2026-10-13 | "`WebFetch(domain:*.example.com)` matches any subdomain at any depth" | PARTIAL |
| WebFetch wildcard version | https://code.claude.com/docs/en/permissions#webfetch | 2026-10-13 | "Wildcards in `WebFetch` rules require Claude Code v2.1.172 or later to match fetches." | VERIFIED |
| WebSearch: 8 backend searches per call | https://code.claude.com/docs/en/tools-reference#websearch-tool-behavior | 2026-10-13 | "The tool may issue up to eight backend searches per call" | VERIFIED |
| WebSearch: 200 per interactive session | https://code.claude.com/docs/en/tools-reference#session-search-limit | 2026-10-13 | "An interactive terminal session has a limit of 200 WebSearch calls." | VERIFIED |
| `CLAUDE_CODE_MAX_WEB_SEARCHES_PER_SESSION` | https://code.claude.com/docs/en/env-vars | 2026-10-13 | "Cap on [WebSearch](/docs/en/tools-reference#session-search-limit) calls (default: 200)." | VERIFIED |
| WebSearch on Amazon Bedrock | https://code.claude.com/docs/en/tools-reference#websearch-tool-behavior | 2026-10-13 | "Amazon Bedrock doesn't expose the server-side web search tool." | DEVIATION |
| `askUserQuestionTimeout` values | https://code.claude.com/docs/en/settings-reference#askuserquestiontimeout | 2026-10-13 | "**Type**: string, one of `"60s"`, `"5m"`, `"10m"`, or `"never"`" | VERIFIED |
| `askUserQuestionTimeout` scope | https://code.claude.com/docs/en/settings-reference#askuserquestiontimeout | 2026-10-13 | "**Scope**: [`User or managed`](#scopes)" | PARTIAL |
| AskUserQuestion default (stays open) | https://code.claude.com/docs/en/tools-reference#question-auto-continue-timeout | 2026-10-13 | "Questions stay open until you answer them." | VERIFIED |
| Bash rule `Bash(cmd *)` | https://code.claude.com/docs/en/permissions#wildcard-patterns | 2026-10-13 | "**A `*` at the end, with a space before it, also matches the bare command.**" | VERIFIED |
| `Bash(cmd:*)` equivalent | https://code.claude.com/docs/en/permissions#wildcard-patterns | 2026-10-13 | "The `:*` suffix is an equivalent way to write a trailing wildcard" | VERIFIED |
| `Read(./.env)` deny rules | https://code.claude.com/docs/en/permissions#read-and-edit | 2026-10-13 | "add a `Read` deny rule for its path, such as `Read(./.env)` or `Read(./secrets/**)`" | VERIFIED |
| Path rules: only `Read`/`Edit` consulted | https://code.claude.com/docs/en/permissions#read-and-edit | 2026-10-13 | "Claude Code checks file permissions against `Edit(path)` and `Read(path)` rules only." | VERIFIED |
| Rule evaluation order | https://code.claude.com/docs/en/permissions#manage-permissions | 2026-10-13 | "Rules are evaluated in order: deny, then ask, then allow." | VERIFIED |
| `Agent(param:value)` rules | https://code.claude.com/docs/en/permissions#match-by-input-parameter | 2026-10-13 | "`Agent(model:opus)` \| Agent calls that request the Opus model tier" | VERIFIED |
| Settings `$schema` | https://code.claude.com/docs/en/settings | 2026-10-13 | ""$schema": "https://json.schemastore.org/claude-code-settings.json"," | VERIFIED |
| Settings `env` block | https://code.claude.com/docs/en/settings-reference#env | 2026-10-13 | "Set environment variables for every session and for the subprocesses Claude Code starts from it." | VERIFIED |
| `CLAUDE_CODE_SUBAGENT_MODEL` | https://code.claude.com/docs/en/env-vars | 2026-10-13 | "The default model for [subagents](/docs/en/sub-agents#choose-a-model)" | VERIFIED |
| `CLAUDE_CODE_WORKFLOW_MAX_CONCURRENT_AGENTS` | https://code.claude.com/docs/en/env-vars | 2026-10-13 | "By default, a run executes up to 16 agents at once" | VERIFIED |
| `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS` | https://code.claude.com/docs/en/env-vars | 2026-10-13 | "Agent teams are experimental and disabled by default" | VERIFIED |
| `CLAUDE_CODE_GIT_BASH_PATH` | https://code.claude.com/docs/en/env-vars | 2026-10-13 | "Windows only: path to the Git Bash executable (`bash.exe`)." | VERIFIED |
| Tool name `Agent` | https://code.claude.com/docs/en/tools-reference | 2026-10-13 | "`Agent` \| Spawns a [subagent](/docs/en/sub-agents) with its own context window" | VERIFIED |

## 6. Agent teams

| mechanism | doc URL | access date | verbatim quote (≤25 words) | status |
|---|---|---|---|---|
| Status | https://code.claude.com/docs/en/agent-teams | 2026-10-13 | "Agent teams are experimental and disabled by default." | VERIFIED |
| Enable env var | https://code.claude.com/docs/en/agent-teams#enable-agent-teams | 2026-10-13 | "Enable them by setting `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1` in your" | VERIFIED |
| Interactive only | https://code.claude.com/docs/en/agent-teams | 2026-10-13 | "Spawning teammates also requires an interactive session." | VERIFIED |
| Plan approval is automatic | https://code.claude.com/docs/en/agent-teams#require-plan-approval-for-teammates | 2026-10-13 | "Claude Code approves the plan in the lead's session as soon as the request arrives, without the lead reviewing it." | VERIFIED |
| One team per session | https://code.claude.com/docs/en/agent-teams#limitations | 2026-10-13 | "**One team per session**: a session has exactly one team, scoped to that session." | VERIFIED |
| No nested teams | https://code.claude.com/docs/en/agent-teams#limitations | 2026-10-13 | "**No nested teams**: teammates cannot spawn their own teammates." | VERIFIED |
| No resume of in-process teammates | https://code.claude.com/docs/en/agent-teams#limitations | 2026-10-13 | "`/resume` and `/rewind` do not restore in-process teammates." | VERIFIED |
| Definition `skills` not applied | https://code.claude.com/docs/en/agent-teams#use-subagent-definitions-for-teammates | 2026-10-13 | "Claude Code doesn't apply the definition's `skills` to a teammate in either display mode." | VERIFIED |
| Definition `disallowedTools` applied | https://code.claude.com/docs/en/agent-teams#use-subagent-definitions-for-teammates | 2026-10-13 | "for an in-process teammate, Claude Code removes the tools in the definition's `disallowedTools` from the teammate's set." | PARTIAL |
| `isolation` on the call → not a teammate | https://code.claude.com/docs/en/agent-teams#how-claude-starts-agent-teams | 2026-10-13 | "or passes `isolation` on the call itself" | VERIFIED |
| Named subagent → teammate while enabled | https://code.claude.com/docs/en/agent-teams | 2026-10-13 | "While agent teams are enabled, a subagent that Claude names in the lead's session launches as a teammate." | VERIFIED |
| Split panes unsupported terminals | https://code.claude.com/docs/en/agent-teams#limitations | 2026-10-13 | "Split-pane mode isn't supported in VS Code's integrated terminal, Windows Terminal, or Ghostty." | VERIFIED |
| Team size | https://code.claude.com/docs/en/agent-teams#choose-an-appropriate-team-size | 2026-10-13 | "Start with 3-5 teammates for most workflows." | VERIFIED |
| Tasks per teammate | https://code.claude.com/docs/en/agent-teams#choose-an-appropriate-team-size | 2026-10-13 | "Having 5-6 tasks per teammate keeps everyone productive" | VERIFIED |

## 7. Dynamic workflows

| mechanism | doc URL | access date | verbatim quote (≤25 words) | status |
|---|---|---|---|---|
| Availability (incl. Bedrock) | https://code.claude.com/docs/en/workflows | 2026-10-13 | "Dynamic workflows are available on all paid plans, with Anthropic API access, and on Amazon Bedrock" | VERIFIED |
| Pro opt-in | https://code.claude.com/docs/en/workflows | 2026-10-13 | "On Pro, turn them on from the Dynamic workflows row in `/config`." | VERIFIED |
| `agent` / `pipeline` / `parallel` | https://code.claude.com/docs/en/workflows#what-the-saved-script-looks-like | 2026-10-13 | "`agent()` spawns one subagent, `pipeline()` runs one per item in a list, and `parallel()` runs a set of agent tasks" | VERIFIED |
| `phase()` | https://code.claude.com/docs/en/workflows#edit-a-saved-script | 2026-10-13 | "call `phase()` to group the agents that follow under a title in the progress view" | VERIFIED |
| `args` global | https://code.claude.com/docs/en/workflows#pass-input-to-a-saved-workflow | 2026-10-13 | "The script reads it as a global named `args`." | VERIFIED |
| `meta` shape | https://code.claude.com/docs/en/workflows#edit-a-saved-script | 2026-10-13 | "keep `export const meta` as the first statement, and keep it a plain object literal with a `name` and a `description`." | VERIFIED |
| `agent()` with `schema` | https://code.claude.com/docs/en/workflows#what-the-saved-script-looks-like | 2026-10-13 | "If you pass a `schema` on an `agent()` call, that subagent returns JSON matching the shape instead of prose." | VERIFIED |
| `agent()` returns `null` on stop/error | https://code.claude.com/docs/en/workflows#what-the-saved-script-looks-like | 2026-10-13 | "An `agent()` call resolves to `null` if you stop it mid-run or it hits an unrecoverable API error." | VERIFIED |
| `agent()` option for custom subagent type / model | https://code.claude.com/docs/en/workflows | 2026-10-13 | — | UNVERIFIED |
| No mid-run input; one workflow per stage | https://code.claude.com/docs/en/workflows#behavior-and-limits | 2026-10-13 | "For sign-off between stages, run each stage as its own workflow" | VERIFIED |
| Concurrency default | https://code.claude.com/docs/en/workflows#behavior-and-limits | 2026-10-13 | "Up to 16 concurrent agents by default, fewer when Claude Code has fewer CPUs available" | VERIFIED |
| Agents per run | https://code.claude.com/docs/en/workflows#behavior-and-limits | 2026-10-13 | "1,000 agents total per run" | VERIFIED |
| Banned nondeterminism | https://code.claude.com/docs/en/workflows#edit-a-saved-script | 2026-10-13 | "Claude Code makes `Date.now()`, `Math.random()`, and a no-argument `new Date()` throw inside the script" | VERIFIED |
| Plugin hooks apply to workflow agents | https://code.claude.com/docs/en/workflows | 2026-10-13 | — | UNVERIFIED |

## 8. Memory

| mechanism | doc URL | access date | verbatim quote (≤25 words) | status |
|---|---|---|---|---|
| CLAUDE.md `@imports` | https://code.claude.com/docs/en/memory#import-additional-files | 2026-10-13 | "CLAUDE.md files can import additional files using `@path/to/import` syntax." | VERIFIED |
| Auto memory load limit | https://code.claude.com/docs/en/memory#auto-memory | 2026-10-13 | "The first 200 lines of `MEMORY.md`, or the first 25KB, whichever comes first, are loaded at the start of every conversation." | VERIFIED |
| Subagent `memory` is part of auto memory | https://code.claude.com/docs/en/sub-agents#enable-persistent-memory | 2026-10-13 | "Subagent memory is part of [auto memory](/docs/en/memory#auto-memory): if you turn auto memory off" | VERIFIED |

## 9. Version gates (changelog)

| mechanism | doc URL | access date | verbatim quote (≤25 words) | status |
|---|---|---|---|---|
| v2.1.246: `maxTurns` partial output | https://code.claude.com/docs/en/changelog | 2026-10-13 | "a subagent that stops at its `maxTurns` limit now returns its output marked as partial" | VERIFIED |
| v2.1.172: WebFetch wildcard rules fixed | https://code.claude.com/docs/en/changelog | 2026-10-13 | "Fixed `WebFetch(domain:*.example.com)` wildcard domain rules never matching subdomains" | PARTIAL |
| v2.1.143: Stop-hook block cap | https://code.claude.com/docs/en/changelog | 2026-10-13 | "the turn now ends with a warning after 8 consecutive blocks (override via `CLAUDE_CODE_STOP_HOOK_BLOCK_CAP`)" | VERIFIED |
| v2.1.47: `last_assistant_message` | https://code.claude.com/docs/en/changelog | 2026-10-13 | "Added `last_assistant_message` field to Stop and SubagentStop hook inputs" | VERIFIED |
| v2.1.139: exec-form `args` | https://code.claude.com/docs/en/changelog | 2026-10-13 | "Added hook `args: string[]` field (exec form) that spawns the command directly without a shell" | VERIFIED |
| v2.1.133: `worktree.baseRef` | https://code.claude.com/docs/en/changelog | 2026-10-13 | "Added `worktree.baseRef` setting (`fresh` \| `head`)" | VERIFIED |
| v2.1.198: background by default | https://code.claude.com/docs/en/changelog | 2026-10-13 | "Subagents now run in the background by default, so Claude keeps working while they run" | VERIFIED |
| v2.1.217: concurrent subagent cap | https://code.claude.com/docs/en/changelog | 2026-10-13 | "Added a cap on concurrently-running subagents (default 20, override with `CLAUDE_CODE_MAX_CONCURRENT_SUBAGENTS`)" | VERIFIED |

## Live results (Phase 6, 2026-10-13, Claude Code 2.1.296, Windows + Git Bash, Amazon Bedrock)

Scratch repo `team-kit-scratch/pocket-notes` with a simulated active run (`.po/ACTIVE`, `state.json`), kit loaded with `claude --plugin-dir`, project settings passed with `--settings`. Each test used one headless `claude -p` call.

| Test | What ran | Result |
|---|---|---|
| S1 | spawn `subagent_type: 'team:researcher'` | **Pass.** The scoped name works (resolves UNVERIFIED 1). `agents.jsonl` got `start`/`stop` entries with `role: researcher`, so shell-form hooks with `${CLAUDE_PLUGIN_ROOT}` run on Windows, the `jq` fallback lookup works with `jq` absent from PATH, and `agent_type` arrives as `team:researcher`. |
| S2 | worktree-isolated `team:backend-developer` | **Pass.** It quoted the injected `TEAM RUN … OBJECTIVE …` line (objective anchor works) and committed in its worktree on branch `worktree-agent-<id>` (resolves UNVERIFIED 5). The SubagentStart/Stop hooks fired for it. |
| S2b (≈ T6) | the same agent told to attempt `Write contracts/openapi.yaml` | **Pass.** Denied with "Contracts are frozen. File a contract change request (ccr/v1)…". The hook saw the worktree path, and the main checkout's contract was unchanged. |
| S3 (≈ T2) | `team:ux-designer` with `budgets.fetch = 1`, two WebFetch calls | **Pass.** Fetch 1 ran; fetch 2 was denied with "Research budget exhausted for WebFetch (1/1)". The budget file shows `WebFetch: 1`; `.po/research/index.jsonl` logged the allowed fetch. |
| S4 | `team:drift-checker` runs an inspection command and a redirect | **Pass.** `git branch --list` ran; `echo tampered > tampered.txt` was denied ("drift-checker is read-only") and no file was created. |
| manual T10 | removed the scratch worktrees and branches | **Pass.** `git worktree list` shows only the main checkout afterwards. This was done by hand, not through `/team:abort`. |

**Findings from the live runs (not in the build prompt):**

20. **Workspace trust gates project settings.** In a project that has not been trusted, Claude Code printed "Ignoring 36 permissions.allow entries from .claude/settings.json: this workspace has not been trusted." Interactive users get the trust dialog. For headless runs, pass `--settings <file>` or accept the trust dialog once. The README says so.
21. **Path casing breaks worktree isolation on Windows.** Launching from `C:/Users/.../work/...` when the directory is really named `Work` made the Agent tool refuse `isolation: worktree`: the worktree "resolves to a different path" that differs only in capitalization. Launching from the canonical casing fixed it. The README tells Windows users to start from the exact on-disk casing.
22. **A model may refuse to attempt a forbidden write,** so the hook never fires. The agent followed its own rules in the first S2 run. That is the intended outcome and the hook is the backstop; S2b needed an explicit instruction to attempt the write.

**What was NOT run:** the full `/team:build` pipeline (Stages A–E), so T1, T3, T4, T5, T7, T8 and T9 are untested. It needs the interactive STOP A and STOP B questions and dozens of agent runs, including Opus ones, on your Bedrock account. T2, T6 and T10 were exercised in the narrower forms above.

## Deviations

The docs or the measured environment win over the build prompt. Each entry gives the planned change.

1. **Platform is native Windows + Git Bash, not WSL2/Ubuntu.** WSL has only `docker-desktop`. The repo lives on the Windows filesystem.
   - Plan: target Git Bash on Windows first.
   - Keep the scripts POSIX-portable so they also run under Linux, macOS and WSL.
   - The repo uses `core.autocrlf=false` plus `.gitattributes` (LF).
2. **The provider is Amazon Bedrock, so the WebSearch tool does not exist** ("Amazon Bedrock doesn't expose the server-side web search tool.").
   - Stage A research falls back to WebFetch against primary-source URLs.
   - The playbook gives role agents a seed list of canonical URLs (owasp.org, w3.org, rfc-editor.org, nodejs.org, …).
   - Agents keep `WebSearch` in `tools` for portability. A missing tool is dropped; launch fails only when *no* listed tool resolves.
   - The research-budget hook still counts both tools.
   - Test T2 ("7th WebSearch denied") can only be exercised through hook fixtures here. Live T2 uses the WebFetch budget instead.
3. **`jq` is not installed.** The spec'd hooks fail open without `jq`, so on this machine none of the guards would enforce anything. **This needs a decision at STOP 0.**
4. **Exec form `"command": "bash"` is unsafe on Windows.** Docs: exec form "requires `command` to resolve to a real executable". On this PATH, `C:\Windows\System32\bash.exe` (the WSL launcher) is also present and wins on some machines.
   - Plan: use shell form, `"command": "bash \"${CLAUDE_PLUGIN_ROOT}/hooks/scripts/<x>.sh\" <arg>"`.
   - Shell form runs under Git Bash on Windows and `sh -c` on macOS/Linux.
   - The docs require the placeholder path to be quoted in shell form.
5. **Windows `tool_input.file_path` uses backslashes,** so `*/contracts/*` never matches.
   - Plan: `path-guard.sh` normalizes `\` → `/`, and converts both the path and `CLAUDE_PROJECT_DIR` with `cygpath -u` when available.
6. **PowerShell tool.** A `Bash`-only matcher never sees PowerShell commands.
   - Plan: matcher `Bash|PowerShell` for `guard-bash.sh` (same `tool_input.command` field).
   - `extras/settings.recommended.json` sets `CLAUDE_CODE_USE_POWERSHELL_TOOL=0`. On Bedrock it is already opt-in, and any Bash deny rule also turns it off on Windows with Git Bash.
7. **Grep/Glob are absent by default on macOS, Linux and WSL.** There, searches go through Bash, and `drift-checker` (tools `Read, Grep, Glob`) would effectively be read-by-path only.
   - Plan: give `drift-checker` `Bash` as well, kept read-only by `guard-bash.sh`, which will deny file-writing commands for read-only roles. To be detailed in Phase 4.
8. **`agent_type` is also present in `--agent` main sessions,** so "no `agent_type` means main session" is not reliable.
   - Plan: scripts detect "inside a subagent" by **`agent_id`** presence. `agent_type` is used only to pick the role.
9. **Plugins cannot ship `worktree.baseRef`.** A plugin `settings.json` honours only `agent` and `subagentStatusLine`.
   - `baseRef` stays in `extras/settings.recommended.json`, with the orchestrator's environment check, as the prompt already planned.
10. **`askUserQuestionTimeout` scope is User or managed only.** Project settings can't set it, and the recommended settings won't try.
    - The README tells users to check `~/.claude/settings.json`.
    - The "anything but explicit Approve = not approved" rule stays.
11. **The background subagent tool set is a superset** of the prompt's list (it adds LSP, PowerShell, NotebookEdit, TodoWrite, ToolSearch, Monitor, TaskStop, …). This is harmless and needs no change.
12. **Built-in Explore uses the main session model,** not haiku. `extras/project-agents/Explore.md` with `model: haiku` is the documented override, so no change is needed.
13. **WebFetch `*.example.com` does not match the apex domain,** and v2.1.172 is a *fix* version (wildcards existed but didn't match before it). The recommended settings already list both apex and wildcard, so no change is needed.
14. **New: gitignore worktrees.** The docs tip says to add `.claude/worktrees/` to `.gitignore`. Plan: the orchestrator init adds it next to `.po/`.
15. **New, optional: mechanical model guard.** `Agent(param:value)` deny rules exist, and the value supports `*`.
    - Plan: add `"Agent(model:*fable*)"` and `"Agent(model:inherit)"` to the recommended `deny` list as a backstop for Rule 3.
    - Omitted `model` params never match, so pinned frontmatter is unaffected.
16. **`SubagentStop` also fires for internal Claude agents with an empty `agent_type`.** The `is_team_role` filter in `log-subagent.sh` already covers this, so no change is needed.
17. **Implementers can be confined to their worktree.** Hook input `cwd` follows the worktree while `CLAUDE_PROJECT_DIR` stays at the root, and absolute-path writes from an `isolation: worktree` subagent into the main checkout are not documented as blocked.
    - Plan: `path-guard.sh` denies implementer Write/Edit targets outside the hook's `cwd`. To be decided in Phase 4.
18. **`TaskCompleted` input fields are now verified** (the prompt listed them as unread). Live-team mode may document an optional `TaskCompleted` gate. No script ships unless asked.
19. **Workflow `agent()` options.** The docs page documents only `schema`, `label` and `stallMs`. The in-session `workflow-authoring` skill (loaded 2026-10-13, not a code.claude.com page) documents more: `phase`, `model`, `effort`, `isolation: 'worktree'` and `agentType` ("resolved from the same registry as the Agent tool"), and `meta.phases` entries shaped `{ title, detail }`.
    - `research.js` uses `label`, `phase`, `schema` and `agentType: 'team:<role>'`, plus `meta.phases`. It stays optional and research-only.
    - The `agentType` option is sourced from the skill reference, not the docs page. Whether it resolves plugin-scoped names such as `team:solution-architect` is still unconfirmed (UNVERIFIED 4).
    - Plugin workflows need a `Workflow` allow rule or a prompt (workflows.md: "Permission to launch").

## UNVERIFIED (conservative fallback in parentheses)

1. ~~The exact `subagent_type` string for spawning plugin agents.~~ **Resolved by live test S1:** `team:<name>` works. (The orchestrator still stops and reports on a failed spawn instead of falling back to `general-purpose`.)
2. The Skill tool accepting `team:build` from the alias skill. The docs only show `Skill(deploy:deploy)` as a permission example. This session's own Skill tool lists plugin skills as `plugin:skill`. (The alias text also tells the user to type `/team:build` directly if invocation fails.)
3. Whether absolute-path Edit/Write from an `isolation: worktree` subagent into the main checkout is blocked. (The kit never relies on it: subagents return JSON, the main session persists `.po/`, and see Deviation 17.)
4. Whether plugin hooks apply to dynamic-workflow agents, and whether `agentType: 'team:<role>'` resolves plugin-scoped names in `agent()`. (The workflow is optional; budgets are restated in its prompts and are not guaranteed by hooks in workflow mode. If `agentType` fails, drop it and rely on the role named in the prompt.)
5. ~~Branch naming for subagent worktrees.~~ **Resolved by live test S2:** branch `worktree-agent-<agent_id>` under `.claude/worktrees/agent-<agent_id>/`. Implementers still report their branch and commit.
6. Which model `haiku` resolves to on Bedrock. It depends on `ANTHROPIC_DEFAULT_HAIKU_MODEL`, and only Haiku 5.5 supports `effort`. (Unsupported effort falls back per model-config; check the model in `/tasks`.)
7. The format of `CLAUDE_PROJECT_DIR` on native Windows. (Both forms are normalised; S1-S4 worked, so the hooks resolved `.po/` correctly.)
8. Whether `bash` inside shell-form hooks always resolves to Git Bash's `bash` on every Windows setup. (Confirmed on this machine by S1-S4; not testable elsewhere.)
9. The marketplace/plugin `$schema` URLs. They are not in the Claude docs; schemastore serves them, and they are ignored at load. (Keep them; they have no runtime effect.)
10. ~~The shape of `meta.phases` entries in workflows.~~ Resolved by the in-session `workflow-authoring` reference: `{ title, detail }`, with titles matching `phase()` calls exactly. `research.js` now declares one.
11. ~~Hooks firing inside worktree-isolated subagents.~~ **Resolved by live tests S2/S2b:** PreToolUse, SubagentStart and SubagentStop all fired for a worktree-isolated agent. (Not separately confirmed for agents launched with `run_in_background`.)
