# Course Reference Map

Every design decision in agent-harness-kit maps back to a specific lecture in the
[Learn Harness Engineering](https://github.com/walkinglabs/learn-harness-engineering) course by Walking Labs.

---

## harness-init

| Design decision | Lecture |
|---|---|
| 5-subsystem model as the output structure | Lecture 02: What Harness Actually Means |
| Repo as single source of truth — generate files into the repo | Lecture 03: Make the Repository Your Single Source of Truth |
| AGENTS.md as router (50–200 lines, links to topic docs) | Lecture 04: Split Instructions Across Files |
| PROGRESS.md + session log template for continuity | Lecture 05: Keep Context Alive Across Sessions |
| Dedicated init phase — init.sh runs before any feature work | Lecture 06: Initialize Before Every Agent Session |
| feature_list.json scaffold with triple structure (behavior, verification, state) | Lecture 08: Use Feature Lists to Constrain What the Agent Does |

---

## harness-audit

| Design decision | Lecture |
|---|---|
| Score each of the 5 subsystems independently | Lecture 02: What Harness Actually Means |
| Check docs against actual code for drift | Lecture 03: Make the Repository Your Single Source of Truth |
| Flag AGENTS.md over 200 lines as instruction bloat | Lecture 04: Split Instructions Across Files |
| Check feature_list.json for stale statuses | Lecture 08: Use Feature Lists to Constrain What the Agent Does |
| Check for verification commands at unit + integration + E2E layers | Lecture 10: Only End-to-End Testing is True Verification |
| Prioritized fix list ordered by impact | Lecture 12: Clean Handoff at the End of Every Session |

---

## harness-handoff

| Design decision | Lecture |
|---|---|
| Record what was done, decisions made, and next steps | Lecture 05: Keep Context Alive Across Sessions |
| Clean-state checklist gates the handoff | Lecture 09: Preventing Agents from Declaring Victory Too Early |
| Three-layer verification before closing (build, tests, startup) | Lecture 09: Preventing Agents from Declaring Victory Too Early |
| Commit handoff as atomic checkpoint | Lecture 12: Clean Handoff at the End of Every Session |
| Update PROGRESS.md at session end | Lecture 12: Clean Handoff at the End of Every Session |
