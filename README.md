# agent-harness-kit

Three agent skills that help teams set up, maintain, and hand off AI agent harnesses.
Works with Claude Code, Cursor, Codex, and Gemini CLI — or run the bash scripts directly.

---

> Built on the foundations of the **[Learn Harness Engineering](https://github.com/walkinglabs/learn-harness-engineering)** course by Walking Labs.
> Every design decision in these skills maps back to a specific lecture in that course.
> See [`docs/course-reference.md`](docs/course-reference.md) for the full map.

---

## The Four Skills

| Skill | What it does | When to run |
|---|---|---|
| [`harness-init`](skills/harness-init/) | Reads your repo and generates a complete harness from scratch | Once, when starting a new project or joining one with no harness |
| [`harness-audit`](skills/harness-audit/) | Scores your harness across 5 subsystems and gives a prioritized fix list | Weekly, or before a big session |
| [`harness-handoff`](skills/harness-handoff/) | Auto-generates session-handoff.md and updates PROGRESS.md at session end | At the end of every working session |
| [`harness-onboard`](skills/harness-onboard/) | Orients a new team member to the harness in under 5 minutes | Once, when a new developer joins the project |

## Quick Start

### Option A: Use with your agent tool

Copy the skill directory you need into your project:

```bash
# Example: add harness-init to your project
cp -r skills/harness-init/ /your/project/skills/harness-init/
```

Then trigger it:
- **Claude Code**: type `harness-init` in chat
- **Cursor**: add `trigger: harness-init` to `.cursorrules`
- **Codex**: add `trigger: harness-init` to `AGENTS.md`
- **Gemini CLI**: add `trigger: harness-init` to `GEMINI.md`

### Option B: Run the bash script directly

No agent tool required:

```bash
# From your project root:
bash /path/to/agent-harness-kit/skills/harness-init/scripts/harness-init.sh
bash /path/to/agent-harness-kit/skills/harness-audit/scripts/harness-audit.sh
bash /path/to/agent-harness-kit/skills/harness-handoff/scripts/harness-handoff.sh
```

## What is a Harness?

A harness is everything in your engineering infrastructure outside the model weights — the files, scripts, and conventions that determine how much of the model's capability actually gets realized.

A complete harness has five subsystems:
1. **Instructions** — AGENTS.md, CLAUDE.md, docs hierarchy
2. **Tools** — verification commands, test runners
3. **Environment** — init.sh, locked dependencies
4. **State** — PROGRESS.md, feature_list.json
5. **Feedback** — test results, lint output, E2E checks

These skills help you build and maintain all five.

## Resources

- [Five Subsystems Explained](docs/five-subsystems.md) — one-pager for team adoption

## License

MIT
