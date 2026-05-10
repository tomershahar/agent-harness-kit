---
name: harness-onboard
description: 5-minute guided walkthrough of an existing project harness for new team members
when_to_use: When a developer joins a project that already has a harness and needs to orient quickly, or when picking up a project after a long break
license: MIT
---

# harness-onboard

A read-only walkthrough that shows a new team member what the project is, how to start it, what's in progress, and what to do first — in under 5 minutes.

## When to use

Run this when you clone a repo for the first time, or when picking up a project you haven't touched in weeks.

## Instructions

**Step 1:** From the project root, run:
```bash
bash /path/to/harness-onboard.sh
```
Or if installed globally:
```bash
harness-onboard
```

**Step 2:** Read each section. The output will tell you:
- What the project is (from AGENTS.md ## Overview)
- How to start (from init.sh and ## Run Commands)
- What's in progress (from feature_list.json)
- What to do first (from PROGRESS.md ## Next Steps)
- Hard constraints you must not violate

**Step 3:** Run `bash init.sh` to verify your environment is set up correctly.

**Step 4:** Pick up the first item from "What do I do first?" and get to work.

## Tool Notes

| Tool | How to use |
|---|---|
| Claude Code | Run in terminal from project root. Output lands in your session context. |
| Cursor | Run in Cursor terminal. Paste output into chat for context. |
| Codex | Run before starting a Codex session. Include output in the task brief. |
| Gemini CLI | Run in terminal. Paste into Gemini context window. |
| GitHub Copilot | Paste skill text into Copilot Chat, or add harness script paths to `.github/copilot-instructions.md` |

## Based On

Learn Harness Engineering — https://github.com/walkinglabs/learn-harness-engineering
Lecture 08 (State), Lecture 05 (Bootstrap Contract), Lecture 04 (Instructions)
