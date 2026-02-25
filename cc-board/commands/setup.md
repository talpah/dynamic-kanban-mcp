---
name: kanban:setup
description: Set up a kanban board for the current project — registers the MCP server in local scope and adds a Kanban section to CLAUDE.md
disable-model-invocation: true
---

**IMPORTANT: Do NOT create any JSON files. Do NOT create .mcp.json. Do NOT create board.json. Do NOT use npx. The ONLY action is to run the enable-kanban.sh shell script.**

Execute the following steps IN ORDER using your tools directly.

## Step 1: Detect project root

Run: `git rev-parse --show-toplevel`

If it fails, run: `pwd`

Store result as PROJECT_ROOT.

## Step 2: Locate enable-kanban.sh

Check each path until FOUND:

```bash
ls ~/Projects/dynamic-kanban-mcp/scripts/enable-kanban.sh 2>/dev/null && echo FOUND || echo NOT_FOUND
```

If NOT_FOUND:
```bash
ls ~/.claude/plugins/marketplaces/dynamic-kanban-mcp/scripts/enable-kanban.sh 2>/dev/null && echo FOUND || echo NOT_FOUND
```

If NOT_FOUND, clone:
```bash
git clone https://github.com/talpah/dynamic-kanban-mcp ~/.local/share/dynamic-kanban-mcp
```
Then SCRIPT_PATH = `~/.local/share/dynamic-kanban-mcp/scripts/enable-kanban.sh`.

## Step 3: Run the setup script

```bash
bash SCRIPT_PATH PROJECT_ROOT
```

Replace SCRIPT_PATH and PROJECT_ROOT with actual absolute paths (expand `~` to real home directory).

The script creates `.kanban/`, registers the MCP server via `claude mcp add`, and appends `## Kanban Board` to `CLAUDE.md`.

## Step 4: Report to the user

Tell the user:
- Kanban board is set up for PROJECT_ROOT
- Restart Claude Code (or run `/mcp reload`) to activate the kanban MCP server
- Board URL available via `kanban_status` after restart (default: `http://127.0.0.1:8765/`)
- Dashboard (multi-project): `http://127.0.0.1:8700/`
