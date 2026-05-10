---
name: harness-audit
description: >-
  Score your agent harness across 5 subsystems (Instructions, Tools, Environment,
  State, Feedback) and get a prioritized fix list. Detects drift between docs and code.
when_to_use: >-
  Use weekly, before a major session, or when agent reliability has degraded.
  Also use after inheriting a project to understand harness health.
license: MIT
---

# harness-audit

Score your harness health and get a prioritized fix list.

**Based on:** Learn Harness Engineering — Walking Labs
**Course:** https://github.com/walkinglabs/learn-harness-engineering
**Lectures:** 02, 03, 04, 08, 10, 12

---

## What This Skill Does

Reads all harness files, compares them against actual code, scores each of the
5 subsystems 1–5, detects drift, and outputs a prioritized fix list.

---

## Step-by-Step Instructions

### Step 1: Read the harness files

Read these files if they exist:
- `AGENTS.md` or `CLAUDE.md`
- `ARCHITECTURE.md`
- `feature_list.json`
- `init.sh`
- `PROGRESS.md`
- `session-handoff.md`

### Step 2: Score each subsystem using the rubric

Read `references/scoring-rubric.md` for exact criteria. For each subsystem, run its drift check.

**Instructions drift check:**
- Does AGENTS.md exist? How many lines?
- Count hard constraints — more than 15?
- Do file paths mentioned in AGENTS.md still exist?

**Tools drift check:**
- Run each verification command listed. Exit code 0 = pass.

**Environment drift check:**
- Run `bash init.sh` if it exists.

**State drift check:**
- Check git log date on PROGRESS.md — how many days ago was it updated?
- For each feature with `"status": "passing"`, confirm the verification command still works.

**Feedback drift check:**
- Check what test files exist.
- Do they match what AGENTS.md describes?

### Step 3: Output the audit report

```
## Harness Audit Report — [date]

### Scores
| Subsystem    | Score | Key finding |
|---|---|---|
| Instructions | X/5   | ... |
| Tools        | X/5   | ... |
| Environment  | X/5   | ... |
| State        | X/5   | ... |
| Feedback     | X/5   | ... |
| **Total**    | X/25  | X% health |

### Priority Fix List (ordered by impact)
1. [Subsystem] — [specific file:line or action] — [why it matters]
2. ...

### Drift Detected
- [file] references [thing] that no longer exists
- feature_list.json: [feature] marked passing but verification fails
```

---

## Tool Notes

| Capability | Claude Code | Cursor | Codex | Gemini CLI | Bash script |
|---|---|---|---|---|---|
| Read files | `Read` tool | file context | file context | file read | `cat` |
| Run commands | `Bash` tool | terminal | shell | shell | direct |
| Trigger | type `harness-audit` | add to `.cursorrules` | add to `AGENTS.md` | add to `GEMINI.md` | `bash harness-audit.sh` |

**To trigger from Cursor**, add to `.cursorrules`:
```
When the user says "harness-audit", follow the instructions in skills/harness-audit/SKILL.md
```

**To trigger from Codex**, add to `AGENTS.md`:
```
When the user says "harness-audit", follow the instructions in skills/harness-audit/SKILL.md
```

**To trigger from Gemini CLI**, add to `GEMINI.md`:
```
When the user says "harness-audit", follow the instructions in skills/harness-audit/SKILL.md
```

Or run `bash skills/harness-audit/scripts/harness-audit.sh` directly.

---

## Based On

Learn Harness Engineering — Walking Labs
https://github.com/walkinglabs/learn-harness-engineering
Lectures: 02, 03, 04, 08, 10, 12
