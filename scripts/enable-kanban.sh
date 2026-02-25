#!/usr/bin/env bash
set -euo pipefail

# enable-kanban.sh — set up dynamic-kanban-mcp for a target project
# Usage: enable-kanban.sh <PROJECT_ROOT>

SERVER_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

if [[ $# -lt 1 ]]; then
    echo "Usage: $0 <PROJECT_ROOT>" >&2
    exit 1
fi

PROJECT_ROOT="$(realpath "$1")"
PROJECT_NAME="$(basename "$PROJECT_ROOT")"
DATA_DIR="${PROJECT_ROOT}/.kanban"
CLAUDE_MD="${PROJECT_ROOT}/CLAUDE.md"

SERVER_ENTRY="${SERVER_DIR}/server/mcp-kanban-server.py"

echo "Setting up kanban board for: ${PROJECT_NAME}"
echo "  Project:    ${PROJECT_ROOT}"
echo "  Server:     ${SERVER_DIR}"
echo "  Board data: ${DATA_DIR}"
echo ""

# 1. Create project data directory
mkdir -p "${DATA_DIR}"
echo "[1/3] Created ${DATA_DIR}"

# 2. Register in local scope (auto-loads without trust dialog)
claude mcp add \
    --scope local \
    -e "KANBAN_DATA_DIR=${DATA_DIR}" \
    -e "KANBAN_WEBSOCKET_HOST=127.0.0.1" \
    kanban \
    uv -- run --project "${SERVER_DIR}" python "${SERVER_ENTRY}" 2>/dev/null \
    || claude mcp add \
        -e "KANBAN_DATA_DIR=${DATA_DIR}" \
        -e "KANBAN_WEBSOCKET_HOST=127.0.0.1" \
        kanban \
        uv -- run --project "${SERVER_DIR}" python "${SERVER_ENTRY}"
echo "[2/3] Registered kanban MCP server in local scope"

# 3. Append kanban section to CLAUDE.md (idempotent)
if [[ ! -f "${CLAUDE_MD}" ]] || ! grep -q "## Kanban Board" "${CLAUDE_MD}"; then
    cat >> "${CLAUDE_MD}" << EOF

## Kanban Board

This project has a kanban board enabled. The \`kanban\` MCP server starts automatically with each Claude Code session.

**At session start:** call \`kanban_status\` to see the current board and the live board URL.
**After completing a task:** call \`kanban_get_next_task\` for the next item.

Key tools:
- \`kanban_status\` — board overview with task counts per column and board URL
- \`add_feature\` — add a task (id, title, description, priority, effort)
- \`kanban_move_card\` — advance: backlog → ready → progress → testing → done
- \`kanban_get_next_task\` — next highest-priority ready task
- \`kanban_start_session\` / \`kanban_end_session\` — track work sessions

Board data: \`.kanban/kanban-progress.json\`
Board UI: run \`kanban_status\` after session start to get the HTTP URL.
EOF
    echo "[3/3] Updated ${CLAUDE_MD}"
else
    echo "[3/3] CLAUDE.md already has kanban section, skipped"
fi

echo ""
echo "Done. Restart Claude Code (or /mcp reload) to activate the kanban server."
