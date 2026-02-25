---
name: kanban:task
description: Show full details for a task — description, history, dependencies, and current status
argument-hint: "[task-id]"
disable-model-invocation: true
---

Show full task details by calling `get_task_details`.

If `$ARGUMENTS` is provided, use it as the task ID.
Otherwise call `kanban_status` to list tasks, then ask: "Which task ID?"

Call `get_task_details` with the task ID and display the result.
