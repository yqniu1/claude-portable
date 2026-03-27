#!/usr/bin/env bash
# setup.sh — wire up claude-portable repo to Claude Code on any machine
# Run once after cloning: bash setup.sh

set -e

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="$HOME/.claude"

echo "claude-portable setup"
echo "Repo:   $REPO_DIR"
echo "Claude: $CLAUDE_DIR"
echo ""

# Detect Windows (msys = Git Bash, cygwin, win32 via CI)
is_windows() {
  [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" || "$OSTYPE" == "win32" ]]
}

# Create a symlink or Windows junction
# Usage: make_link <link_path> <target_path>
make_link() {
  local LINK="$1"
  local TARGET="$2"
  local LABEL="$3"

  if [ -L "$LINK" ]; then
    echo "✓ $LABEL symlink already exists: $LINK"
    return
  fi

  if [ -d "$LINK" ]; then
    echo "! $LINK is a real directory. Backing up to ${LINK}.backup"
    mv "$LINK" "${LINK}.backup"
  fi

  if is_windows; then
    # NOTE: Windows paths with spaces in them can cause junction failures here.
    # If this fails, create the junction manually in PowerShell:
    #   New-Item -ItemType Junction -Path "<LINK>" -Target "<TARGET>"
    # Tracked issue: setup.sh risk — Windows paths with spaces (see README.md)
    local TARGET_WIN LINK_WIN
    TARGET_WIN="$(cygpath -w "$TARGET" 2>/dev/null || echo "$TARGET")"
    LINK_WIN="$(cygpath -w "$LINK" 2>/dev/null || echo "$LINK")"
    powershell -Command "New-Item -ItemType Junction -Path '$LINK_WIN' -Target '$TARGET_WIN'"
  else
    ln -s "$TARGET" "$LINK"
  fi

  echo "✓ Linked: $LINK -> $TARGET"
}

# --- Skills ---
make_link "$CLAUDE_DIR/skills" "$REPO_DIR/skills" "Skills"

# --- Agents ---
make_link "$CLAUDE_DIR/agents" "$REPO_DIR/agents" "Agents"

echo ""

# --- MCP Config ---
ENV_FILE="$REPO_DIR/mcp-configs/.env"

if [ -f "$ENV_FILE" ]; then
  echo "Generating MCP configs from template..."
  python3 "$REPO_DIR/mcp-configs/apply-config.py" "$REPO_DIR" "$HOME"
else
  echo "! mcp-configs/.env not found."
  echo "  Copy the template and fill in your values:"
  echo "    cp mcp-configs/.env.template mcp-configs/.env"
  echo "  Then re-run setup.sh (or run apply-config.py directly)."
fi

echo ""
echo "Done."
echo "  Add a skill:  create skills/<name>/SKILL.md, commit, push"
echo "  Add an agent: create agents/<name>.md, commit, push"
echo "  Update MCP:   edit mcp-configs/mcp-template.json, update .env, re-run setup.sh"
