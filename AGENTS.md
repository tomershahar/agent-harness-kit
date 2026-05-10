# AGENTS.md — agent-harness-kit

## Project Overview

Three agent skills (harness-init, harness-audit, harness-handoff) that help teams set up, maintain, and hand off AI agent harnesses across Claude Code, Cursor, Codex, and Gemini CLI.
Tech stack: Markdown (SKILL.md files), Bash (scripts), JSON (templates) — no build step.

## Startup Rules

Before making any changes, complete in order:

1. Read this file completely.
2. Read `ARCHITECTURE.md` to understand the skill structure.
3. Run `bash init.sh` to verify all scripts are valid.
4. Read `feature_list.json` to see current feature status.

## Run Commands

- Verify scripts: `bash init.sh`
- Run tests: `bash tests/run-all.sh`
- Full verification: `bash init.sh && bash tests/run-all.sh`

## Hard Constraints

- Every bash script must pass `bash -n` syntax check before commit
- Never remove or rename `{{TOKEN}}` placeholders in templates — the scripts depend on them
- SKILL.md files must include the frontmatter block (name, description, when_to_use, license)
- Attribution footer (Based On section) must appear in every SKILL.md

## Topic Docs

- [Architecture](ARCHITECTURE.md) — skill structure and file responsibilities
- [Course Reference](docs/course-reference.md) — maps every decision to a lecture

## Definition of Done

A feature is complete when:
1. `bash init.sh` passes with zero errors
2. `bash tests/run-all.sh` passes
3. The feature appears in `feature_list.json` with status `"passing"` and evidence

## Session Handoff

- **Start of session**: Read `PROGRESS.md`, run `bash init.sh`, resume from "Next Steps"
- **End of session**: Update `PROGRESS.md`, run `bash init.sh && bash tests/run-all.sh`, commit all work
