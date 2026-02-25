---
name: kanban:import
description: Bulk import tasks from a JSON file
argument-hint: "[json-file]"
disable-model-invocation: true
---

Bulk import tasks by calling `import_features`.

If `$ARGUMENTS` is provided, use it as the JSON file path.
Otherwise ask the user: "Path to the JSON file to import?"

Read the file with the Read tool to confirm it exists and looks valid before importing.

Call `import_features` with the file contents or path.

Report how many tasks were imported and suggest `/kanban:status` to see the board.
