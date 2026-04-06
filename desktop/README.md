# Desktop Fallback Files

These files are for **Desktop chat** (claude.ai Projects UI) — the last-resort surface
when Claude Code and Cowork aren't available.

## Surface Hierarchy

1. **Claude Code** (primary) — full subagent routing, custom MCP, file I/O → use `skills/` and `agents/` directly
2. **Cowork** (secondary) — same skills/agents via `~/.claude/` symlinks → use `/start-my-day` directly
3. **Desktop chat** (fallback) — no skills, no agents, no file I/O → **use these files**

## When to Use These

Only if you're in the basic claude.ai web chat without Cowork features. If you have Cowork,
skip this folder entirely — the real skill at `skills/start-my-day/SKILL.md` works natively.

## Setup (Desktop Chat Only)

1. Create a **Project** in Claude Desktop (claude.ai → Projects → Create project)
2. Paste `project-instructions.md` as **Custom Instructions**
   - Edit the `My Config` block with your name, timezone, and sources
3. Upload `start-my-day-procedure.md` as **Project Knowledge**
4. Enable MCP integrations in settings: Gmail, Google Calendar, Slack, Atlassian
5. Open the project and say **"start my day"**

## What's Different from Code/Cowork

| Feature | Code / Cowork | Desktop chat (these files) |
|---------|---------------|---------------------------|
| Subagent routing | Triage → specialist agents | Inline triage table in instructions |
| Config | `~/.claude/.start-my-day-config.json` | Embedded in project instructions |
| State (last_run) | `~/.claude/.start-my-day-state.json` | Asks user for cutoff time |
| Outlook | Custom MCP server (Code only) | Not available |
| Memory graph | Custom MCP server (Code only) | Claude's conversation memory |

## Files

| File | Purpose |
|------|---------|
| `project-instructions.md` | Custom instructions — persona, triage routing, config, tool reference |
| `start-my-day-procedure.md` | Full briefing procedure + complete MCP tool reference |

## Keeping in Sync

These are standalone copies, not auto-generated. When updating `skills/start-my-day/SKILL.md`,
check if the changes should also be reflected here. The authoritative source is always the skill file.
