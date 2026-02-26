---
name: kanban:start
description: Move a ready task to in-progress and begin working on it
argument-hint: "[task-id]"
disable-model-invocation: true
---

Move a **ready** task to `progress` and begin work. Only `ready` tasks can be started — tasks must go through `/kanban:prepare` first to get a plan.

**Mandatory flow:** `backlog` → `/kanban:prepare` → `ready` → `/kanban:start` → `progress` → `testing` → `done`

## Determine task from `$ARGUMENTS`

**If `$ARGUMENTS` starts with `task-`** → use it as the task ID.

**If `$ARGUMENTS` is free text** → this is a new task title. Do NOT create-and-start directly. Instead:
1. Call `add_feature` with the title (priority `medium`, effort `m`) to create in `backlog`
2. Tell the user: "Created task `<id>`. Run `/kanban:prepare <id>` to generate a plan and move it to ready before starting."
3. Stop here — do not move to progress.

**If `$ARGUMENTS` is empty** → call `kanban_get_ready_tasks` and ask which task to start.

---

## Starting a ready task

**Step 1** — Call `get_task_details` with the task ID.

If status is `backlog`: stop and tell the user "Task <id> is in backlog — run `/kanban:prepare <id>` first to create a plan and move it to ready."

If status is anything other than `ready`: warn "Task <id> is in `<status>`, expected `ready`. Proceed anyway? [y/N]". Stop if they say no.

**Step 2** — Call `kanban_move_card`:
- `task_id`: the task ID
- `new_status`: `progress`
- `notes`: "Started via /kanban:start"

**Step 3** — Start a session if none is active: call `kanban_status` to check; if no active session, call `kanban_start_session` with `session_name` set to the task title (truncated to 40 chars).

**Step 4** — Report: "🚀 **<title>** (`<id>`) is now in progress." Show the plan if one exists, then begin implementation.
