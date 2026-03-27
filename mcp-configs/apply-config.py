#!/usr/bin/env python3
"""apply-config.py — substitute .env variables into mcp-template.json
and write outputs to:
  - ~/.claude/mcp.json          (Claude Code CLI global MCP config)
  - <claude_desktop_config>     (Claude Desktop — mcpServers section only)

Usage:
  python3 mcp-configs/apply-config.py <repo_dir> <home_dir>

Called automatically by setup.sh when mcp-configs/.env exists.
Can also be run manually after editing mcp-template.json or .env.
"""

import json
import os
import platform
import re
import sys
from pathlib import Path


def load_env(env_path: Path) -> dict[str, str]:
    """Parse a simple KEY=VALUE .env file. Ignores comments and blank lines."""
    env: dict[str, str] = {}
    for line in env_path.read_text(encoding="utf-8").splitlines():
        line = line.strip()
        if not line or line.startswith("#"):
            continue
        if "=" not in line:
            continue
        key, _, value = line.partition("=")
        env[key.strip()] = value.strip()
    return env


def substitute(content: str, env: dict[str, str]) -> str:
    """Replace ${VAR} placeholders with values from env dict.
    Unknown placeholders are left as-is (not removed).
    """
    def replacer(match: re.Match) -> str:
        var = match.group(1)
        return env.get(var, match.group(0))

    return re.sub(r"\$\{([^}]+)\}", replacer, content)


def claude_desktop_config_path() -> Path | None:
    """Return the platform-specific path to claude_desktop_config.json."""
    system = platform.system()
    if system == "Windows":
        app_data = os.environ.get("APPDATA")
        if app_data:
            return Path(app_data) / "Claude" / "claude_desktop_config.json"
    elif system == "Darwin":
        return Path.home() / "Library" / "Application Support" / "Claude" / "claude_desktop_config.json"
    elif system == "Linux":
        # Claude Desktop on Linux (if available)
        config_home = os.environ.get("XDG_CONFIG_HOME", str(Path.home() / ".config"))
        return Path(config_home) / "Claude" / "claude_desktop_config.json"
    return None


def write_claude_code_mcp(mcp_servers: dict, home_dir: Path) -> None:
    """Write ~/.claude/mcp.json for Claude Code CLI."""
    claude_dir = home_dir / ".claude"
    claude_dir.mkdir(parents=True, exist_ok=True)
    output_path = claude_dir / "mcp.json"
    payload = {"mcpServers": mcp_servers}
    output_path.write_text(json.dumps(payload, indent=2), encoding="utf-8")
    print(f"✓ Wrote Claude Code MCP config: {output_path}")


def update_claude_desktop_config(mcp_servers: dict) -> None:
    """Merge mcpServers into claude_desktop_config.json, preserving other keys."""
    config_path = claude_desktop_config_path()
    if config_path is None:
        print("! Could not determine Claude Desktop config path for this platform.")
        return

    if not config_path.exists():
        print(f"! Claude Desktop config not found at {config_path} — skipping Desktop update.")
        print("  (Claude Desktop may not be installed, or hasn't been launched yet.)")
        return

    try:
        existing = json.loads(config_path.read_text(encoding="utf-8"))
    except json.JSONDecodeError as e:
        print(f"! Could not parse {config_path}: {e} — skipping Desktop update.")
        return

    existing["mcpServers"] = mcp_servers
    config_path.write_text(json.dumps(existing, indent=2), encoding="utf-8")
    print(f"✓ Updated Claude Desktop config: {config_path}")


def main() -> None:
    if len(sys.argv) < 3:
        print("Usage: python3 apply-config.py <repo_dir> <home_dir>")
        sys.exit(1)

    repo_dir = Path(sys.argv[1])
    home_dir = Path(sys.argv[2])

    env_path = repo_dir / "mcp-configs" / ".env"
    template_path = repo_dir / "mcp-configs" / "mcp-template.json"

    if not env_path.exists():
        print(f"! .env not found at {env_path}")
        print("  Copy mcp-configs/.env.template to mcp-configs/.env and fill in values.")
        sys.exit(1)

    if not template_path.exists():
        print(f"! Template not found at {template_path}")
        sys.exit(1)

    env = load_env(env_path)
    template_content = template_path.read_text(encoding="utf-8")
    substituted = substitute(template_content, env)

    try:
        parsed = json.loads(substituted)
    except json.JSONDecodeError as e:
        print(f"! Template produced invalid JSON after substitution: {e}")
        print("  Check that all ${VAR} placeholders in mcp-template.json have matching entries in .env")
        sys.exit(1)

    mcp_servers = parsed.get("mcpServers", parsed)

    write_claude_code_mcp(mcp_servers, home_dir)
    update_claude_desktop_config(mcp_servers)

    # Warn about any unresolved placeholders
    unresolved = re.findall(r"\$\{([^}]+)\}", substituted)
    if unresolved:
        print(f"\n! Unresolved placeholders (add these to .env): {', '.join(set(unresolved))}")


if __name__ == "__main__":
    main()
