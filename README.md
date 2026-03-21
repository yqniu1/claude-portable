# claude-portable

Portable Claude Code configuration: MCP server templates and skills.
Syncs across machines (PC, Mac) via Git.

## Structure

```
claude-portable/
├── skills/                      # Claude Code skills (each is a folder with SKILL.md)
├── mcp-configs/
│   ├── mcp-template.json        # MCP server config with env var placeholders
│   └── .env.template            # Template for machine-specific values (never commit .env)
└── README.md
```

## Machine Setup (New Machine)

1. Clone this repo:
   ```bash
   git clone https://github.com/yqniu1/claude-portable.git
   ```

2. Copy env template and fill in machine-specific paths:
   ```bash
   cp mcp-configs/.env.template mcp-configs/.env
   # Edit .env with correct paths for this machine
   ```

3. Create `~/.claude/mcp.json` with hardcoded paths for this machine.
   Use `mcp-configs/mcp-template.json` as a reference, replacing `${VAR}` placeholders
   with actual values from your `.env`.

4. Create `~/.claude/skills/` directory and symlink it to this repo once skills are added:
   ```bash
   mkdir -p ~/.claude/skills   # or on Mac: already exists
   # Once skills are added to this repo:
   ln -s ~/path/to/claude-portable/skills ~/.claude/skills
   ```

## MCP Servers

| Server | Purpose | Notes |
|--------|---------|-------|
| `memory` | Persistent AI memory via MCP | Data file is machine-local, not synced |
| `outlook` | Microsoft Outlook/Calendar integration | Requires local outlook-mcp Node.js server |

## Daily Workflow

```bash
# Edit skills or configs on any machine, then:
git add .
git commit -m "Describe your change"
git push

# On other machines:
git pull
# Symlinks pick up changes immediately — no restart needed
```

## Notes for AI Agents

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
