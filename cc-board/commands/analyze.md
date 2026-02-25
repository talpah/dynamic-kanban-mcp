---
name: kanban:analyze
description: Generate an implementation plan for a task — breaks it down into subtasks and identifies requirements
argument-hint: "[task-id]"
disable-model-invocation: true
---

Analyze a task's requirements by calling `analyze_task_requirements`.

If `$ARGUMENTS` is provided, use it as the task ID.
Otherwise call `kanban_status` to show in-progress and ready tasks, then ask: "Which task ID to analyze?"

Call `analyze_task_requirements` with the task ID.

Present the implementation plan clearly, highlighting:
- Subtasks or steps identified
- Dependencies flagged
- Estimated complexity
