---
name: kanban:status
description: Show the kanban board status — task counts, next task, board URL, and command reference
disable-model-invocation: true
---

Execute the following steps:

## Step 1: Call kanban_status

Call the `kanban_status` MCP tool. If it fails with "tool not found", tell the user to run `/kanban:setup` first and stop.

Display the output verbatim.

## Step 2: Append quick reference

After the status output, print this command reference:

```
── Kanban commands ──────────────────────────────
/kanban:add [title]        add a task interactively
/kanban:task [id]          view full task details
/kanban:analyze [id]       generate implementation plan
/kanban:validate [id|--all] check dependencies
/kanban:session start|end  track a work session
/kanban:init               set project metadata & columns
/kanban:import [file]      bulk import tasks from JSON
/kanban:setup              re-register MCP server
```

## Step 3: Offer to open the board

Extract the Board UI URL (line starting with "🌐 Board UI:") and ask:
"Open the board in the browser? [y/N]"

If yes: `xdg-open <board_url>`
