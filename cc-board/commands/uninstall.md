---
name: kanban:uninstall
description: Remove the kanban MCP server registration and Kanban section from CLAUDE.md for the current project
disable-model-invocation: true
---

Execute the following steps IN ORDER using your tools directly.

## Step 1: Detect project root

Run: `git rev-parse --show-toplevel` (fallback: `pwd`)

Store result as PROJECT_ROOT. PROJECT_NAME = last component.

## Step 2: Confirm

Tell the user what will be removed:
- MCP server registration (local scope)
- `## Kanban Board` section from `CLAUDE.md`
- Optionally: `.kanban/` data directory

Ask: "Remove kanban from **PROJECT_NAME**? [y/N]"

Stop if no.

## Step 3: Stop the server if running

```bash
python3 -c "
import json, os
from pathlib import Path
reg = Path.home() / '.kanban' / 'registry.json'
if reg.exists():
    entries = json.loads(reg.read_text())
    match = [e for e in entries if e['project_root'] == 'PROJECT_ROOT']
    if match:
        try:
            os.kill(match[0]['pid'], 0)
            print(match[0]['pid'])
        except ProcessLookupError:
            print('DEAD')
    else:
        print('NOT_FOUND')
else:
    print('NOT_FOUND')
"
```

Replace `PROJECT_ROOT` with actual path. If a live PID is returned: `kill <PID>`

## Step 4: Remove MCP registration

```bash
claude mcp remove kanban --scope local 2>/dev/null || claude mcp remove kanban 2>/dev/null || echo "not registered"
```

## Step 5: Remove CLAUDE.md section

Check if `PROJECT_ROOT/CLAUDE.md` contains `## Kanban Board`. If so, use the Edit tool to remove the `## Kanban Board` section and everything below it until the next `##` heading or end of file.

## Step 6: Ask about data directory

Ask: "Also delete `.kanban/` data directory? This permanently removes all task history. [y/N]"

If yes: `rm -rf PROJECT_ROOT/.kanban`

## Step 7: Report

Tell the user: MCP deregistered, CLAUDE.md updated, data directory kept/deleted. Restart Claude Code or run `/mcp reload` to fully disconnect.
