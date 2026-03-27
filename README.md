# claude-portable

Portable Claude Code configuration: global behaviors, MCP server templates, and skills.
Syncs across machines (PC, Mac) via Git.

## Structure

```
claude-portable/
├── CLAUDE.md                    # Global Claude Code behaviors (symlinked from ~/.claude/CLAUDE.md)
├── project-CLAUDE-template.md   # Template for per-project .claude/CLAUDE.md files
├── skills/                      # Claude Code skills (each is a folder with SKILL.md)
├── mcp-configs/
│   ├── mcp-template.json        # MCP server config with env var placeholders
│   └── .env.template            # Template for machine-specific values (never commit .env)
└── setup.sh                     # Run once after cloning to wire up symlinks
```

## Machine Setup (New Machine)

1. Clone this repo
2. Run `bash setup.sh` to symlink `~/.claude/skills/` → repo
3. Symlink global behaviors: `ln -sf ~/path/to/claude-portable/CLAUDE.md ~/.claude/CLAUDE.md`
4. Copy env template: `cp mcp-configs/.env.template mcp-configs/.env` and fill in paths
5. Create `~/.claude/mcp.json` using `mcp-configs/mcp-template.json` as reference, replacing `${VAR}` placeholders with values from `.env`

## MCP Servers

| Server | Purpose | Notes |
|--------|---------|-------|
| `memory` | Persistent AI memory via MCP | Data file is machine-local, not synced |
| `outlook` | Microsoft Outlook/Calendar integration | Requires local outlook-mcp Node.js server |

## Skills

| Skill | Trigger | Purpose |
|-------|---------|---------|
| `survey-designer` | User asks to create/design/improve a K12 survey | Research-grade survey design with validity/reliability rationale |
| `start-my-day` | "Start my day", "morning briefing", "what did I miss" | Morning briefing: emails (Gmail + Outlook) + calendar (Google + Outlook), last-run cutoff, unified Action/FYI lists |

## Notes for AI Agents

- `CLAUDE.md` **is** in this repo and symlinked to `~/.claude/CLAUDE.md` — edit here, not there
- `~/.claude/mcp.json` is **NOT** in this repo — it's machine-local with hardcoded paths
- Memory data (`~/.claude-memory/memory.json`) is **NOT** synced — each machine is independent
- `OUTLOOK_CLIENT_ID` in `.env.template` is a public Azure app registration ID, not a secret
- Secrets (OAuth tokens, client secrets) live only in machine-local `.env` and token files
- Skills live in `skills/` — each skill is a directory containing a `SKILL.md` file
- To add a new skill: create `skills/<skill-name>/SKILL.md` with proper frontmatter, commit, and push

## Machines

| Machine | OS | Account | Notes |
|---------|-----|---------|-------|
| PC | Windows 11 | Personal (pniu@outlook.com) | Primary dev machine |
| Mac | macOS | Company Teams account | outlook-mcp needs separate clone |
