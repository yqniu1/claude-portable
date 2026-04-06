# claude-portable

Portable Claude configuration: global behaviors, MCP server templates, agent subagents, and skills.
Syncs across machines (PC, Mac) via Git. Works across three surfaces with graceful degradation.

## Surfaces (in priority order)

| Surface | Role | What works |
|---------|------|------------|
| **Claude Code** (CLI) | Primary workspace | Full subagent routing, skills, file I/O, custom MCP servers, code write |
| **Claude Cowork** | Secondary | Same skills + agents via symlink, native MCP integrations, file I/O |
| **Desktop chat** (claude.ai) | Fallback | Standalone project files in `desktop/`, no file I/O, no subagents |

## Structure

```
claude-portable/
├── CLAUDE.md                    # Global behaviors + assistant routing (symlinked from ~/.claude/CLAUDE.md)
├── agents/                      # Subagent definitions (symlinked from ~/.claude/agents/)
│   ├── triage.md                # Haiku screener — classifies intent, routes to team member
│   ├── day.md                   # Daily planning — morning briefing, calendar, email
│   ├── coding.md                # Software engineering — code Q&A, PR orchestration
│   ├── pr-create.md             # PR implementation — invoked by coding agent after approval
│   └── pr-review.md             # PR review — invoked by coding agent after PR creation
├── skills/                      # Procedural skills (symlinked from ~/.claude/skills/)
│   ├── start-my-day/SKILL.md    # Morning briefing procedure (used by day agent)
│   └── survey-designer/SKILL.md # K12 survey design (future: used by research agent)
├── desktop/                     # Fallback files for Desktop chat (Projects UI)
│   ├── project-instructions.md  # Standalone custom instructions with embedded triage + config
│   └── start-my-day-procedure.md # Standalone briefing procedure (no file I/O)
├── mcp-configs/
│   ├── mcp-template.json        # MCP server config with ${VAR} placeholders
│   ├── .env.template            # Template for machine-specific credentials (never commit .env)
│   └── apply-config.py          # Substitutes .env into template → writes mcp.json + Desktop config
├── project-CLAUDE-template.md   # Template for per-project .claude/CLAUDE.md files
└── setup.sh                     # Run once after cloning — creates symlinks + generates MCP configs
```

## Machine Setup (New Machine)

```bash
# 1. Clone repo
git clone <repo-url> ~/claude-portable
cd ~/claude-portable

# 2. Symlink CLAUDE.md
ln -sf ~/claude-portable/CLAUDE.md ~/.claude/CLAUDE.md   # macOS/Linux
# Windows (PowerShell): New-Item -ItemType SymbolicLink -Path "$HOME\.claude\CLAUDE.md" -Target "$HOME\claude-portable\CLAUDE.md"

# 3. Fill in credentials
cp mcp-configs/.env.template mcp-configs/.env
# Edit mcp-configs/.env with machine-specific paths and tokens

# 4. Run setup — creates agents/ and skills/ symlinks, generates MCP configs
bash setup.sh
```

`setup.sh` creates:
- `~/.claude/skills/` → `claude-portable/skills/`
- `~/.claude/agents/` → `claude-portable/agents/`
- `~/.claude/mcp.json` (Claude Code CLI MCP config)
- `~/AppData/Roaming/Claude/claude_desktop_config.json` mcpServers section (Claude Desktop)

After setup, both **Claude Code** and **Cowork** have full access to skills and agents via the symlinks.

## Using Each Surface

### Claude Code (primary)

Everything works out of the box after `setup.sh`. Full subagent routing, custom MCP servers (Outlook, memory, doc-library), file I/O for config and state.

```bash
claude          # start Claude Code
/start-my-day   # invoke skill directly
```

### Cowork (secondary)

Skills and agents are available via the same `~/.claude/` symlinks — no extra setup needed.

**Additional step:** Enable native MCP integrations in Cowork settings:
- Gmail, Google Calendar, Slack, Atlassian (Jira/Confluence)

These replace the custom MCP servers used by Claude Code. The skill's `allowed-tools` list
includes both naming conventions so it works in either environment.

```
/start-my-day   # works in any Cowork conversation
```

**What's different from Code:** No Outlook (custom MCP), no memory graph (custom MCP), no doc-library. The skill skips unavailable sources gracefully.

### Desktop Chat (fallback)

For the basic claude.ai web chat without Cowork features:

1. Create a **Project** in Claude Desktop
2. Paste `desktop/project-instructions.md` as **Custom Instructions**
3. Upload `desktop/start-my-day-procedure.md` as **Project Knowledge**
4. Enable MCP integrations (Gmail, Google Calendar, Slack, Atlassian)

This is a self-contained copy — no symlinks, no file I/O, config embedded in instructions.

## Agent Team

