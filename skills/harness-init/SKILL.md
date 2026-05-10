---
name: harness-init
description: >-
  Generate a complete agent harness from an existing repo — AGENTS.md,
  ARCHITECTURE.md, feature_list.json, init.sh, and PROGRESS.md, all populated
  with real project data. Run once when starting or inheriting a project.
when_to_use: >-
  Use when: starting a new project, joining a project with no harness, the agent
  keeps forgetting context between sessions, no verification commands exist,
  no AGENTS.md or it is empty.
license: MIT
---

# harness-init

Generate a complete agent harness from your existing repo in one command.

**Based on:** Learn Harness Engineering — Walking Labs
**Course:** https://github.com/walkinglabs/learn-harness-engineering
**Lectures:** 02 (5 subsystems), 03 (repo as source of truth), 06 (init phase), 08 (feature list)

---

## What This Skill Does

Reads your existing repo and generates five harness files:

| File | Harness subsystem | Purpose |
|---|---|---|
| `AGENTS.md` | Instructions | Project overview, run commands, hard constraints, topic doc links |
| `ARCHITECTURE.md` | Instructions | Layer diagram, key invariants, data flow |
| `feature_list.json` | State | Machine-readable feature tracker with pass/fail status |
| `init.sh` | Environment | Install + verify the project builds cleanly |
| `PROGRESS.md` | State | Session log for cross-session continuity |

---

## Step-by-Step Instructions

### Step 1: Read the repo

Read the following files if they exist:
- `package.json` or `pyproject.toml` or `Cargo.toml` — tech stack and scripts
- `src/` directory structure — understand the layers
- `README.md` — existing project description
- `git log --oneline -20` — recent activity
- Any existing test config (`jest.config.*`, `pytest.ini`, `vitest.config.*`)

### Step 2: Ask three questions (one at a time)

1. "I can see this project uses [detected stack]. Is that correct, and is there anything important I missed?"
2. "How many people work on this project — just you, a small team (2–5), or larger?"
3. "Which agent tools does your team use? (Claude Code / Cursor / Codex / Gemini CLI / other)"

### Step 3: Generate harness files

Use the templates in `templates/` as starting points. Replace all `{{TOKEN}}` placeholders with real values from the repo. Do not leave any placeholder unfilled.

**AGENTS.md rules (from Lecture 04):**
- Keep it under 200 lines
- Include: project overview (2 sentences max), run commands, hard constraints (≤15), links to topic docs
- Do NOT include: history, roadmaps, tutorial prose, anything that will go stale quickly

**ARCHITECTURE.md rules (from Lecture 03):**
- Include: layer diagram, key invariants per layer, data flow as numbered steps, storage layout
- Do NOT include: why decisions were made, future plans, framework basics

**feature_list.json rules (from Lecture 08):**
- Every entry needs the triple: behavior description + verification command + current state
- State must be one of: `not_started`, `active`, `blocked`, `passing`
- Seed with the top 3–5 features you can identify from the README or existing code

**init.sh rules (from Lecture 06):**
- Must: install dependencies, run type check, run build
- Use `set -euo pipefail` — stop immediately on any error
- End with a message confirming success and how to launch

**PROGRESS.md rules (from Lecture 05):**
- Include sections: Current State, Completed, In Progress, Known Issues, Next Steps
- Pre-fill Current State with the repo's current git HEAD and test status if discoverable

### Step 4: Verify

Run `bash init.sh`. If it fails, fix the errors before proceeding.

### Step 5: Commit

```bash
git add AGENTS.md ARCHITECTURE.md feature_list.json init.sh PROGRESS.md
git commit -m "harness: initialize project harness (harness-init)"
```

### Step 6: Report

Output a summary:
- List each file created with one sentence on what it contains
- Note anything the team should review or customize
- Remind them to share these files so the whole team works from the same harness

---

## Tool Notes

| Capability | Claude Code | Cursor | Codex | Gemini CLI | Bash script |
|---|---|---|---|---|---|
| Read files | `Read` tool | file context | file context | file read | `cat` |
| Run commands | `Bash` tool | terminal | shell | shell | direct |
| Trigger | type `harness-init` | add to `.cursorrules` | add to `AGENTS.md` | add to `GEMINI.md` | `bash harness-init.sh` |

**To trigger from Cursor**, add to `.cursorrules`:
```
When the user says "harness-init", follow the instructions in skills/harness-init/SKILL.md
```

**To trigger from Codex**, add to `AGENTS.md`:
```
When the user says "harness-init", follow the instructions in skills/harness-init/SKILL.md
```

**To trigger from Gemini CLI**, add to `GEMINI.md`:
```
When the user says "harness-init", follow the instructions in skills/harness-init/SKILL.md
```

Or run `bash skills/harness-init/scripts/harness-init.sh` directly — no agent tool needed.

---

## Based On

Learn Harness Engineering — Walking Labs
https://github.com/walkinglabs/learn-harness-engineering
Lectures: 02, 03, 06, 08
