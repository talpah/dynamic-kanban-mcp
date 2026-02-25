# dynamic-kanban-mcp

> **Fork of [renatokuipers/dynamic-kanban-mcp](https://github.com/renatokuipers/dynamic-kanban-mcp)**
>
> Key differences from upstream:
> - **Per-project isolation** via `KANBAN_DATA_DIR` — multiple projects run concurrently without stepping on each other
> - **HTTP serving** — board and dashboard served over HTTP on the server port; no `file://` URLs
> - **Multi-project dashboard** on port 8700 — single view of all active kanban sessions
> - **Shared registry** (`~/.kanban/registry.json`) — servers discover each other and prune stale entries automatically
> - **Claude Code plugin** — `/kanban:setup`, `/kanban:status`, `/kanban:start`, `/kanban:stop`, `/kanban:uninstall`
> - **`uv`-based** — `pyproject.toml` replaces `requirements.txt`; `ruff` + `ty` for lint/typecheck
> - **Reorganized layout** — `server/` for Python, `ui/` for HTML+JS

A Model Context Protocol (MCP) server that gives Claude Code a real-time kanban board for any project, with a browser UI served over HTTP and a multi-project dashboard.

![Screenshot from 2025-06-23 15-16-00](https://github.com/user-attachments/assets/02e030bc-7b31-4242-8429-69ed5785d6ff)
![Screenshot from 2025-06-23 15-15-02](https://github.com/user-attachments/assets/0254cf60-b309-490c-b70a-be70229c2a61)
![Screenshot from 2025-06-23 15-15-25](https://github.com/user-attachments/assets/6a38b248-d2dc-4953-beef-e0ffc45366cc)

## How it works

Each project gets its own kanban server process (managed as a Claude Code MCP subprocess). The server binds HTTP + WebSocket on the same port — the board UI is served over HTTP, so no `file://` URLs. A shared registry (`~/.kanban/registry.json`) lets all servers discover each other, enabling a multi-project dashboard.

```
~/.kanban/registry.json           ← shared registry
       │
┌──────▼──────────┐   ┌──────────────────┐
│ Project A :8765 │   │ Project B :8766  │
│ HTTP + WS       │   │ HTTP + WS        │
│ /         board │   │ /         board  │
│ /dashboard dash │   │ /dashboard dash  │
│ /api/registry   │   │ /api/registry    │
└──────────────────┘   └──────────────────┘
         │
┌────────▼────────┐
│ Dashboard :8700 │  ← first server claims this
│ shows all active│    projects in a grid
└─────────────────┘
```

## Quick start (Claude Code plugin)

This repo is both the MCP server and a Claude Code plugin marketplace. Add it once and use `/kanban:setup` in any project.

**1. Add the marketplace** (one-time):
```
/plugin marketplace add https://github.com/talpah/dynamic-kanban-mcp
```

**2. Set up a project:**
```
/kanban:setup
```

This registers the `kanban` MCP server in local scope for the current project and adds a `## Kanban Board` section to `CLAUDE.md`. Restart Claude Code (or `/mcp reload`) to activate.

**3. Use the board:**
- Call `kanban_status` to get the board URL
- Open `http://127.0.0.1:8765/` in the browser
- Multi-project dashboard: `http://127.0.0.1:8700/`

## Plugin commands

| Command | Description |
|---------|-------------|
| `/kanban:setup` | Register kanban for the current project |
| `/kanban:status` | Show board overview + open in browser |
| `/kanban:start` | Check if running; guide to restart if not |
| `/kanban:stop` | Kill the server for the current project |
| `/kanban:uninstall` | Remove MCP registration and CLAUDE.md section |

## Manual setup (without the plugin)

```bash
# Clone or have the repo available, then for each project:
bash /path/to/dynamic-kanban-mcp/scripts/enable-kanban.sh /path/to/your-project
```

Or with `uv` directly:
```bash
KANBAN_DATA_DIR=/your-project/.kanban \
KANBAN_WEBSOCKET_HOST=127.0.0.1 \
uv run --project /path/to/dynamic-kanban-mcp \
  python /path/to/dynamic-kanban-mcp/server/mcp-kanban-server.py
```

## MCP tools

### Project management
- `create_project` — initialize project with metadata
- `add_feature` — add a task (title, description, priority, effort, epic, stage, dependencies)
- `configure_board` — customize columns and board layout
- `import_features` — bulk import from JSON

### Kanban operations
- `kanban_status` — board stats, next task, board URL
- `kanban_get_ready_tasks` — tasks with all dependencies met
- `kanban_get_next_task` — highest-priority ready task
- `kanban_move_card` — advance task: backlog → ready → progress → testing → done
- `kanban_update_progress` — add progress notes

### Workflow
- `kanban_start_session` / `kanban_end_session` — track work sessions
- `analyze_task_requirements` — generate implementation plans
- `get_task_details` — full task info and history
- `validate_dependencies` / `validate_project_dependencies` — dependency checks

### Maintenance
- `remove_feature`, `remove_features`, `clear_column`, `clear_kanban`, `reset_board`

## Architecture

```
server/
  mcp-kanban-server.py   ← MCP stdio entry point; spawned by Claude Code
  kanban_controller.py   ← board logic, HTTP handler, WebSocket broadcast
  registry.py            ← shared ~/.kanban/registry.json (fcntl-locked)
  config.py              ← configuration; KANBAN_DATA_DIR for per-project isolation
  mcp_protocol.py        ← JSON-RPC 2.0 over stdio
  models.py              ← Pydantic data models
ui/
  kanban-board.html      ← board UI (served over HTTP, connects WS to same port)
  kanban-board.js        ← board JavaScript
  dashboard.html         ← multi-project dashboard (served on port 8700)
scripts/
  enable-kanban.sh       ← shell script used by /kanban:setup
cc-board/                ← Claude Code plugin (name: "kanban")
```

### Per-project isolation

Set `KANBAN_DATA_DIR` to a project-specific path (e.g. `/your-project/.kanban`). The server stores `kanban-progress.json` and `features.json` there. `enable-kanban.sh` sets this automatically.

### HTTP endpoints

Each server exposes these on its port:

| Path | Content |
|------|---------|
| `/` | Board HTML (same port as WebSocket) |
| `/kanban-board.js` | Board JavaScript |
| `/dashboard` | Multi-project dashboard HTML |
| `/api/status` | JSON status for this server |
| `/api/registry` | JSON list of all active servers |

WebSocket upgrades on the same port and path (no dedicated WS port).

## Environment variables

| Variable | Default | Description |
|----------|---------|-------------|
| `KANBAN_DATA_DIR` | repo dir | Directory for `kanban-progress.json` and `features.json` |
| `KANBAN_WEBSOCKET_PORT` | `8765` | Starting port; auto-increments if in use |
| `KANBAN_WEBSOCKET_HOST` | `0.0.0.0` | Bind address (`127.0.0.1` recommended) |
| `KANBAN_DASHBOARD_PORT` | `8700` | Shared dashboard port; first server claims it |

## Development

```bash
# Install dependencies
uv sync

# Lint + typecheck
uv run nox

# Run server manually for testing
KANBAN_DATA_DIR=/tmp/test-kanban KANBAN_WEBSOCKET_HOST=127.0.0.1 \
  uv run python server/mcp-kanban-server.py
```

Requires Python 3.11+, `uv`, `websockets>=16.0`, `pydantic>=2.0`.
