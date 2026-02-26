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
echo "[1/4] Created ${DATA_DIR}"

# 2. Register in local scope (idempotent: skip if already registered)
if claude mcp list 2>/dev/null | grep -q "^kanban"; then
    echo "[2/4] kanban MCP server already registered, skipped"
else
    claude mcp add \
        --scope local \
        -e "KANBAN_DATA_DIR=${DATA_DIR}" \
        -e "KANBAN_WEBSOCKET_HOST=127.0.0.1" \
        --transport stdio \
        kanban \
        -- uv run --project "${SERVER_DIR}" python "${SERVER_ENTRY}" 2>/dev/null \
        || claude mcp add \
            -e "KANBAN_DATA_DIR=${DATA_DIR}" \
            -e "KANBAN_WEBSOCKET_HOST=127.0.0.1" \
            --transport stdio \
            kanban \
            -- uv run --project "${SERVER_DIR}" python "${SERVER_ENTRY}"
    echo "[2/4] Registered kanban MCP server in local scope"
fi

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

Task sequencing: move **one** task to \`progress\` at a time. Only advance the next \`ready\` task after the current one is \`done\`.

**New work:** A \`UserPromptSubmit\` hook fires on every message. When no task is in progress it will remind you to classify the request — non-trivial work (bug fix, feature, multi-step change) should be tracked with \`/kanban:start <title>\` before you begin; trivial single-step operations proceed without a task.

Board data: \`.kanban/kanban-progress.json\`
Board UI: run \`kanban_status\` after session start to get the HTTP URL.
EOF
    echo "[3/4] Updated ${CLAUDE_MD}"
else
    echo "[3/4] CLAUDE.md already has kanban section, skipped"
fi

# 4. Install UserPromptSubmit hook
HOOK_DIR="${PROJECT_ROOT}/.claude/hooks/UserPromptSubmit"
HOOK_SRC="${SERVER_DIR}/scripts/kanban-hook.sh"
HOOK_DST="${HOOK_DIR}/kanban-hook.sh"
mkdir -p "${HOOK_DIR}"
if [[ ! -f "${HOOK_DST}" ]]; then
    cp "${HOOK_SRC}" "${HOOK_DST}"
    chmod +x "${HOOK_DST}"
    echo "[4/5] Installed kanban-hook.sh → ${HOOK_DST}"
else
    # Always update to pick up latest version
    cp "${HOOK_SRC}" "${HOOK_DST}"
    chmod +x "${HOOK_DST}"
    echo "[4/5] Updated kanban-hook.sh in ${HOOK_DIR}"
fi

# 5. Add kanban skill permissions to .claude/settings.local.json
mkdir -p "${PROJECT_ROOT}/.claude"
PROJECT_ROOT="${PROJECT_ROOT}" python3 << 'PYEOF'
import json
import os
from pathlib import Path

settings_file = Path(os.environ["PROJECT_ROOT"]) / ".claude" / "settings.local.json"
kanban_skills = [
    "Skill(kanban:setup)",
    "Skill(kanban:status)",
    "Skill(kanban:init)",
    "Skill(kanban:add)",
    "Skill(kanban:import)",
    "Skill(kanban:session)",
    "Skill(kanban:analyze)",
    "Skill(kanban:task)",
    "Skill(kanban:validate)",
    "Skill(kanban:prepare)",
    "Skill(kanban:start)",
]

settings: dict = {}
if settings_file.exists():
    try:
        settings = json.loads(settings_file.read_text())
    except json.JSONDecodeError:
        settings = {}

# Kanban skill permissions (allow autonomous invocation without user prompt)
allow_list: list = settings.setdefault("permissions", {}).setdefault("allow", [])
added = [s for s in kanban_skills if s not in allow_list]
allow_list.extend(added)
if added:
    print(f"[5/5] Added {len(added)} kanban skill permission(s) to settings.local.json")
else:
    print("[5/5] Kanban skill permissions already present, skipped")

settings_file.write_text(json.dumps(settings, indent=2) + "\n")
PYEOF

echo ""
echo "Done. Restart Claude Code to activate the kanban server."
