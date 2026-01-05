# AGENTS - claude-guide

## Project Context
- Purpose: Keep CLAUDE CLI usage lean by wrapping complex workflows in short bash commands and providing a concise onboarding guide.
- Stack: Bash tool wrappers; optional Python workflows via `uv` or `poetry`; git required for release/commit helpers.
- Structure: `tools/` for dev/data/release/commit wrappers, `scripts/generate_tools.sh` to regenerate them, `docs/` for CLAUDE usage philosophy and setup prompt, `README.md` for quick overview.
- Dependencies to verify per environment: `uv` or `poetry`, `aws` CLI for data sync, `tox` if using format target, git with push access for releases.

## Operational Commands
- Dev cycle: `./tools/dev.sh up` (server), `./tools/dev.sh test`, `./tools/dev.sh format`, `./tools/dev.sh shell`.
- Data: `./tools/data.sh pull-local [s3://src] [./data]`, `./tools/data.sh validate [./data]` (requires `scripts/validate_dataset.py`).
- Release: `./tools/release.sh patch|minor|major` (clean git tree, pushes tags).
- Commits: `./tools/commit.sh` for interactive Conventional Commit messages.
- Tool regeneration: `./scripts/generate_tools.sh` to re-detect defaults and rewrite `tools/*.sh`; review outputs before use.
- Line gate: `wc -l AGENTS.md` to ensure <500 lines.

## Golden Rules
- Hard limits: keep every AGENTS.md under 500 lines; no emojis; no tables in context maps; never store secrets or tokens.
- TDD-first: add or update tests before changing tool logic or docs-driven workflows.
- Keep commands intuitive: prefer updating wrappers over writing long instructions; document only the minimal switches.
- Safety: use interactive prompts for destructive actions; do not bypass wrapper defaults without documenting the change.
- Scope discipline: do not modify shared utilities without justification and tests; respect repo-relative paths only.

## SOLID & Design Principles
- SRP: each wrapper handles a single responsibility (dev, data, release, commit); factor out shared helpers instead of mixing concerns.
- OCP: extend via new subcommands or helper scripts rather than editing stable paths; prefer flags/hooks over branching on globals.
- LSP: any substituted runner (uv, poetry, python) must respect the same interface the scripts expect.
- ISP: keep help outputs small; avoid forcing users to supply unused options.
- DIP: depend on abstractions such as `PY_RUN`/`PY_TEST` variables instead of hard-coded binaries; inject via env vars when needed.
- DRY/YAGNI: reuse generator defaults; remove dead code and unused commands; favor composition over inheritance patterns in any new code.

## TDD Protocol
- Flow: write a failing test describing the wrapper behavior, implement the minimal change, then refactor with tests green.
- Coverage: target 90%+ on critical paths for any added Python or shell test harness; prefer targeted invocations like `uv run pytest -q`.
- Test scope: include happy path, missing dependency handling, and error exits for interactive prompts.
- Current state: no automated tests exist; add tests alongside new features before relying on updated scripts.

## Naming Conventions
- Bash/Zsh: file names snake_case with `.sh`; functions snake_case; user-facing aliases use dash-form mapped from snake_case.
- Documentation: markdown files use dash-form (e.g., `setup-guide.md`, `git-workflow.md`); avoid camelCase or snake_case in filenames.

## Context Map (Action Routing)
- **[Repo overview](./README.md)** - Purpose and quickstart narrative.
- **[Tool wrappers](./tools)** - Dev/data/release/commit scripts; edit defaults per stack and keep help text accurate.
- **[Tool generator](./scripts/generate_tools.sh)** - Regenerates `tools/*.sh` based on detected runners; run after stack changes.
- **[Claude guide](./docs/CLAUDE_GUIDE.md)** - Philosophy on short docs and intuitive commands.
- **[Project setup prompt](./docs/PROJECT_SETUP_PROMPT.md)** - Template prompt for initializing new projects and wrappers.

## Validation & Maintenance
- Line count: `wc -l AGENTS.md` must stay under 500.
- Markdown sanity: `mdformat AGENTS.md` or `markdownlint AGENTS.md` if available; keep outputs table-free.
- Script checks: `bash -n tools/*.sh` and `shellcheck tools/*.sh` if installed; dry-run generator before committing.
- Update this file whenever commands, defaults, or new module boundaries change; add nested AGENTS.md in subdirectories only when they gain their own dependencies or >10 files.
