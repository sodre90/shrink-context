# shrink-context

A Claude Code plugin that lets you pick what to keep before compacting your conversation, instead of letting `/compact` blindly summarize everything.

## What it does

- **`/shrink-context` skill** — analyzes the current conversation, breaks it into topics, and asks you which strategy to use (summarize everything, keep recent and condense the beginning, keep selected topics in detail, or custom instructions). It then hands you the exact `/compact <instructions>` command to run — Claude Code has no tool for triggering compaction programmatically, so you run the final command yourself.
- **`PreCompact` hook** — a one-shot intercept on auto-compaction. The first time Claude Code would auto-compact in a session, this hook blocks it and tells Claude to invoke `/shrink-context` instead. If it fires again before a compaction actually happens, it lets the second one through (no indefinite blocking, so you never hit a hard context-limit error waiting for input). Any manual `/compact` clears the marker, recharging the one-shot grace for later.

## Install

```
claude plugin marketplace add sodre90/shrink-context
claude plugin install shrink-context@shrink-context
```

Restart Claude Code (or run `/hooks` to reload) for the `PreCompact` hook to take effect.

## Requirements

- `jq` (used by the hook script to read the session ID from stdin)

## How the one-shot intercept works

The hook script (`hooks/precompact-shrink-context.sh`) tracks a per-session marker file in `$TMPDIR`:

- `PreCompact` with matcher `auto`: if no marker exists, create one and block (exit 2) with a reason telling Claude to run `/shrink-context`. If a marker already exists (grace already used), delete it and let auto-compact through normally.
- `PreCompact` with matcher `manual`: always clears the marker, so the grace recharges after any real compaction.

## License

MIT
