# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

`cc-board` is a Claude Code plugin (prefix: `kanban`) that adds a per-project kanban board to any project. It is bundled inside [`dynamic-kanban-mcp`](https://github.com/talpah/dynamic-kanban-mcp) — a single repo that is both the MCP server and the plugin marketplace.

## Commands

| Command | Description |
|---------|-------------|
| `/kanban:setup` | Register kanban MCP for this project + update CLAUDE.md |
| `/kanban:status` | Show board overview, task counts, and live board URL |
| `/kanban:start` | Check if running; guide user to restart if not |
| `/kanban:stop` | Kill the running kanban server for this project |
| `/kanban:uninstall` | Remove MCP registration and CLAUDE.md section |

## Architecture

```
dynamic-kanban-mcp/                    ← single repo: server + plugin marketplace
├── .claude-plugin/
│   └── marketplace.json               ← marketplace manifest (points to ./cc-board)
├── cc-board/                          ← this plugin (plugin name: "kanban")
│   ├── .claude-plugin/plugin.json     ← plugin manifest
│   ├── commands/                      ← one .md per slash command
│   │   ├── setup.md
│   │   ├── status.md
│   │   ├── start.md
│   │   ├── stop.md
│   │   └── uninstall.md
│   ├── skills/                        ← one SKILL.md per command
│   │   ├── setup/SKILL.md
│   │   ├── status/SKILL.md
│   │   ├── start/SKILL.md
│   │   ├── stop/SKILL.md
│   │   └── uninstall/SKILL.md
│   └── CLAUDE.md                      ← this file
├── scripts/
│   └── enable-kanban.sh               ← shell script that does the actual setup
├── mcp-kanban-server.py               ← MCP stdio server entry point
├── kanban_controller.py               ← board logic, HTTP + WebSocket server
├── registry.py                        ← shared ~/.kanban/registry.json management
├── config.py                          ← supports KANBAN_DATA_DIR env var
├── mcp_protocol.py                    ← JSON-RPC 2.0 over stdio
├── models.py                          ← Pydantic data models
├── kanban-board.html                  ← board UI (served over HTTP on :8765)
└── dashboard.html                     ← multi-project dashboard (served on :8700)
```

Per-project data lands in `<project>/.kanban/kanban-progress.json`.

## How it works

`/kanban:setup` (see `skills/setup/SKILL.md`):
1. Detects git root as the project root
2. Locates `scripts/enable-kanban.sh`
3. Runs the script — creates `.kanban/`, registers MCP in local scope, updates CLAUDE.md

The server (`mcp-kanban-server.py`) starts as a Claude Code MCP subprocess. It serves:
- `http://127.0.0.1:<port>/` — board HTML (WebSocket on the same port)
- `http://127.0.0.1:8700/` — multi-project dashboard (first server claims this port)
- `http://127.0.0.1:<port>/api/registry` — list of all active servers

## Development

When modifying the plugin:
- `SKILL.md` changes take effect immediately (no reinstall needed)
- `plugin.json` or `commands/` changes require plugin reinstall: run `/plugin` in CC
- `marketplace.json` changes require re-adding the marketplace

When modifying the server (files in the repo root):
- Changes take effect on the next Claude Code session restart (server is a subprocess)
- `config.py` must retain the `KANBAN_DATA_DIR` env var support — do not remove it

## Key constraint

`config.py` uses `KANBAN_DATA_DIR` to redirect all data files per-project. This is what enables multiple concurrent project boards. It must survive any upstream merges.
