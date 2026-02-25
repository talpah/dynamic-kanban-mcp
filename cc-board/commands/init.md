---
name: kanban:init
description: Initialize a kanban project with metadata — name, description, team, and initial configuration
argument-hint: "[project-name]"
disable-model-invocation: true
---

Initialize this project's kanban board by calling `create_project`.

Ask the user for any missing details, then call `create_project` with the collected values:
- **name**: project name (default: current directory name)
- **description**: one-line summary of the project
- **team** (optional): team or owner name

If `$ARGUMENTS` is provided, use it as the project name without asking.

After the tool call, confirm what was created and suggest `/kanban:add` to start adding tasks.
