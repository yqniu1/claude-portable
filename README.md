# claude-portable

Portable Claude Code configuration: global behaviors, MCP server templates, and skills.
Syncs across machines (PC, Mac) via Git.

## Structure

```
claude-portable/
├── CLAUDE.md                    # Global Claude Code behaviors (symlinked from ~/.claude/CLAUDE.md)
├── project-CLAUDE-template.md  # Template for per-project .claude/CLAUDE.md files
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

2. Link global Claude behaviors to `~/.claude/CLAUDE.md`:

   **Mac/Linux (true symlink):**
   ```bash
   ln -sf ~/path/to/claude-portable/CLAUDE.md ~/.claude/CLAUDE.md
   ```

   **Windows with Developer Mode enabled (true symlink, PowerShell as Admin):**
   ```powershell
   New-Item -ItemType SymbolicLink -Path "$env:USERPROFILE\.claude\CLAUDE.md" -Target "C:\path\to\claude-portable\CLAUDE.md"
   ```

   **Windows without Developer Mode (manual copy — run after each `git pull`):**
   ```bash
   cp CLAUDE.md ~/.claude/CLAUDE.md
   ```

3. Copy env template and fill in machine-specific paths:
   ```bash
   cp mcp-configs/.env.template mcp-configs/.env
   # Edit .env with correct paths for this machine
   ```

4. Create `~/.claude/mcp.json` with hardcoded paths for this machine.
   Use `mcp-configs/mcp-template.json` as a reference, replacing `${VAR}` placeholders
   with actual values from your `.env`.

5. Create `~/.claude/skills/` directory and symlink it to this repo once skills are added:
   ```bash
   mkdir -p ~/.claude/skills
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

## Global Claude Behaviors (CLAUDE.md)

`CLAUDE.md` in this repo is the source of truth for how Claude should behave in every session.
It is symlinked from `~/.claude/CLAUDE.md` on each machine.

Current behaviors defined:
- **Memory**: retrieve at session start, store during session, summarize at session end
- **README maintenance**: update project READMEs when tasks change the project meaningfully
- **Collaborative coding style**: confirm approach before multi-step tasks, stay minimal

To update a behavior: edit `CLAUDE.md`, commit, push. Changes apply on next session after `git pull`.

For project-specific behaviors, copy `project-CLAUDE-template.md` into any project as `.claude/CLAUDE.md`.

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
