#!/usr/bin/env python3
"""
Registry for active kanban server instances.
Servers register on startup and deregister on shutdown.
Shared via ~/.kanban/registry.json with file locking.
"""

import fcntl
import json
import logging
import os
from datetime import datetime
from pathlib import Path

from config import CONFIG

logger = logging.getLogger("kanban_registry")


def _registry_path() -> Path:
    return CONFIG.REGISTRY_PATH


def _read_registry(f) -> list[dict]:
    """Read registry from open file handle (already locked)."""
    f.seek(0)
    content = f.read()
    if not content:
        return []
    try:
        return json.loads(content)
    except json.JSONDecodeError:
        return []


def _write_registry(f, entries: list[dict]) -> None:
    """Write registry to open file handle (already locked)."""
    f.seek(0)
    f.truncate()
    f.write(json.dumps(entries, indent=2))


def _is_alive(pid: int) -> bool:
    """Return True if process with given PID is running."""
    try:
        os.kill(pid, 0)
        return True
    except (ProcessLookupError, PermissionError):
        return False


def _prune(entries: list[dict]) -> list[dict]:
    """Remove entries whose PID is no longer alive."""
    return [e for e in entries if _is_alive(e["pid"])]


def register(project_name: str, project_root: str, port: int, pid: int) -> None:
    """Add or update this server's entry in the shared registry."""
    path = _registry_path()
    path.parent.mkdir(parents=True, exist_ok=True)

    with open(path, "a+") as f:
        fcntl.flock(f, fcntl.LOCK_EX)
        try:
            entries = _prune(_read_registry(f))
            # Remove any existing entry for this PID or port
            entries = [e for e in entries if e["pid"] != pid and e["port"] != port]
            entries.append(
                {
                    "project_name": project_name,
                    "project_root": project_root,
                    "port": port,
                    "pid": pid,
                    "started_at": datetime.now().isoformat(),
                }
            )
            _write_registry(f, entries)
        finally:
            fcntl.flock(f, fcntl.LOCK_UN)

    logger.info(f"Registered {project_name} (port={port}, pid={pid}) in registry")


def deregister(pid: int) -> None:
    """Remove this server's entry from the shared registry."""
    path = _registry_path()
    if not path.exists():
        return

    with open(path, "r+") as f:
        fcntl.flock(f, fcntl.LOCK_EX)
        try:
            entries = _read_registry(f)
            entries = [e for e in entries if e["pid"] != pid]
            _write_registry(f, entries)
        finally:
            fcntl.flock(f, fcntl.LOCK_UN)

    logger.info(f"Deregistered pid={pid} from registry")


def kill_stale_for_project(project_root: str) -> int:
    """Kill any existing servers for the same project_root and remove their registry entries.

    Called on startup so a new session cleanly replaces any orphaned process
    from a previous session that wasn't cleaned up on exit.

    Returns the number of processes killed.
    """
    import signal

    path = _registry_path()
    if not path.exists():
        return 0

    killed = 0
    with open(path, "a+") as f:
        fcntl.flock(f, fcntl.LOCK_EX)
        try:
            entries = _prune(_read_registry(f))
            stale = [e for e in entries if e["project_root"] == project_root and e["pid"] != os.getpid()]
            for entry in stale:
                try:
                    os.kill(entry["pid"], signal.SIGTERM)
                    killed += 1
                    logger.info(f"Killed stale server pid={entry['pid']} for {project_root}")
                except (ProcessLookupError, PermissionError):
                    pass
            remaining = [e for e in entries if e["project_root"] != project_root or e["pid"] == os.getpid()]
            _write_registry(f, remaining)
        finally:
            fcntl.flock(f, fcntl.LOCK_UN)

    return killed


def get_active_servers() -> list[dict]:
    """Return live registry entries, pruning stale ones."""
    path = _registry_path()
    if not path.exists():
        return []

    with open(path, "r+") as f:
        fcntl.flock(f, fcntl.LOCK_EX)
        try:
            entries = _read_registry(f)
            live = _prune(entries)
            if len(live) != len(entries):
                _write_registry(f, live)
        finally:
            fcntl.flock(f, fcntl.LOCK_UN)

    return live
