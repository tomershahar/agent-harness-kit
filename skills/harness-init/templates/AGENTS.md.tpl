# AGENTS.md — {{PROJECT_NAME}}

## Project Overview

{{PROJECT_DESCRIPTION}}
Tech stack: {{TECH_STACK}}

## Startup Rules

Before writing any code, complete in order:

1. Read this file completely.
2. Read `ARCHITECTURE.md` to understand the layer structure.
3. Run `bash init.sh` to verify the project builds cleanly.
4. Read `feature_list.json` to see current feature status.

## Run Commands

- Install: `{{INSTALL_COMMAND}}`
- Dev server: `{{DEV_COMMAND}}`
- Tests: `{{TEST_COMMAND}}`
- Type check: `{{TYPECHECK_COMMAND}}`
- Full verification: `{{CHECK_COMMAND}}`

## Hard Constraints

- {{CONSTRAINT_1}}
- {{CONSTRAINT_2}}

{{READINESS_WARNINGS}}

## Topic Docs

- [Architecture](ARCHITECTURE.md) — read before modifying any layer boundaries

## Definition of Done

A feature is complete when:
1. `{{CHECK_COMMAND}}` passes with zero errors
2. The feature appears in `feature_list.json` with status `"passing"` and evidence
3. No console errors during normal operation

## Session Handoff

- **Start of session**: Read `PROGRESS.md`, run `bash init.sh`, resume from "Next Steps"
- **End of session**: Update `PROGRESS.md`, run `{{CHECK_COMMAND}}`, commit all work
