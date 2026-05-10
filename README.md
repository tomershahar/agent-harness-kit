# agent-harness-kit

Your agent forgets context between sessions, re-derives the same answers, and onboards new developers from scratch every time. This kit fixes that with four skills that take any repo from zero to a fully instrumented agent harness.

## What is a Harness?

A harness is everything in your repo that determines how reliably an AI agent can work in it — the files, scripts, and conventions that turn a capable model into a productive collaborator. Five subsystems: **Instructions, Tools, Environment, State, Feedback**. → [full explainer](docs/five-subsystems.md)

## The Four Skills

| Skill | What it does |
|---|---|
| [`harness-init`](skills/harness-init/) | Reads your repo, detects gaps, generates a complete harness in one pass |
| [`harness-audit`](skills/harness-audit/) | Scores 5 subsystems, gives a prioritized fix list — runs in seconds |
| [`harness-handoff`](skills/harness-handoff/) | Scans commit messages for decisions and tracked files for blockers, writes a session handoff |
| [`harness-onboard`](skills/harness-onboard/) | Orients a new developer or agent to the harness in under 5 minutes |

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
for skill in init audit handoff onboard; do
  ln -sf "$PWD/skills/harness-$skill/scripts/harness-$skill.sh" ~/.local/bin/harness-$skill
done
```

Then from any project root:

```bash
harness-init --yes  # auto-detects stack, no prompts — recommended default
harness-audit       # weekly health check
harness-handoff     # end of every session
harness-onboard     # when a new developer joins
```

Running in a real terminal and want to confirm the detected values? Use `harness-init` without `--yes` for an interactive walkthrough.

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
# 91 tests: unit + integration per skill + full 4-skill E2E chain
```

## Resources

- [Five Subsystems Explained](docs/five-subsystems.md) — shareable one-pager for team onboarding
- [Architecture](ARCHITECTURE.md) — skill structure and file responsibilities
- [Course Reference](docs/course-reference.md) — maps every design decision to a lecture

## Credits

Built on the foundations of the **[Learn Harness Engineering](https://github.com/walkinglabs/learn-harness-engineering)** course by Walking Labs.

## License

MIT
