---
name: harness-handoff
description: >-
  Auto-generate session-handoff.md and update PROGRESS.md at session end.
  Enforces the clean-state checklist before closing — build must pass,
  tests must pass, no debug artifacts, startup path must work.
when_to_use: >-
  Run at the end of every working session before closing the agent.
  Blocks handoff if the clean-state checklist fails.
license: MIT
---

# harness-handoff

Clean session exit with auto-generated handoff artifacts.

**Based on:** Learn Harness Engineering — Walking Labs
**Course:** https://github.com/walkinglabs/learn-harness-engineering
**Lectures:** 05 (continuity), 09 (premature completion), 12 (clean state)

---

## What This Skill Does

1. Runs the clean-state checklist — blocks handoff if anything fails
2. Reads git diff + test results + feature_list.json current state
3. Writes `session-handoff.md`
4. Updates `PROGRESS.md`
5. Commits everything with a standard message

---

## Step-by-Step Instructions

### Step 1: Run clean-state checklist

Check all five dimensions. If any fail, **stop and fix before proceeding**:

```
- [ ] Build passes          → run the build command from AGENTS.md
- [ ] All tests pass        → run the test command from AGENTS.md
- [ ] No debug artifacts    → search for console.log, debugger, TODO, FIXME in src/
- [ ] feature_list.json updated → confirm active feature status is current
- [ ] Startup path works    → run the dev command from AGENTS.md
```

If any item fails, output:
```
HANDOFF BLOCKED: [item] failed.
Fix required: [specific action]
Do not proceed until this is resolved.
```

### Step 2: Gather session data

Read:
- `git diff HEAD~1` or `git diff` — what changed this session
- `git log --oneline -5` — recent commits
- `feature_list.json` — current feature states

### Step 3: Write session-handoff.md

Create or overwrite `session-handoff.md` using the template in `templates/session-handoff.md.tpl`. Fill in all sections with real data — do not leave placeholder text.

Required sections:
- **What Was Accomplished** — each feature with evidence (commit hash or test output)
- **What Remains** — features still at `not_started` or `active`
- **Decisions Made** — the WHY, not just the what
- **Files Modified** — from git diff
- **Blockers** — or "None"
- **Next Steps** — specific, actionable items for next session

### Step 4: Update PROGRESS.md

Append a new session entry to `PROGRESS.md`:

```markdown
### Session [date]
**Goal**: [what this session aimed to do]
**Done**: [what actually got done]
**Next**: [what comes next]
```

### Step 5: Commit

```bash
git add session-handoff.md PROGRESS.md feature_list.json
git commit -m "chore: session handoff [date]"
```

### Step 6: Confirm

Output:
```
Handoff complete. Next session starts with:
  1. Read PROGRESS.md
  2. Read session-handoff.md
  3. Run: bash init.sh
  4. Continue from: [next step from handoff doc]
```

---

## Tool Notes

| Capability | Claude Code | Cursor | Codex | Gemini CLI | Bash script |
|---|---|---|---|---|---|
| Read files | `Read` tool | file context | file context | file read | `cat` |
| Run commands | `Bash` tool | terminal | shell | shell | direct |
| Trigger | type `harness-handoff` | add to `.cursorrules` | add to `AGENTS.md` | add to `GEMINI.md` | `bash harness-handoff.sh` |

**To trigger from Cursor**, add to `.cursorrules`:
```
When the user says "harness-handoff", follow the instructions in skills/harness-handoff/SKILL.md
```

**To trigger from Codex**, add to `AGENTS.md`:
```
When the user says "harness-handoff", follow the instructions in skills/harness-handoff/SKILL.md
```

**To trigger from Gemini CLI**, add to `GEMINI.md`:
```
When the user says "harness-handoff", follow the instructions in skills/harness-handoff/SKILL.md
```

Or run `bash skills/harness-handoff/scripts/harness-handoff.sh` directly.

---

## Based On

Learn Harness Engineering — Walking Labs
https://github.com/walkinglabs/learn-harness-engineering
Lectures: 05, 09, 12
