# Harness Audit Scoring Rubric

Score each subsystem 1–5. Report the lowest score as the priority to fix first.

---

## Subsystem 1: Instructions

| Score | Criteria |
|---|---|
| 5 | AGENTS.md ≤200 lines, links to topic docs, ≤15 hard constraints, no bloat |
| 4 | AGENTS.md ≤300 lines, most rules relevant, minor bloat |
| 3 | AGENTS.md exists but >300 lines OR missing topic doc links |
| 2 | AGENTS.md exists but mixes hard constraints with historical notes/preferences |
| 1 | No AGENTS.md or CLAUDE.md |

**Drift check:** Do the file paths and module names mentioned in AGENTS.md still exist in the repo?

---

## Subsystem 2: Tools

| Score | Criteria |
|---|---|
| 5 | Verification commands listed and all pass when run |
| 4 | Verification commands listed, 1–2 fail |
| 3 | Verification commands listed but not tested |
| 2 | Some commands mentioned in prose but not standardized |
| 1 | No verification commands defined |

**Drift check:** Run each listed verification command. Do they all exit 0?

---

## Subsystem 3: Environment

| Score | Criteria |
|---|---|
| 5 | `init.sh` exists, passes from scratch, deps locked in lockfile |
| 4 | `init.sh` exists and passes, but deps not locked |
| 3 | `init.sh` exists but has warnings or non-fatal errors |
| 2 | Install instructions exist in README but no `init.sh` |
| 1 | No environment setup documentation |

**Drift check:** Run `bash init.sh` from scratch. Does it pass?

---

## Subsystem 4: State

| Score | Criteria |
|---|---|
| 5 | `PROGRESS.md` updated within last session, `feature_list.json` statuses match reality |
| 4 | `PROGRESS.md` updated, feature statuses partially stale |
| 3 | `PROGRESS.md` exists but >1 week stale |
| 2 | `feature_list.json` exists but statuses haven't changed in weeks |
| 1 | No `PROGRESS.md` or `feature_list.json` |

**Drift check:** Are there features in `feature_list.json` marked `passing` that no longer have working verification commands?

---

## Subsystem 5: Feedback

| Score | Criteria |
|---|---|
| 5 | Unit tests + integration tests + at least one E2E check all defined and passing |
| 4 | Unit tests + integration tests passing, no E2E |
| 3 | Unit tests only, passing |
| 2 | Tests exist but some are failing or flaky |
| 1 | No automated tests |

**Drift check:** Do the test commands in AGENTS.md match what actually exists in the test suite?

---

## Overall Score

`Total / 25 × 100 = Harness Health %`

| Range | Status |
|---|---|
| 90–100% | Healthy — maintain with weekly audits |
| 70–89% | Needs attention — fix lowest subsystem this week |
| 50–69% | At risk — schedule a harness repair session |
| <50% | Critical — agent reliability severely impacted |
