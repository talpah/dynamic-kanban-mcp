---
name: kanban:init
description: Initialize or reconfigure the kanban project — set name, description, team, and customize columns
argument-hint: "[project-name]"
disable-model-invocation: true
---

Set up project metadata and board layout by calling `create_project` then `configure_board`.

If `$ARGUMENTS` is provided, use it as the project name without asking.

**Step 1 — Project metadata** (ask for any missing):
- **name**: project name (default: current directory name)
- **description**: one-line summary
- **team** (optional): team or owner name

Call `create_project` with the collected values.

**Step 2 — Board columns**

Show the default columns, then ask: "Customize columns? [y/N]"

If yes, ask what columns they want (names and order), then call `configure_board`.
If no, skip.

Confirm what was set up and suggest `/kanban:add` to start adding tasks.
