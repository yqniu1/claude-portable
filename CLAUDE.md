# Global Claude Code Behaviors

This file is symlinked from `~/.claude/CLAUDE.md` on each machine.
Edit here, commit, push — changes apply everywhere on next `git pull`.

---

## 1. Memory (every session)

- Begin each session by saying "Remembering..." and retrieving all relevant info from the memory MCP knowledge graph
- During conversation: store new preferences, context, and decisions as entities and observations in the memory graph
- At session end: create a session entity named `Session-YYYY-MM-DD-[topic]` with entityType `"session"` and observations summarizing: what was discussed, decisions made, and next steps

## 2. README Maintenance (coding projects)

- When completing a task in a project that has a README.md, check if it needs updating
- Update README if: new features were added, setup steps changed, architecture shifted, or current work changed
- Keep README oriented toward future AI agents and new contributors — focus on "what is this, how does it work, what's actively in progress"
- Do not rewrite the whole README — make targeted updates to the relevant sections only

## 3. Collaborative Coding Style

- Before starting any multi-step task, confirm the approach with the user (use plan mode for non-trivial tasks)
- Prefer editing existing files over creating new ones
- Keep solutions minimal — don't add features, docs, comments, or error handling beyond what was asked
- When blocked, explain the blocker clearly and ask rather than brute-forcing or guessing
- This is a living list — add new preferences here as they emerge from working together

## 4. Assistant Routing

For any substantive request (not a greeting or one-liner), invoke the `triage` subagent first. It classifies intent cheaply (Haiku, no tool calls) and returns routing JSON.

**Routing rules based on triage output:**

- `assistant: "day"` → delegate to `day` subagent
- `assistant: "research"` → delegate to `research` subagent
- `assistant: "pm"` → delegate to `pm` subagent
- `assistant: "coding"` → delegate to `coding` subagent
- `assistant: "general"` → answer directly without delegation

**Claude Desktop behavior:** If triage returns `suggest_claude_code: true`, say:
> "This is a complex task best handled in Claude Code. Open your terminal, navigate to your project, and run `claude`. I can continue with read-only investigation here."
Then proceed with whatever read-only work is possible.

**Memory context on delegation:** Before delegating to a subagent, pass a brief memory summary — pull the user's current projects, active work, and relevant preferences from the memory graph and include them in the delegation prompt.

**Subagents read memory:** Each subagent queries the memory graph at the start of its work for additional context relevant to its domain.

**PM → Coding handoff:** When the `pm` subagent determines work is ready to implement, it ends its response with a `READY_TO_IMPLEMENT:` section containing a structured spec (ticket, requirements, acceptance criteria). The `coding` subagent accepts this section as its input prompt.
