import nox

nox.options.default_venv_backend = "uv"
nox.options.sessions = ["lint", "typecheck"]


@nox.session
def lint(session: nox.Session) -> None:
    """Run ruff linter and formatter check."""
    session.install("ruff>=0.9")
    session.run("ruff", "check", ".")
    session.run("ruff", "format", "--check", ".")


@nox.session(name="format")
def format_(session: nox.Session) -> None:
    """Auto-fix formatting and lint issues with ruff."""
    session.install("ruff>=0.9")
    session.run("ruff", "check", "--fix", ".")
    session.run("ruff", "format", ".")


@nox.session
def typecheck(session: nox.Session) -> None:
    """Run ty type checker."""
    session.install("ty>=0.0.1a0", "pydantic>=2.12", "websockets>=16.0")
    session.run("ty", "check", "server/")


@nox.session
def tests(session: nox.Session) -> None:
    """Run pytest test suite."""
    session.install("pytest>=8.0", "pydantic>=2.12", "websockets>=16.0")
    session.run("pytest", "tests/", "-v")
