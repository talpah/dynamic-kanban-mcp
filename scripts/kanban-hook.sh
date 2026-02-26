#!/usr/bin/env bash
# UserPromptSubmit hook for dynamic-kanban-mcp
# Injects a kanban task reminder when no task is currently in progress.
# Install location: <project>/.claude/hooks/UserPromptSubmit/kanban-hook.sh

set -euo pipefail

PROJECT_ROOT="$(git rev-parse --show-toplevel 2>/dev/null)" || exit 0
REGISTRY="${HOME}/.kanban/registry.json"

[[ -f "$REGISTRY" ]] || exit 0

# Look up port for this project from the shared registry
PORT=$(python3 -c "
import json, sys
try:
    with open(sys.argv[1]) as f:
        data = json.load(f)
    entry = next((e for e in data if e['project_root'] == sys.argv[2]), None)
    print(entry['port'] if entry else '')
except Exception:
    pass
" "$REGISTRY" "$PROJECT_ROOT" 2>/dev/null)

[[ -z "$PORT" ]] && exit 0

# Check in-progress count (fast, 1s timeout — fail silently if server is down)
STATUS=$(curl -sf --max-time 1 "http://127.0.0.1:${PORT}/api/status" 2>/dev/null) || exit 0

IN_PROGRESS=$(python3 -c "
import json, sys
try:
    d = json.loads(sys.argv[1])
    print(d.get('status_counts', {}).get('progress', 0))
except Exception:
    print(0)
" "$STATUS" 2>/dev/null)

[[ "${IN_PROGRESS:-0}" -gt 0 ]] && exit 0

# No active task — inject judgment prompt
cat <<'EOF'
⚠️  No kanban task is currently in progress. Before proceeding, classify this request:

  NON-TRIVIAL → create + start a task first (then continue with the work):
    Examples: bug fix, new feature, refactor, multi-step change, anything touching 2+ files
    Action: call add_feature (title, priority, effort) then kanban_move_card to "progress"

  TRIVIAL → proceed immediately without a task:
    Examples: single command, status check, cache clear, answering a question, one-liner edit

Use your judgment. When in doubt, lean toward creating a task.
EOF
