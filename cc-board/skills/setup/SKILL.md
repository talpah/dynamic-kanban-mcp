---
name: kanban:setup
description: This skill should be used when the user runs /kanban:setup or asks to "set up kanban", "add kanban board", "enable kanban for this project", or "set up task board". Sets up dynamic-kanban-mcp for the current project by registering the MCP server in local scope and updating CLAUDE.md.
version: 2.0.0
---

# kanban:setup

Execute the following steps IN ORDER using your tools directly. Do NOT delegate to other agents.

## Step 1: Detect project root

Use the Bash tool to run: `git rev-parse --show-toplevel`

If it fails, run: `pwd`

Store the result as PROJECT_ROOT. PROJECT_NAME = the last path component of PROJECT_ROOT.

## Step 2: Locate the enable-kanban script

Check each path in order until one is FOUND:

1. `~/Projects/dynamic-kanban-mcp/scripts/enable-kanban.sh` — dev checkout
2. `~/.claude/plugins/marketplaces/dynamic-kanban-mcp/scripts/enable-kanban.sh` — installed marketplace
3. `~/.local/share/cc-board/server/scripts/enable-kanban.sh` — legacy location

Use the Bash tool to check:
```
ls ~/Projects/dynamic-kanban-mcp/scripts/enable-kanban.sh 2>/dev/null && echo FOUND || echo NOT_FOUND
```

If NOT_FOUND at path 1, check path 2:
```
ls ~/.claude/plugins/marketplaces/dynamic-kanban-mcp/scripts/enable-kanban.sh 2>/dev/null && echo FOUND || echo NOT_FOUND
```

If NOT_FOUND at path 2, check path 3:
```
ls ~/.local/share/cc-board/server/scripts/enable-kanban.sh 2>/dev/null && echo FOUND || echo NOT_FOUND
```

If all three return NOT_FOUND, clone the repo:
```
mkdir -p ~/.local/share/cc-board
git clone https://github.com/talpah/dynamic-kanban-mcp ~/.local/share/cc-board/server
```
Then SCRIPT_PATH = `~/.local/share/cc-board/server/scripts/enable-kanban.sh`.

Store the located path as SCRIPT_PATH.

## Step 3: Run the setup script

Use the Bash tool to run:

```
bash SCRIPT_PATH PROJECT_ROOT
```

Replace SCRIPT_PATH and PROJECT_ROOT with actual absolute paths (expand `~` to the real home directory).

The script handles all setup steps: creates `.kanban/`, registers the MCP server in local scope (no `.mcp.json` needed), and appends `## Kanban Board` to `CLAUDE.md`.

## Step 4: Report to the user

Read the output from the script and extract SERVER_DIR (printed as "Server: ..."). Tell the user:

- **Project:** PROJECT_NAME (PROJECT_ROOT)
- **Server:** SERVER_DIR/server/mcp-kanban-server.py
- **Board data:** PROJECT_ROOT/.kanban/
- **Board URL:** available via `kanban_status` after session restart (default: `http://127.0.0.1:8765/`)
- **Dashboard:** `http://127.0.0.1:8700/` (multi-project view, first server claims this port)
- They must restart Claude Code (or run `/mcp reload`) to activate the kanban MCP

Then ask: "Would you like me to open the board in the browser once the server starts? (It will be available after restarting Claude Code)"
