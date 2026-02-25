---
name: kanban:status
description: Show the kanban board status for the current project — task counts, next task, board URL, and dashboard link
disable-model-invocation: true
---

Execute the following steps IN ORDER using your tools directly.

## Step 1: Check if kanban MCP is available

Call the `kanban_status` MCP tool. If it fails with "tool not found" or "unknown tool", tell the user:

> The kanban MCP server is not running for this project. Run `/kanban:setup` to set it up, or `/kanban:start` to start it if already configured.

Stop here if the tool is unavailable.

## Step 2: Display status

Call `kanban_status` and display the output verbatim.

## Step 3: Offer to open the board

Extract the Board UI URL from the output (line starting with "🌐 Board UI:").

Ask: "Open the board in the browser? [y/N]"

If yes:
```bash
xdg-open <board_url>
```
