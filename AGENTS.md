# AGENTS.md — agent-harness-kit

## Project Overview

Add one-sentence project description here.
Tech stack: Markdown + Bash (skills kit)

## Startup Rules

Before writing any code, complete in order:

1. Read this file completely.
2. Read `ARCHITECTURE.md` to understand the layer structure.
3. Run `bash init.sh` to verify the project builds cleanly.
4. Read `feature_list.json` to see current feature status.

## Run Commands

- Install: `npm install`
- Dev server: `npm run dev`
- Tests: `npm test`
- Type check: `npx tsc --noEmit`
- Full verification: `npm test`

## Hard Constraints

- All code must pass type checking before commit
- Do not commit broken builds

## Topic Docs

- [Architecture](ARCHITECTURE.md) — read before modifying any layer boundaries

## Definition of Done

A feature is complete when:
1. `npm test` passes with zero errors
2. The feature appears in `feature_list.json` with status `"passing"` and evidence
3. No console errors during normal operation

## Session Handoff

- **Start of session**: Read `PROGRESS.md`, run `bash init.sh`, resume from "Next Steps"
- **End of session**: Update `PROGRESS.md`, run `npm test`, commit all work
