# Before / After Example

This shows the same Node.js project before and after running `harness-init`.

## The Cold-Start Test

A new agent session should be able to answer 5 questions using only repo contents:

| Question | Before | After |
|---|---|---|
| What is this system? | ⚠️ Partial (README exists) | ✅ AGENTS.md + README |
| How is it organized? | ❌ No architecture doc | ✅ ARCHITECTURE.md |
| How do I run it? | ⚠️ README mentions it | ✅ init.sh + AGENTS.md |
| How do I verify it works? | ❌ No verification commands | ✅ feature_list.json + AGENTS.md |
| Where are we now? | ❌ No progress tracking | ✅ PROGRESS.md + feature_list.json |

## Try It

```bash
# From the repo root, run harness-init on the before/ example:
cd examples/before-after/before
bash ../../../skills/harness-init/scripts/harness-init.sh
```

Watch harness-init generate the same files that already exist in `after/`.

## Files Added by harness-init

| File | Harness subsystem | What it provides |
|---|---|---|
| `AGENTS.md` | Instructions | Project overview, run commands, hard constraints |
| `ARCHITECTURE.md` | Instructions | Layer structure, data flow, storage layout |
| `feature_list.json` | State | Machine-readable feature tracker with verification commands |
| `init.sh` | Environment | Automated environment verification |
| `PROGRESS.md` | State | Session continuity log |

Based on: [Learn Harness Engineering](https://github.com/walkinglabs/learn-harness-engineering) by Walking Labs
