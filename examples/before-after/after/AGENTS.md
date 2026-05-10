# AGENTS.md — example-app

## Project Overview

A simple Node.js demonstration app — used to show harness-tools before/after.
Tech stack: Node.js 20, no framework.

## Startup Rules

1. Read this file completely.
2. Run `bash init.sh` to verify the project builds cleanly.
3. Read `feature_list.json` to see current feature status.

## Run Commands

- Install: `npm install`
- Run: `node src/index.js`
- Tests: `node src/index.js | grep 'Hello world'`
- Full verification: `node src/index.js | grep 'Hello world'`

## Hard Constraints

- Do not use `eval()` or `Function()` constructor
- All async code must handle errors explicitly

## Definition of Done

A feature is complete when:
1. Verification command in feature_list.json passes
2. The feature appears in `feature_list.json` with status `"passing"` and evidence

## Session Handoff

- **Start of session**: Read `PROGRESS.md`, run `bash init.sh`, resume from "Next Steps"
- **End of session**: Update `PROGRESS.md`, run verification, commit all work
