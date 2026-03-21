#!/usr/bin/env bash
# setup.sh — wire up claude-portable repo to Claude Code on any machine
# Run once after cloning: bash setup.sh

set -e

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="$HOME/.claude"
SKILLS_LINK="$CLAUDE_DIR/skills"
SKILLS_TARGET="$REPO_DIR/skills"

echo "claude-portable setup"
echo "Repo:   $REPO_DIR"
echo "Claude: $CLAUDE_DIR"
echo ""

# --- Skills ---
if [ -L "$SKILLS_LINK" ]; then
  echo "✓ Skills symlink already exists: $SKILLS_LINK"
elif [ -d "$SKILLS_LINK" ]; then
  echo "! ~/.claude/skills is a real directory. Backing up to ~/.claude/skills.backup"
  mv "$SKILLS_LINK" "${SKILLS_LINK}.backup"
  create_skills_link=true
else
  create_skills_link=true
fi

if [ "${create_skills_link:-false}" = "true" ]; then
  if [[ "$OSTYPE" == "msys" || "$OSTYPE" == "cygwin" || "$OSTYPE" == "win32" ]]; then
    # Windows: use directory junction via PowerShell (no admin required)
    SKILLS_TARGET_WIN="$(cygpath -w "$SKILLS_TARGET" 2>/dev/null || echo "$SKILLS_TARGET")"
    SKILLS_LINK_WIN="$(cygpath -w "$SKILLS_LINK" 2>/dev/null || echo "$SKILLS_LINK")"
    powershell -Command "New-Item -ItemType Junction -Path '$SKILLS_LINK_WIN' -Target '$SKILLS_TARGET_WIN'"
  else
    # macOS / Linux
    ln -s "$SKILLS_TARGET" "$SKILLS_LINK"
  fi
  echo "✓ Linked: $SKILLS_LINK -> $SKILLS_TARGET"
fi

echo ""
echo "Done. Claude Code will now load skills from the repo."
echo "To add a skill: create skills/<name>/SKILL.md, commit, push."
