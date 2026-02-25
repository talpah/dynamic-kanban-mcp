---
name: kanban:validate
description: Check task dependencies — validates a single task or the entire project
argument-hint: "[task-id|--all]"
disable-model-invocation: true
---

Validate dependencies by calling `validate_dependencies` or `validate_project_dependencies`.

Determine scope from `$ARGUMENTS`:
- Task ID provided → call `validate_dependencies` for that task
- `--all` or no argument → call `validate_project_dependencies`

Report any dependency issues found — circular dependencies, missing tasks, blocked tasks.
If all clear, confirm the project is consistent.
