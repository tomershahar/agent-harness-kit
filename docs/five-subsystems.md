# The Five Harness Subsystems

Everything an AI agent needs to work reliably in your repo fits into five categories. Score each 1–5 with `harness-audit`. Fix the lowest first.

---

## 1. Instructions

**What it is:** The rules the agent reads before touching anything — your AGENTS.md or CLAUDE.md.

**Example of 1/5:** A 600-line CLAUDE.md that mixes setup instructions, historical decisions, personal preferences, and TODO lists. The agent reads the first 200 lines and misses the constraint at line 450.

**Example of 5/5:** A 40-line AGENTS.md with: project overview, 3 run commands, 5 hard constraints, and links to topic docs (architecture, decisions, API contracts).

**Rule of thumb:** If you can't read it in 2 minutes, it's too long.

---

## 2. Tools

**What it is:** The verification commands the agent runs to confirm its own work is correct.

**Example of 1/5:** No test command defined. The agent declares a feature complete because the code compiles.

**Example of 5/5:** AGENTS.md has `Full verification: npm test && npx tsc --noEmit`. The agent runs this after every change. Failures block it from moving to the next task.

**Rule of thumb:** If the agent can't self-verify, you become the test suite.

---

## 3. Environment

**What it is:** A single script (`init.sh`) that takes the repo from clone to working in one command.

**Example of 1/5:** README says "install Node 18, then npm install, then copy .env.example to .env and fill in the values." Four manual steps, no verification.

**Example of 5/5:** `bash init.sh` installs deps, checks versions, validates .env, runs a smoke test, and exits 0. New team member is productive in 3 minutes.

**Rule of thumb:** A new agent session should pass `init.sh` without any human intervention.

---

## 4. State

**What it is:** The files that tell the agent (and the next human) what's done, what's in progress, and what comes next.

**Example of 1/5:** No tracking files. Each session starts from a git log and guesswork.

**Example of 5/5:** `PROGRESS.md` updated at every session end with done/next/decisions. `feature_list.json` has statuses that match reality. A new agent session picks up exactly where the last one left off.

**Rule of thumb:** Could a fresh agent start the right task with zero questions after reading these files?

---

## 5. Feedback

**What it is:** The test layers that tell the agent whether its change actually worked — unit, integration, and E2E.

**Example of 1/5:** No tests. The agent writes code, the code runs, nothing breaks obviously — so it ships. The bug surfaces in production three days later.

**Example of 5/5:** Unit tests catch logic errors. Integration tests catch wiring errors. One E2E test confirms the user-visible behavior. All run in `npm test`. Agent sees red or green.

**Rule of thumb:** Three layers: does the function work, does the system wire up, does the user get what they asked for.

---

## Scoring

Run `harness-audit` from any project root. Each subsystem scores 1–5. Total out of 25.

| Score | Status |
|---|---|
| 23–25 | Healthy — weekly audit to maintain |
| 18–22 | Needs attention — fix lowest subsystem this week |
| 13–17 | At risk — schedule a repair session |
| <13 | Critical — agent reliability severely impacted |

---

*Based on: Learn Harness Engineering — https://github.com/walkinglabs/learn-harness-engineering*
