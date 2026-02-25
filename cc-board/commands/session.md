---
name: kanban:session
description: Start or end a work session — tracks time and progress against the board
argument-hint: "start|end"
disable-model-invocation: true
---

Manage a work session using `kanban_start_session` or `kanban_end_session`.

Determine the action from `$ARGUMENTS`:
- If `$ARGUMENTS` is `start` or empty with no active session → call `kanban_start_session`
- If `$ARGUMENTS` is `end` → call `kanban_end_session`
- If `$ARGUMENTS` is neither, ask: "Start or end session? [start/end]"

**On start:** call `kanban_start_session`, then show what tasks are `in_progress` or `ready` to work on.

**On end:** call `kanban_end_session`, then show a summary of what moved during the session.
