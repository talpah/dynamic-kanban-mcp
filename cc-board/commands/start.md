---
name: kanban:start
description: Start working on a task — move an existing ready task to in-progress, or create a new one from a title
argument-hint: "[task-id | task title]"
disable-model-invocation: true
---

Start working on a kanban task by moving it to `progress`.

## Determine mode from `$ARGUMENTS`

**If `$ARGUMENTS` starts with `task-`** → it's an existing task ID. Use the **Start Existing Task** flow below.

**If `$ARGUMENTS` is free text (not a task ID)** → it's a title for a new task. Use the **Create and Start** flow below.

**If `$ARGUMENTS` is empty** → call `kanban_get_ready_tasks` to list ready tasks, then ask: "Which task ID to start, or provide a title to create a new one?"

---

## Flow A — Start Existing Task

**Step 1** — Call `get_task_details` with the task ID.

If the task status is not `ready`, warn: "Task <id> is in `<status>`, not ready. Start anyway? [y/N]". Stop if they say no.

**Step 2** — Call `kanban_move_card`:
- `task_id`: the task ID
- `new_status`: `progress`
- `notes`: "Started via /kanban:start"

**Step 3** — Start a session if none is active: call `kanban_status` to check; if no active session, call `kanban_start_session` with `session_name` set to the task title (truncated to 40 chars).

**Step 4** — Report: "🚀 Task <id> **<title>** is now in progress." Show the plan if one exists.

---

## Flow B — Create and Start

**Step 1** — Call `add_feature` with:
- `title`: `$ARGUMENTS`
- `description`: "" (empty — will be filled in later)
- `priority`: `medium`
- `effort`: `m`

Capture the returned task ID from the response.

**Step 2** — Call `kanban_move_card`:
- `task_id`: the new task ID
- `new_status`: `progress`
- `notes`: "Created and started via /kanban:start"

**Step 3** — Start a session if none is active: call `kanban_start_session` with `session_name` set to `$ARGUMENTS` (truncated to 40 chars).

**Step 4** — Report: "🚀 Created and started **<title>** (`<task-id>`)."
