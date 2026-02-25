---
name: kanban:stop
description: This skill should be used when the user runs /kanban:stop or asks to "stop the kanban server", "kill kanban", "shut down kanban board". Kills the kanban server process for the current project.
version: 1.0.0
---

# kanban:stop

Execute the following steps IN ORDER using your tools directly. Do NOT delegate to other agents.

## Step 1: Detect project root

Use the Bash tool to run: `git rev-parse --show-toplevel`

If it fails, run: `pwd`

Store the result as PROJECT_ROOT.

## Step 2: Find the server PID from the registry

Use the Bash tool to run:

```bash
python3 -c "
import json, os
from pathlib import Path
reg = Path.home() / '.kanban' / 'registry.json'
if not reg.exists():
    print('NO_REGISTRY')
else:
    entries = json.loads(reg.read_text())
    project_root = '$(PROJECT_ROOT)'
    match = [e for e in entries if e['project_root'] == project_root]
    if match:
        print(match[0]['pid'])
    else:
        print('NOT_FOUND')
"
```

Replace `$(PROJECT_ROOT)` with the actual project root path.

If the output is `NO_REGISTRY` or `NOT_FOUND`, tell the user:
> No running kanban server found for this project. The server may already be stopped or was never started.

Stop here.

## Step 3: Kill the server

Use the Bash tool to run:
```bash
kill <PID>
```

Replace `<PID>` with the PID from step 2.

If the kill succeeds (exit code 0), tell the user:
> Kanban server (PID <PID>) stopped.

Note: The registry entry will be automatically cleaned up the next time `/api/registry` is accessed. You may need to run `/mcp reload` in Claude Code to fully disconnect.

If the kill fails (process not found), tell the user the server was already stopped.
