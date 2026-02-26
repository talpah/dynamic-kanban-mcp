#!/usr/bin/env python3
"""
Centralized Configuration for Dynamic Kanban MCP Server
Ensures consistent settings across all components
"""

import os
from pathlib import Path
from typing import Any


class KanbanConfig:
    """Centralized configuration management for the Kanban MCP system"""

    # WebSocket Configuration
    WEBSOCKET_PORT = int(os.getenv("KANBAN_WEBSOCKET_PORT", "8765"))
    WEBSOCKET_HOST = os.getenv("KANBAN_WEBSOCKET_HOST", "0.0.0.0")

    # Dashboard/Registry Configuration
    DASHBOARD_PORT = int(os.getenv("KANBAN_DASHBOARD_PORT", "8700"))
    REGISTRY_PATH = Path.home() / ".kanban" / "registry.json"

    # File Paths - Use absolute paths relative to script directory
    @classmethod
    def get_progress_file_path(cls):
        data_dir = os.getenv("KANBAN_DATA_DIR")
        if data_dir:
            return str(Path(data_dir) / "kanban-progress.json")
        return str(Path(__file__).parent / "kanban-progress.json")

    @classmethod
    def get_features_file_path(cls):
        data_dir = os.getenv("KANBAN_DATA_DIR")
        if data_dir:
            return str(Path(data_dir) / "features.json")
        return str(Path(__file__).parent / "features.json")

    # UI files live in ui/ sibling directory
    _UI_DIR = Path(__file__).parent.parent / "ui"

    @classmethod
    def get_ui_file_path_static(cls):
        return str(cls._UI_DIR / "kanban-board.html")

    DEFAULT_PROGRESS_FILE = "./kanban-progress.json"  # Fallback for backward compatibility
    DEFAULT_UI_FILE = "kanban-board.html"

    # Server Configuration
    MCP_SERVER_NAME = "dynamic-kanban"
    MCP_SERVER_VERSION = "3.0.0"

    # Default Board Configuration
    DEFAULT_COLUMNS = [
        {"id": "backlog", "name": "📋 Backlog", "emoji": "📋"},
        {"id": "ready", "name": "⚡ Ready", "emoji": "⚡"},
        {"id": "progress", "name": "🔧 In Progress", "emoji": "🔧"},
        {"id": "testing", "name": "🧪 Testing", "emoji": "🧪"},
        {"id": "done", "name": "✅ Done", "emoji": "✅"},
    ]

    # Priority configurations
    PRIORITY_LEVELS = ["low", "medium", "high", "critical"]

    # Validation settings
    MAX_TASK_TITLE_LENGTH = 100
    MAX_TASK_DESCRIPTION_LENGTH = 1000
    MAX_DEPENDENCIES = 10

    # WebSocket settings
    WEBSOCKET_RECONNECT_DELAY = 3  # seconds
    WEBSOCKET_PING_INTERVAL = 30  # seconds
    WEBSOCKET_TIMEOUT = 120  # seconds

    @classmethod
    def get_websocket_url(cls) -> str:
        """Get the complete WebSocket URL"""
        return f"ws://{cls.WEBSOCKET_HOST}:{cls.WEBSOCKET_PORT}"

    @classmethod
    def validate_task_data(cls, task_data: dict[str, Any]) -> list[str]:
        """Validate task data using Pydantic model and return list of errors"""
        try:
            from models import Task
            from pydantic import ValidationError

            # Try to create a Task instance with the data
            Task.model_validate(task_data)
            return []  # No errors if validation passes
        except Exception as e:
            # Extract error messages from Pydantic validation
            if isinstance(e, ValidationError):
                errors = []
                for error in e.errors():
                    field = " -> ".join(str(x) for x in error["loc"])
                    message = error["msg"]
                    errors.append(f"{field}: {message}")
                return errors
            else:
                return [str(e)]

    @classmethod
    def detect_circular_dependencies(cls, tasks: list[dict[str, Any]]) -> list[list[str]]:
        """Detect circular dependencies in task list and return cycles found"""
        # Build dependency graph
        graph = {}
        for task in tasks:
            task_id = task.get("id")
            if task_id:
                graph[task_id] = task.get("dependencies", [])

        cycles = []
        visited = set()
        rec_stack = set()

        def dfs(node: str, path: list[str]) -> bool:
            """Depth-first search to detect cycles"""
            if node in rec_stack:
                # Found a cycle - extract the cycle from the path
                cycle_start = path.index(node)
                cycle = path[cycle_start:] + [node]
                cycles.append(cycle)
                return True

            if node in visited:
                return False

            visited.add(node)
            rec_stack.add(node)
            path.append(node)

            # Check all dependencies
            for dependency in graph.get(node, []):
                if dependency in graph and dfs(dependency, path):  # Only check existing tasks
                    # Continue searching for more cycles
                    pass

            rec_stack.remove(node)
            path.pop()
            return False

        # Check all nodes for cycles
        for task_id in graph:
            if task_id not in visited:
                dfs(task_id, [])

        return cycles

    @classmethod
    def validate_dependencies_against_tasks(
        cls, task_id: str, dependencies: list[str], existing_tasks: list[dict[str, Any]]
    ) -> dict[str, Any]:
        """Validate that dependencies exist and don't create circular dependencies"""
        existing_task_ids = {task.get("id") for task in existing_tasks if task.get("id")}

        # Check for non-existent dependencies
        missing_deps = [
            dep for dep in dependencies if dep not in existing_task_ids and dep != task_id
        ]

        # Create a test task list including the new task to check for cycles
        test_tasks = existing_tasks.copy()
        test_tasks.append({"id": task_id, "dependencies": dependencies})

        # Check for circular dependencies
        circular_deps = cls.detect_circular_dependencies(test_tasks)

        return {
            "valid": len(missing_deps) == 0 and len(circular_deps) == 0,
            "missing": missing_deps,
            "circular": circular_deps,
        }

    @classmethod
    def get_default_task_data(cls) -> dict[str, Any]:
        """Get default task data structure"""
        return {
            "id": "",
            "title": "",
            "description": "",
            "priority": "medium",
            "status": "backlog",
            "dependencies": [],
            "acceptance": "Feature works as described",
        }

    @classmethod
    def ensure_websocket_port_available(cls) -> bool:
        """Check if WebSocket port is available"""
        import socket

        try:
            with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
                s.bind((cls.WEBSOCKET_HOST, cls.WEBSOCKET_PORT))
                return True
        except OSError:
            return False

    @classmethod
    def find_available_port(cls, start_port: int | None = None) -> int:
        """Find an available port starting from start_port"""
        import socket

        if start_port is None:
            start_port = cls.WEBSOCKET_PORT

        for port in range(start_port, start_port + 100):
            try:
                with socket.socket(socket.AF_INET, socket.SOCK_STREAM) as s:
                    s.bind((cls.WEBSOCKET_HOST, port))
                    return port
            except OSError:
                continue

        raise RuntimeError("No available ports found")

    @classmethod
    def get_ui_file_path(cls) -> str:
        """Get the path to the UI file"""
        ui_file = cls._UI_DIR / cls.DEFAULT_UI_FILE
        return str(ui_file)

    @classmethod
    def validate_ui_file_exists(cls) -> bool:
        """Check if the UI file exists"""
        import os

        return os.path.exists(cls.get_ui_file_path())


# Global configuration instance
CONFIG = KanbanConfig()
