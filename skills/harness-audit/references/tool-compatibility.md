# Tool Compatibility — harness-audit

## Claude Code

**Trigger:** Type `harness-audit` in the chat window.

Or add to your project's `CLAUDE.md`:
```
When the user says "harness-audit", follow the instructions in skills/harness-audit/SKILL.md
```

- File reading: `Read` tool — no special setup needed
- Running commands: `Bash` tool — shell access must be enabled

---

## Cursor

Add to `.cursorrules`:
```
When the user says "harness-audit", follow the instructions in skills/harness-audit/SKILL.md
```

- File reading: Cursor reads files via file context — ensure the skill directory is in the workspace
- Running commands: Use the Cursor terminal panel

---

## Codex (OpenAI)

Add to `AGENTS.md`:
```
When the user says "harness-audit", follow the instructions in skills/harness-audit/SKILL.md
```

- File reading: Codex reads repository files directly
- Running commands: Codex has shell access in its sandboxed environment

---

## Gemini CLI

Add to `GEMINI.md`:
```
When the user says "harness-audit", follow the instructions in skills/harness-audit/SKILL.md
```

- File reading: Gemini CLI reads files via its file read tool
- Running commands: Use the shell tool or terminal

---

## Universal Fallback (no agent tool required)

Run the bash script directly from your project root:

```bash
bash /path/to/agent-harness-kit/skills/harness-audit/scripts/harness-audit.sh
```

Output is identical to running via an agent tool.
