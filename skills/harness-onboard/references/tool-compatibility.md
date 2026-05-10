# tool-compatibility — harness-onboard

harness-onboard is a read-only bash script. It works in any environment where bash and python3 are available.

## Claude Code

Run `harness-onboard` (if installed globally via symlink) or `bash /path/to/harness-onboard.sh` from the project root. The output appears in your terminal and can be pasted into a Claude Code session.

## Cursor

Run in Cursor's integrated terminal. Copy the output into a Cursor chat message to give the AI full project context before starting work.

## Codex (OpenAI)

Include the onboard output in your Codex task prompt as "Project context:" at the top.

## Gemini CLI

Run before starting a Gemini session. Paste the output into the context window.

## GitHub Copilot (VS Code / JetBrains / CLI)

Run in VS Code terminal. Paste the output into Copilot Chat to orient it to the project. Alternatively, add key sections to `.github/copilot-instructions.md`.

**Limitation:** `feature_list.json` parsing requires `python3`. If unavailable, open the file manually.
