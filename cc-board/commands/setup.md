---
name: kanban:setup
description: Set up a kanban board for the current project — registers the MCP server in local scope and adds a Kanban section to CLAUDE.md
disable-model-invocation: true
---

**IMPORTANT: Do NOT create any JSON files. Do NOT create .mcp.json. Do NOT use npx. Run enable-kanban.sh as shown below.**

## Context (auto-detected)

- Project root: !`git rev-parse --show-toplevel 2>/dev/null || pwd`
- Script: !`ls ~/.claude/plugins/marketplaces/dynamic-kanban-mcp/scripts/enable-kanban.sh 2>/dev/null || ls ~/Projects/dynamic-kanban-mcp/scripts/enable-kanban.sh 2>/dev/null || echo NOT_FOUND`

## Steps

### If Script shows NOT_FOUND

Clone the repo first:
```bash
git clone https://github.com/talpah/dynamic-kanban-mcp ~/.local/share/dynamic-kanban-mcp
```
Then use `~/.local/share/dynamic-kanban-mcp/scripts/enable-kanban.sh` as the script path.

### Run the setup script

```bash
bash <Script> <Project root>
```

Use the exact values from the Context section above (expand `~` to the real home directory path).

### Report to the user

Tell the user:
- Kanban board set up for `<Project root>`
- Restart Claude Code or run `/mcp reload` to activate the kanban MCP server
- Board URL available via `kanban_status` after restart (default: `http://127.0.0.1:8765/`)
- Dashboard (multi-project): `http://127.0.0.1:8700/`