The assistant routes every substantive request through triage first, then delegates to a specialist.

| Agent | Model | Role | Invokes |
|-------|-------|------|---------|
| `triage` | Haiku | Classifies intent, returns routing JSON, no tool calls | — |
| `day` | Haiku | Calendar, email, morning briefing | `start-my-day` skill |
| `coding` | Sonnet | Code Q&A, debugging, PR orchestration | `pr-create`, `pr-review` |
| `pr-create` | Sonnet | Implements changes, creates PRs | — |
| `pr-review` | Sonnet | Reviews PRs for quality + CI | — |

**Planned (Phase 3+):** `research` (survey design, vector DB), `pm` (JIRA + product context)

**Surface availability:** Full subagent routing works in Claude Code and Cowork. Desktop chat uses embedded triage logic in the project instructions instead.

## MCP Servers

| Server | Package | Purpose | Available in |
|--------|---------|---------|-------------|
| `memory` | `@modelcontextprotocol/server-memory` | Persistent knowledge graph | Code only |
| `outlook` | local Node.js server | Outlook email + calendar | Code only |
| `github` | `@modelcontextprotocol/server-github` | Repos, PRs, code search | Code only |
| `doc-library` | local Python server (`doc-mcp/server.py`) | Semantic search over ingested PDFs/DOCX | Code only |
| Gmail | Native integration | Email | Cowork, Desktop |
| Google Calendar | Native integration | Calendar | Cowork, Desktop |
| Slack | Native integration | Messaging | Cowork, Desktop |
| Atlassian | Native integration | Jira + Confluence | Cowork, Desktop |

> **doc-library on new machines:** ChromaDB is stored in `doc-mcp/chroma_db/` on OneDrive — let it fully sync before starting Claude. Only run `ingest.py` when adding new documents. Each machine also needs [Ollama](https://ollama.com) installed with `ollama pull mxbai-embed-large`.

## Skills

Skills are procedural specs executed inline by Claude (or invoked by an agent).
The `allowed-tools` field in each SKILL.md lists both custom MCP and native integration tool names, so skills work across Code and Cowork without modification.

| Skill | Direct trigger | Used by agent | Surfaces |
|-------|---------------|--------------|----------|
| `start-my-day` | "Start my day", "morning briefing" | `day` | Code, Cowork, Desktop (via `desktop/`) |
| `survey-designer` | "Design a survey for..." | `research` (planned) | Code, Cowork |

## Adding a New Agent

1. Create `agents/<name>.md` with frontmatter (`name`, `description`, `model`)
2. Add routing rule to the triage agent's assistant table
3. Add routing case to `CLAUDE.md` section 4 if needed
4. Commit and push — setup.sh symlink picks it up automatically (Code + Cowork)

## Adding a New MCP Server

1. Add server config to `mcp-configs/mcp-template.json`
2. Add required credentials to `mcp-configs/.env.template` (with comments)
3. Fill in values in your local `mcp-configs/.env`
4. Run `python3 mcp-configs/apply-config.py . ~` to regenerate configs
5. Restart Claude Code / Claude Desktop

## Known Issues

- **Windows paths with spaces**: `setup.sh` junction creation via PowerShell can fail if paths contain
  spaces (e.g., OneDrive paths). If setup fails, create the junction manually — see setup.sh comments.
- **Claude Desktop model frontmatter**: The `model:` field in agent files is a Claude Code CLI feature.
  Cowork and Desktop may not honor per-agent model selection; triage cost savings may not apply there.
- **MCP config sync**: `~/.claude/mcp.json` and `claude_desktop_config.json` are machine-local.
  Re-run `apply-config.py` after pulling changes to `mcp-template.json`.
- **Desktop chat limitations**: No file I/O, no subagent system, no custom MCP servers. The `desktop/`
  folder provides self-contained fallback files that work within these constraints.

## Notes for AI Agents

- `CLAUDE.md` is version-controlled here and symlinked to `~/.claude/CLAUDE.md` — edit here, not there
- `agents/` is version-controlled here and symlinked to `~/.claude/agents/`
- `~/.claude/mcp.json` is machine-local — generated by `apply-config.py`, not committed
- Memory data (`~/.claude-memory/memory.json`) is machine-local — not synced across machines
- Secrets live only in machine-local `mcp-configs/.env` and token files — never committed
- `OUTLOOK_CLIENT_ID` in `.env.template` is a public Azure app registration ID, not a secret
- `desktop/` files are standalone copies for Desktop chat — the authoritative skill lives in `skills/`

## Machines

| Machine | OS | Account | Notes |
|---------|-----|---------|-------|
| PC | Windows 11 | Personal (pniu@outlook.com) | Primary dev machine |
| Mac | macOS | Company Teams account | outlook-mcp needs separate clone |
