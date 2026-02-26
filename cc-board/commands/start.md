---
name: kanban:start
description: Start working on a ready task — moves it to in-progress and begins a work session
argument-hint: "[task-id]"
disable-model-invocation: true
---

Start working on a kanban task by moving it to `progress`.

If `$ARGUMENTS` is provided, use it as the task ID.
Otherwise call `kanban_get_ready_tasks` to list ready tasks, then ask: "Which task ID to start?"

**Step 1 — Fetch task details**

Call `get_task_details` with the task ID.

If the task status is not `ready`, warn: "Task <id> is in `<status>`, not ready. Start anyway? [y/N]". Stop if they say no.

**Step 2 — Move to progress**

Call `kanban_move_card` with:
- `task_id`: the task ID
- `new_status`: `progress`
- `notes`: "Started via /kanban:start"

**Step 3 — Start a work session (if none active)**

Call `kanban_status` to check if there is an active session.
If no active session, call `kanban_start_session` with `session_name`: the task title (truncated to 40 chars).

**Step 4 — Confirm**

Report: "🚀 Task <id> is now **in progress**."

Show the task plan if one exists (from `get_task_details`), so it's visible as you work.
