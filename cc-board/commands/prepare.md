---
name: kanban:prepare
description: Quick-plan a backlog task — spawns a planning subagent, stores the plan, and moves the task to ready
argument-hint: "[task-id]"
disable-model-invocation: true
---

Prepare a backlog task for development by generating a quick implementation plan.

If `$ARGUMENTS` is provided, use it as the task ID.
Otherwise call `kanban_get_ready_tasks` to list backlog tasks, then ask: "Which task ID to prepare?"

**Step 1 — Fetch task details**

Call `get_task_details` with the task ID.

If the task status is not `backlog`, warn the user: "Task <id> is in `<status>`, not backlog. Prepare anyway? [y/N]". Stop if they say no.

**Step 2 — Quick plan subagent**

Spawn a Task tool agent with `subagent_type: "Plan"` and this prompt:

```
You are a planning agent preparing a kanban task for development.

Task ID: <task_id>
Title: <title>
Description: <description>

Working directory: <current working directory>

Explore the codebase relevant to this task, then produce a concise implementation plan with:
- 3–7 numbered steps
- Key files to create or modify (with paths)
- Any risks, blockers, or dependencies to flag

Keep the plan under 300 words. Return only the plan text, no preamble.

IMPORTANT: Do NOT call any MCP tools that modify data. Do not call add_feature, import_features,
update_task_plan, kanban_move_card, clear_kanban, reset_board, or any other write operation.
Your only job is to explore the codebase and return plan text. The calling agent handles all writes.
```

Fill in `<task_id>`, `<title>`, `<description>` from the `get_task_details` result.
Fill in `<current working directory>` from the shell environment.

**Step 3 — Store plan and advance task**

Call `update_task_plan` with:
- `task_id`: the task ID
- `plan`: the plan text returned by the subagent

Call `kanban_move_card` with:
- `task_id`: the task ID
- `new_status`: `ready`
- `notes`: "Prepared via /kanban:prepare — plan added to task notes"

**Step 4 — Confirm**

Report: "✅ Task <id> is now **ready**. Implementation plan stored in task notes."

Suggest running `/kanban:prepare <next-task-id>` to prepare additional backlog tasks before picking one to work on.
