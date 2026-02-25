---
name: kanban:add
description: Add a task to the kanban board — interactively collects title, description, priority, effort, epic, stage, and dependencies
argument-hint: "[title]"
disable-model-invocation: true
---

Add a task to the kanban board by calling `add_feature`.

Collect the following fields interactively. If `$ARGUMENTS` is provided, use it as the title and skip asking for it.

**Required — ask if not provided:**
- **title**: short task name

**Ask one by one (user can skip with Enter for defaults):**
- **description**: what needs to be done (default: empty)
- **priority**: `low` / `medium` / `high` / `critical` (default: `medium`)
- **effort**: estimated story points or days, number (default: 1)

**Optional — only ask if user seems to want them:**
- **epic**: group/epic name this task belongs to
- **stage**: initial board column (default: `backlog`)
- **dependencies**: comma-separated task IDs this depends on

Once all values are collected, call `add_feature` with the gathered arguments.

Confirm the task was added and show its ID. Suggest `/kanban:status` to see the updated board.
