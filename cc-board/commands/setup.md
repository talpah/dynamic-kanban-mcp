---
name: kanban:setup
description: Set up a kanban board for the current project — registers the MCP server in local scope and adds a Kanban section to CLAUDE.md
disable-model-invocation: true
---

**IMPORTANT: Do NOT create any JSON files. Do NOT create .mcp.json. Do NOT use npx. Run enable-kanban.sh as shown below.**

## Context (auto-detected)

- Project root: !`git rev-parse --show-toplevel 2>/dev/null || pwd`

## Steps

### Step 1: Locate enable-kanban.sh

Use the Bash tool to find the script — check in order:

```bash
test -f ~/.claude/plugins/marketplaces/dynamic-kanban-mcp/scripts/enable-kanban.sh && echo FOUND || echo NOT_FOUND
```

If NOT_FOUND:
```bash
test -f ~/Projects/dynamic-kanban-mcp/scripts/enable-kanban.sh && echo FOUND || echo NOT_FOUND
```

If NOT_FOUND, clone:
```bash
git clone https://github.com/talpah/dynamic-kanban-mcp ~/.local/share/dynamic-kanban-mcp
```
Then use `~/.local/share/dynamic-kanban-mcp/scripts/enable-kanban.sh`.

### Step 2: Run the setup script

```bash
bash <script-path> <Project root>
```

Use the exact project root from the Context section above (expand `~` to the real home path).

### Step 3: Report to the user

- Kanban board set up for `<Project root>`
- **Restart Claude Code** to activate the kanban MCP server
- Board URL available via `kanban_status` after restart (default: `http://127.0.0.1:8765/`)
- Dashboard: `http://127.0.0.1:8700/`
