---
name: kanban:stop
description: Stop the running kanban server for the current project
disable-model-invocation: true
---

Execute the following steps IN ORDER using your tools directly.

## Step 1: Detect project root

Run: `git rev-parse --show-toplevel` (fallback: `pwd`)

Store result as PROJECT_ROOT.

## Step 2: Find the server PID

```bash
python3 -c "
import json, os
from pathlib import Path
reg = Path.home() / '.kanban' / 'registry.json'
if not reg.exists():
    print('NO_REGISTRY')
else:
    entries = json.loads(reg.read_text())
    match = [e for e in entries if e['project_root'] == 'PROJECT_ROOT']
    if match:
        print(match[0]['pid'])
    else:
        print('NOT_FOUND')
"
```

Replace `PROJECT_ROOT` with the actual path. If output is `NO_REGISTRY` or `NOT_FOUND`, tell the user no server is running and stop.

## Step 3: Kill the server

```bash
kill <PID>
```

If kill succeeds, tell the user the server was stopped. The registry entry cleans up automatically on next access.
