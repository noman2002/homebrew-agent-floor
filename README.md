# Agent Floor

A local pixel office for your Claude Code sessions. Every session shows up as an avatar on its project's floor, and one **Needs you** queue collects what's waiting on you: permission requests, questions, finished turns and stuck agents. You can answer from the browser, your phone, or the terminal, whichever is first.

Runs entirely on your Mac. No account, no cloud server.

## Install (macOS, Homebrew)
```bash
brew install noman2002/agent-floor/agent-floor
```
If Homebrew asks you to trust the tap: `brew trust noman2002/agent-floor`, then run the install again.
Needs Node.js 22.5 or newer on the machine (`brew install node`, fnm, nvm or volta all work).

## Use
```bash
agent-floor start --open     # first run: opens your browser already paired
agent-floor sandbox          # optional: two throwaway repos to try it safely
```
To see your sessions on the floor, connect Claude Code **once** with one of these:
- `agent-floor install-hooks` (adds hooks to `~/.claude/settings.json`, keeps a backup; undo with `agent-floor uninstall-hooks`), or
- the plugin: in Claude Code, `/plugin marketplace add $(brew --prefix)/opt/agent-floor/libexec/plugin-marketplace`, then `/plugin install agent-floor@agent-floor`.

Start at login: `brew services start agent-floor`. Health check: `agent-floor doctor`.

## Teams (optional)
In the **Plans** tab, give a project's CTO agent a goal. It writes a plan, you approve it, and dev agents work in sandboxed git worktrees on `af/*` branches. A QA agent then verifies each task. Nothing is ever pushed or merged for you. Launched agents use your own Claude Code login.

## Privacy and safety
- Everything stays on your machine. History is kept 30 days in `~/.agent-floor` with secrets redacted.
- Browsers and phones pair with one-time codes. Agents can't approve their own commands.
- If Agent Floor isn't running, Claude Code works normally. Hooks fail silently and add about 11ms.
- Phone access away from home: install Tailscale, then `agent-floor start --tailscale`.

## Uninstall
```bash
agent-floor uninstall-hooks
brew services stop agent-floor; brew uninstall agent-floor; brew untap noman2002/agent-floor
rm -rf ~/.agent-floor
```

Copyright (c) 2026 noman2002. All rights reserved. Free to install and use; source is not public.
