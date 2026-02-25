---
name: kanban:uninstall
description: This skill should be used when the user runs /kanban:uninstall or asks to "remove kanban", "uninstall kanban board", "clean up kanban". Removes the kanban MCP registration and CLAUDE.md section for the current project.
version: 1.0.0
---

# kanban:uninstall

Execute the following steps IN ORDER using your tools directly. Do NOT delegate to other agents.

## Step 1: Detect project root

Use the Bash tool to run: `git rev-parse --show-toplevel`

If it fails, run: `pwd`

Store the result as PROJECT_ROOT. PROJECT_NAME = last component of PROJECT_ROOT.

## Step 2: Confirm with the user

Tell the user what will be removed:
- MCP server registration (local scope)
- `## Kanban Board` section from `CLAUDE.md`
- Optionally: `.kanban/` data directory

Ask: "Remove kanban from **PROJECT_NAME**? This will deregister the MCP server and remove the CLAUDE.md section. [y/N]"

If the user says no, stop here.

## Step 3: Stop the server (if running)

Use the Bash tool to run:
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

Replace `PROJECT_ROOT` with the actual project root path.

If a live PID is returned, kill it:
```bash
kill <PID>
```

## Step 4: Remove MCP registration

Use the Bash tool to run:
```bash
claude mcp remove kanban --scope local 2>/dev/null || claude mcp remove kanban 2>/dev/null || echo "not registered"
```

## Step 5: Remove CLAUDE.md section

Use the Bash tool to check if `PROJECT_ROOT/CLAUDE.md` exists and contains `## Kanban Board`.

If it does, use the Edit tool to remove the `## Kanban Board` section and everything below it until the next `##` heading (or end of file). Be careful to only remove the kanban section.

## Step 6: Ask about data directory

Ask: "Also delete the board data directory `.kanban/`? This will permanently remove all task history. [y/N]"

If yes:
```bash
rm -rf PROJECT_ROOT/.kanban
```
Replace `PROJECT_ROOT` with the actual path.

## Step 7: Report

Tell the user:
- Kanban MCP server deregistered
- CLAUDE.md section removed
- Data directory: deleted / kept (based on step 6)
- Restart Claude Code or run `/mcp reload` to fully disconnect
