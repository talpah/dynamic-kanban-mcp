# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

`cc-board` is a Claude Code plugin (prefix: `kanban`) that adds a per-project kanban board to any project. It is bundled inside [`dynamic-kanban-mcp`](https://github.com/talpah/dynamic-kanban-mcp) — a single repo that is both the MCP server and the plugin marketplace.

## Commands

| Command | Description |
|---------|-------------|
| `/kanban:setup` | Register kanban MCP for this project + update CLAUDE.md |
| `/kanban:status` | Show board overview, task counts, and live board URL |
| `/kanban:init` | Initialize board with project tasks |
| `/kanban:add` | Add a single task to the board |
| `/kanban:import` | Import tasks from JSON |
| `/kanban:session` | Start or end a work session |
| `/kanban:analyze` | Analyze board state and priorities |
| `/kanban:task` | Get details or work on a specific task |
| `/kanban:validate` | Validate board consistency |
| `/kanban:prepare` | Quick-plan a backlog task and move it to ready |
| `/kanban:start` | Start working on a ready task — move to in-progress |

## Architecture

```
dynamic-kanban-mcp/                    ← single repo: server + plugin marketplace
├── .claude-plugin/
│   └── marketplace.json               ← marketplace manifest (points to ./cc-board)
├── cc-board/                          ← this plugin (plugin name: "kanban")
│   ├── .claude-plugin/plugin.json     ← plugin manifest
│   ├── commands/                      ← one .md per slash command (no skills/ dir)
│   │   ├── setup.md
│   │   ├── status.md
│   │   ├── init.md
│   │   ├── add.md
│   │   ├── import.md
│   │   ├── session.md
│   │   ├── analyze.md
│   │   ├── task.md
│   │   └── validate.md
│   └── CLAUDE.md                      ← this file
├── scripts/
│   └── enable-kanban.sh               ← shell script that does the actual setup
├── server/
│   ├── mcp-kanban-server.py           ← MCP stdio server entry point
│   ├── kanban_controller.py           ← board logic, HTTP + WebSocket server
│   ├── registry.py                    ← shared ~/.kanban/registry.json management
│   ├── config.py                      ← supports KANBAN_DATA_DIR env var
│   ├── mcp_protocol.py                ← JSON-RPC 2.0 over stdio
│   └── models.py                      ← Pydantic data models
└── ui/
    ├── kanban-board.html              ← board UI (served over HTTP on :8765)
    ├── kanban-board.js                ← board JavaScript
    └── dashboard.html                 ← multi-project dashboard (served on :8700)
```

Per-project data lands in `<project>/.kanban/kanban-progress.json`.

## How it works

`/kanban:setup`:
1. Detects git root as the project root
2. Locates `scripts/enable-kanban.sh`
3. Runs the script — creates `.kanban/`, registers MCP in local scope, updates CLAUDE.md, adds skill permissions

The server (`server/mcp-kanban-server.py`) starts as a Claude Code MCP subprocess. It serves:
- `http://127.0.0.1:<port>/` — board HTML (WebSocket on the same port)
- `http://127.0.0.1:8700/` — multi-project dashboard (first server claims this port)
- `http://127.0.0.1:<port>/api/registry` — list of all active servers

## Task sequencing rules

When the user asks to "do all tasks" or work through multiple tasks:
- Move **one** task to `progress`; keep the rest in `ready`
- Implement the task, then move it to `done`
- Only then advance the next `ready` task to `progress`
- Never put multiple tasks in `progress` simultaneously unless explicitly asked to work in parallel

Before starting any non-trivial task the user requests, check if it already exists on the board. If not, call `add_feature` to create it, then move it to `progress` before beginning.

## Development

When modifying the plugin:
- `commands/*.md` changes require plugin reinstall: run `/plugin` in CC
- `plugin.json` changes require plugin reinstall
- No `skills/` directory — instructions live directly in `commands/*.md`

When modifying the server (files in the repo root):
- Changes take effect on the next Claude Code session restart (server is a subprocess)
- `config.py` must retain the `KANBAN_DATA_DIR` env var support — do not remove it

## Key constraint

`config.py` uses `KANBAN_DATA_DIR` to redirect all data files per-project. This is what enables multiple concurrent project boards. It must survive any upstream merges.
