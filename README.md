# agent-harness-kit

Your agent forgets context between sessions, re-derives the same answers, and onboards new developers from scratch every time. This kit fixes that with four skills that take any repo from zero to a fully instrumented agent harness.

## What is a Harness?

A harness is everything in your repo that determines how reliably an AI agent can work in it — the files, scripts, and conventions that turn a capable model into a productive collaborator. Five subsystems: **Instructions, Tools, Environment, State, Feedback**. → [full explainer](docs/five-subsystems.md)

## The Four Skills

| Skill | What it does | Time |
|---|---|---|
| [`harness-init`](skills/harness-init/) | Reads your repo, detects gaps, generates a complete harness in one pass | ~2 min |
| [`harness-audit`](skills/harness-audit/) | Scores 5 subsystems in under 30 seconds, gives a prioritized fix list | ~30 sec |
| [`harness-handoff`](skills/harness-handoff/) | Auto-extracts decisions and blockers from git, writes a session handoff | ~10 sec |
| [`harness-onboard`](skills/harness-onboard/) | Orients a new developer to the harness in under 5 minutes | ~5 min |

## See it in action

Run `harness-audit` on any project that has been initialized:

```
## Harness Audit Report — 2026-05-10

### Scores
| Subsystem      | Score | Key finding
|---|---|---
| Instructions   | 5/5   | AGENTS.md is 46 lines — healthy
| Tools          | 5/5   | Verification commands found and confirmed passing
| Environment    | 3/5   | init.sh exists but has errors
| State          | 5/5   | Both state files present and current
| Feedback       | 1/5   | No test files detected
| **Total**      | 19/25 | 76% health

### Priority Fix List
1. [Environment] Fix init.sh errors
2. [Feedback] CRITICAL: No tests — agents will declare victory too early

Status: NEEDS ATTENTION — fix lowest subsystem this week
```

Fix the lowest subsystem. Re-run. Watch the score move.

## Quick Start

**Recommended for teams: install globally** and use across all your repos.

```bash
git clone https://github.com/tomershahar/agent-harness-kit
cd agent-harness-kit
ln -sf "$PWD/skills/harness-init/scripts/harness-init.sh"    ~/.local/bin/harness-init
ln -sf "$PWD/skills/harness-audit/scripts/harness-audit.sh"  ~/.local/bin/harness-audit
ln -sf "$PWD/skills/harness-handoff/scripts/harness-handoff.sh" ~/.local/bin/harness-handoff
ln -sf "$PWD/skills/harness-onboard/scripts/harness-onboard.sh" ~/.local/bin/harness-onboard
```

Then from any project root:

```bash
harness-init      # first time setup
harness-audit     # weekly health check
harness-handoff   # end of every session
harness-onboard   # when a new developer joins
```

**Only need it once?** Run the bash scripts directly without installing:

```bash
bash /path/to/agent-harness-kit/skills/harness-init/scripts/harness-init.sh
```

**Using an agent tool?** Copy the skill into your project and trigger it by name (Claude Code, Cursor, Codex, Gemini CLI, GitHub Copilot — all supported).

## What you get after `harness-init`

```
your-project/
├── AGENTS.md          # project overview, run commands, hard constraints
├── ARCHITECTURE.md    # layer diagram and invariants (fill in)
├── feature_list.json  # feature tracker with status and verification commands
├── init.sh            # one-command environment setup
└── PROGRESS.md        # session log — what's done, what's next, decisions made
```

Any gaps detected in your repo (missing test runner, no entry point, etc.) are embedded as `# HARNESS-GAP:` comments so you see exactly what needs fixing.

## Testing

```bash
bash tests/run-all.sh
# 90 tests: unit + integration per skill + full 4-skill E2E chain
```

## Resources

- [Five Subsystems Explained](docs/five-subsystems.md) — shareable one-pager for team onboarding
- [Architecture](ARCHITECTURE.md) — skill structure and file responsibilities
- [Course Reference](docs/course-reference.md) — maps every design decision to a lecture

## Credits

Built on the foundations of the **[Learn Harness Engineering](https://github.com/walkinglabs/learn-harness-engineering)** course by Walking Labs.

## License

MIT
