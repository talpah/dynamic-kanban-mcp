---
name: kanban:session
description: Start or end a work session — tracks time and progress against the board
argument-hint: "start [name] | end"
disable-model-invocation: true
---

Manage a work session using `kanban_start_session` or `kanban_end_session`.

## Examples

```
/kanban:session start auth-refactor
/kanban:session start "fix payment bugs"
/kanban:session end
```

## Logic

Parse `$ARGUMENTS`:

- Starts with `start` → extract the rest as the session name, then call `kanban_start_session` with `session_name`
  - If no name provided after `start`, ask: "Session name?"
- `end` → call `kanban_end_session` (no arguments needed)
- Empty → ask: "Start or end session? [start/end]"

**On start:** confirm the session name, then show tasks currently `in_progress` or `ready`.

**On end:** confirm the session ended, then show what moved during the session.
