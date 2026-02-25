---
name: kanban:start
description: Start (or restart) the kanban MCP server for the current project — use after setup, or to recover a stopped server
disable-model-invocation: true
---

Execute the following steps IN ORDER using your tools directly.

## Step 1: Detect project root

Run: `git rev-parse --show-toplevel` (fallback: `pwd`)

Store result as PROJECT_ROOT.

## Step 2: Check if already running

```bash
python3 -c "
import json, os
from pathlib import Path
reg = Path.home() / '.kanban' / 'registry.json'
if not reg.exists():
    print('NOT_RUNNING')
else:
    entries = json.loads(reg.read_text())
    match = [e for e in entries if e['project_root'] == 'PROJECT_ROOT']
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

Replace `PROJECT_ROOT` with the actual path. If output starts with `RUNNING:`, tell the user the port and stop.

## Step 3: Check MCP is configured

```bash
claude mcp list 2>/dev/null | grep kanban
```

If empty: tell the user to run `/kanban:setup` first and stop.

## Step 4: Guide restart

Tell the user:
> The kanban server is not running. Run `/mcp reload` in Claude Code to restart all MCP servers including kanban.
> Alternatively, restart Claude Code entirely.

Do NOT attempt to start the server manually — it is a stdio MCP subprocess managed by Claude Code.
