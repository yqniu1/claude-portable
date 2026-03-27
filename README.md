# claude-portable

Portable Claude Code configuration: global behaviors, MCP server templates, agent subagents, and skills.
Syncs across machines (PC, Mac) via Git. Claude Code is the primary surface; Claude Desktop is best-effort.

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
├── skills/                      # Procedural skills invoked by agents or directly by user
│   ├── start-my-day/SKILL.md    # Morning briefing procedure (used by day agent)
│   └── survey-designer/SKILL.md # K12 survey design (future: used by research agent)
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

### Claude Desktop behavior

When triage flags a task as complex code work (`suggest_claude_code: true`), Claude Desktop tells
the user to switch to Claude Code CLI. Read-only investigation continues in Desktop.

## MCP Servers

| Server | Package | Purpose | Credentials needed |
|--------|---------|---------|-------------------|
| `memory` | `@modelcontextprotocol/server-memory` | Persistent knowledge graph | `CLAUDE_MEMORY_FILE_PATH` |
| `outlook` | local Node.js server | Outlook email + calendar | `OUTLOOK_MCP_PATH`, `OUTLOOK_TOKEN_FILE` |
| `github` | `@modelcontextprotocol/server-github` | Repos, PRs, code search | `GITHUB_TOKEN` |
| `doc-library` | local Python server (`doc-mcp/server.py`) | Semantic search over ingested PDFs/DOCX | `DOC_MCP_PYTHON`, `DOC_MCP_SERVER_PATH` |

**Planned:** `jira` (Phase 3)

> **doc-library on new machines:** ChromaDB is stored in `doc-mcp/chroma_db/` on OneDrive — let it fully sync before starting Claude. Only run `ingest.py` when adding new documents. Each machine also needs [Ollama](https://ollama.com) installed with `ollama pull mxbai-embed-large`.

## Skills

Skills are procedural specs executed inline by Claude (or invoked by an agent).

| Skill | Direct trigger | Used by agent |
|-------|---------------|--------------|
| `start-my-day` | "Start my day", "morning briefing" | `day` |
| `survey-designer` | "Design a survey for..." | `research` (planned) |

## Adding a New Agent

1. Create `agents/<name>.md` with frontmatter (`name`, `description`, `model`)
2. Add routing rule to the triage agent's assistant table
3. Add routing case to `CLAUDE.md` section 4 if needed
4. Commit and push — setup.sh symlink picks it up automatically

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
  Claude Desktop may not honor per-agent model selection; triage cost savings may not apply there.
- **MCP config sync**: `~/.claude/mcp.json` and `claude_desktop_config.json` are machine-local.
  Re-run `apply-config.py` after pulling changes to `mcp-template.json`.

## Notes for AI Agents

- `CLAUDE.md` is version-controlled here and symlinked to `~/.claude/CLAUDE.md` — edit here, not there
- `agents/` is version-controlled here and symlinked to `~/.claude/agents/`
- `~/.claude/mcp.json` is machine-local — generated by `apply-config.py`, not committed
- Memory data (`~/.claude-memory/memory.json`) is machine-local — not synced across machines
- Secrets live only in machine-local `mcp-configs/.env` and token files — never committed
- `OUTLOOK_CLIENT_ID` in `.env.template` is a public Azure app registration ID, not a secret

## Machines

| Machine | OS | Account | Notes |
|---------|-----|---------|-------|
| PC | Windows 11 | Personal (pniu@outlook.com) | Primary dev machine |
| Mac | macOS | Company Teams account | outlook-mcp needs separate clone |
