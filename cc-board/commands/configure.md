---
name: kanban:configure
description: Customize the kanban board columns and layout
disable-model-invocation: true
---

Configure the board layout by calling `configure_board`.

First call `kanban_status` to show the current column configuration.

Then ask the user what they want to change:
- Add, remove, or rename columns
- Change column order
- Set WIP limits per column (if supported)

Collect their changes and call `configure_board` with the new configuration.

Confirm the changes and show the updated board layout.
