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
