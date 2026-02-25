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
MCP_JSON="${PROJECT_ROOT}/.mcp.json"
CLAUDE_MD="${PROJECT_ROOT}/CLAUDE.md"

echo "Setting up kanban board for: ${PROJECT_NAME}"
echo "  Project:    ${PROJECT_ROOT}"
echo "  Server:     ${SERVER_DIR}"
echo "  Board data: ${DATA_DIR}"
echo ""

# 1. Create project data directory
mkdir -p "${DATA_DIR}"
echo "[1/4] Created ${DATA_DIR}"

# 2. Merge .mcp.json
if [[ -f "${MCP_JSON}" ]]; then
    # Merge kanban entry into existing file
    jq --arg cmd "uv" \
       --argjson args '["run", "--project", "'"${SERVER_DIR}"'", "python", "'"${SERVER_DIR}/mcp-kanban-server.py"'"]' \
       --arg data_dir "${DATA_DIR}" \
       '.mcpServers.kanban = {command: $cmd, args: $args, env: {KANBAN_DATA_DIR: $data_dir, KANBAN_WEBSOCKET_HOST: "127.0.0.1"}}' \
       "${MCP_JSON}" > "${MCP_JSON}.tmp" && mv "${MCP_JSON}.tmp" "${MCP_JSON}"
else
    jq -n \
       --arg cmd "uv" \
       --argjson args '["run", "--project", "'"${SERVER_DIR}"'", "python", "'"${SERVER_DIR}/mcp-kanban-server.py"'"]' \
       --arg data_dir "${DATA_DIR}" \
       '{mcpServers: {kanban: {command: $cmd, args: $args, env: {KANBAN_DATA_DIR: $data_dir, KANBAN_WEBSOCKET_HOST: "127.0.0.1"}}}}' \
       > "${MCP_JSON}"
fi
echo "[2/4] Written ${MCP_JSON}"

# 3. Register in local scope (auto-loads without trust dialog)
claude mcp add \
    --scope local \
    -e "KANBAN_DATA_DIR=${DATA_DIR}" \
    -e "KANBAN_WEBSOCKET_HOST=127.0.0.1" \
    kanban \
    uv -- run --project "${SERVER_DIR}" python "${SERVER_DIR}/mcp-kanban-server.py" 2>/dev/null \
    || claude mcp add \
        -e "KANBAN_DATA_DIR=${DATA_DIR}" \
        -e "KANBAN_WEBSOCKET_HOST=127.0.0.1" \
        kanban \
        uv -- run --project "${SERVER_DIR}" python "${SERVER_DIR}/mcp-kanban-server.py"
echo "[3/4] Registered kanban MCP server in local scope"

# 4. Append kanban section to CLAUDE.md (idempotent)
if [[ ! -f "${CLAUDE_MD}" ]] || ! grep -q "## Kanban Board" "${CLAUDE_MD}"; then
    cat >> "${CLAUDE_MD}" << EOF

## Kanban Board

This project has a kanban board enabled. The \`kanban\` MCP server starts automatically with each Claude Code session.

**At session start:** call \`kanban_status\` to see the current board.
**After completing a task:** call \`kanban_get_next_task\` for the next item.

Key tools:
- \`kanban_status\` — board overview with task counts per column
- \`add_feature\` — add a task (id, title, description, priority, effort)
- \`kanban_move_card\` — advance: backlog → ready → progress → testing → done
- \`kanban_get_next_task\` — next highest-priority ready task
- \`kanban_start_session\` / \`kanban_end_session\` — track work sessions

Board data: \`.kanban/kanban-progress.json\`
Board UI: open ${SERVER_DIR}/kanban-board.html in your browser (WebSocket on port 8765).
EOF
    echo "[4/4] Updated ${CLAUDE_MD}"
else
    echo "[4/4] CLAUDE.md already has kanban section, skipped"
fi

echo ""
echo "Done. Restart Claude Code (or /mcp reload) to activate the kanban server."
