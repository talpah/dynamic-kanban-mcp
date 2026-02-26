
## Kanban Board

This project has a kanban board enabled. The `kanban` MCP server starts automatically with each Claude Code session.

**At session start:** call `kanban_status` to see the current board and the live board URL.
**After completing a task:** call `kanban_get_next_task` for the next item.

Key tools:
- `kanban_status` — board overview with task counts per column and board URL
- `add_feature` — add a task (title, description, priority)
- `kanban_move_card` — advance cards through the flow
- `kanban_get_next_task` — next highest-priority ready task
- `kanban_start_session` / `kanban_end_session` — track work sessions

## MANDATORY task flow — NEVER skip steps

Every non-trivial task MUST follow this exact sequence:

```
1. add_feature          → creates task in backlog
2. /kanban:prepare <id> → plan agent generates plan, moves task to ready
3. /kanban:start <id>   → moves task to progress, then begin implementation
```

**NEVER** call `kanban_move_card` with `new_status: "progress"` directly.
**NEVER** begin implementation before `/kanban:start` has been called.
**NEVER** skip `/kanban:prepare` — tasks without a plan cannot be started.

Only trivial requests (single command, status check, one-liner, answering a question) may proceed without creating a task.

A `UserPromptSubmit` hook fires on every message. When it warns that no task is in progress, classify the request and follow the mandatory flow if non-trivial.

Task sequencing: move **one** task to `progress` at a time. Complete the full flow (progress → testing → done) before starting the next.

Board data: `.kanban/kanban-progress.json`
Board UI: run `kanban_status` after session start to get the HTTP URL.
