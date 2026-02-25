
## Kanban Board

This project has a kanban board enabled. The `kanban` MCP server starts automatically with each Claude Code session.

**At session start:** call `kanban_status` to see the current board and the live board URL.
**After completing a task:** call `kanban_get_next_task` for the next item.

Key tools:
- `kanban_status` — board overview with task counts per column and board URL
- `add_feature` — add a task (id, title, description, priority, effort)
- `kanban_move_card` — advance: backlog → ready → progress → testing → done
- `kanban_get_next_task` — next highest-priority ready task
- `kanban_start_session` / `kanban_end_session` — track work sessions

Task sequencing: move **one** task to `progress` at a time. Only advance the next `ready` task after the current one is `done`.

Board data: `.kanban/kanban-progress.json`
Board UI: run `kanban_status` after session start to get the HTTP URL.
