---
name: kanban:start
description: This skill should be used when the user runs /kanban:start or asks to "start kanban", "restart kanban", "kanban server is down". Starts the kanban server for the current project if it is not already running.
version: 1.0.0
---

# kanban:start

Execute the following steps IN ORDER using your tools directly. Do NOT delegate to other agents.

## Step 1: Detect project root

Use the Bash tool to run: `git rev-parse --show-toplevel`

If it fails, run: `pwd`

Store the result as PROJECT_ROOT.

## Step 2: Check if the server is already running

Use the Bash tool to run:

```bash
python3 -c "
import json, os
from pathlib import Path
reg = Path.home() / '.kanban' / 'registry.json'
if not reg.exists():
    print('NOT_RUNNING')
else:
    entries = json.loads(reg.read_text())
    project_root = 'PROJECT_ROOT'
    match = [e for e in entries if e['project_root'] == project_root]
    if match:
        try:
            os.kill(match[0]['pid'], 0)
            print(f\"RUNNING:{match[0]['port']}\")
        except ProcessLookupError:
            print('NOT_RUNNING')
    else:
        print('NOT_RUNNING')
"
```

Replace `PROJECT_ROOT` with the actual project root path.

If the output starts with `RUNNING:`, extract the port and tell the user:
> Kanban server is already running on port `<port>`. Board: `http://127.0.0.1:<port>/`

Stop here.

## Step 3: Check if the MCP server is configured

Use the Bash tool to run:
```bash
claude mcp list 2>/dev/null | grep kanban
```

If the output is empty, tell the user:
> Kanban is not configured for this project. Run `/kanban:setup` first.

Stop here.

## Step 4: Restart via MCP reload

The kanban server is managed as a Claude Code MCP subprocess. To start it:

Tell the user:
> The kanban server is not running. To start it, run `/mcp reload` in Claude Code — this restarts all MCP servers including kanban.
>
> Alternatively, you can restart Claude Code entirely to re-launch the server.

Do NOT attempt to start the server manually via bash, as it is a stdio MCP server managed by Claude Code.
