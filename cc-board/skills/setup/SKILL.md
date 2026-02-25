---
name: kanban:setup
description: This skill should be used when the user runs /kanban:setup or asks to "set up kanban", "add kanban board", "enable kanban for this project", or "set up task board". Sets up dynamic-kanban-mcp for the current project by registering the MCP server in local scope and updating CLAUDE.md.
version: 2.0.0
---

# kanban:setup

**CRITICAL: Do NOT create any JSON files. Do NOT create .mcp.json. Do NOT create board.json. Do NOT use npx. The ONLY action required is to run the enable-kanban.sh shell script using the Bash tool.**

Execute the following steps IN ORDER using your tools directly. Do NOT delegate to other agents.

## Step 1: Detect project root

Use the Bash tool to run: `git rev-parse --show-toplevel`

If it fails, run: `pwd`

Store the result as PROJECT_ROOT.

## Step 2: Locate the enable-kanban script

Check in order until FOUND:

```bash
ls ~/Projects/dynamic-kanban-mcp/scripts/enable-kanban.sh 2>/dev/null && echo FOUND || echo NOT_FOUND
```

If NOT_FOUND, check:
```bash
ls ~/.claude/plugins/marketplaces/dynamic-kanban-mcp/scripts/enable-kanban.sh 2>/dev/null && echo FOUND || echo NOT_FOUND
```

If NOT_FOUND, clone:
```bash
git clone https://github.com/talpah/dynamic-kanban-mcp ~/.local/share/dynamic-kanban-mcp
```
Then SCRIPT_PATH = `~/.local/share/dynamic-kanban-mcp/scripts/enable-kanban.sh`.

## Step 3: Run the setup script

Use the Bash tool to run (expand `~` to real home path):

```bash
bash SCRIPT_PATH PROJECT_ROOT
```

The script creates `.kanban/`, registers the MCP server via `claude mcp add` (no `.mcp.json` needed), and appends `## Kanban Board` to `CLAUDE.md`.

## Step 4: Report to the user

Tell the user:

- Kanban board is set up for PROJECT_ROOT
- They must restart Claude Code (or run `/mcp reload`) to activate the kanban MCP server
- Board URL will be available via `kanban_status` after restart (default: `http://127.0.0.1:8765/`)
- Dashboard (multi-project): `http://127.0.0.1:8700/`
