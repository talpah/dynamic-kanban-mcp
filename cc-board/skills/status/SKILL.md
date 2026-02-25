---
name: kanban:status
description: This skill should be used when the user runs /kanban:status or asks to "show kanban status", "what's on the board", "kanban overview". Calls the kanban_status MCP tool and presents the result.
version: 1.0.0
---

# kanban:status

Execute the following steps IN ORDER using your tools directly. Do NOT delegate to other agents.

## Step 1: Check if kanban MCP is available

Use the kanban_status MCP tool. If it fails with "tool not found" or "unknown tool", tell the user:

> The kanban MCP server is not running for this project. Run `/kanban:setup` to set it up, or `/kanban:start` to start it if already configured.

Stop here if the tool is unavailable.

## Step 2: Call kanban_status

Call the `kanban_status` MCP tool with no arguments. Display the output verbatim.

## Step 3: Offer to open the board

From the output, extract the Board UI URL (line starting with "🌐 Board UI:").

Ask the user: "Open the board in the browser? [y/N]"

If yes, use the Bash tool to run:
```
xdg-open <board_url>
```

Replace `<board_url>` with the extracted URL (e.g. `http://127.0.0.1:8765/`).
