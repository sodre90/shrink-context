---
name: shrink-context
description: Use when the user wants to reduce or shrink the conversation's context before it grows too large — triggered by /shrink-context, phrases like "shrink the context", "compact this conversation", "drop the beginning of the context", or when a PreCompact hook has just blocked auto-compaction and handed back a reason instructing you to run this skill.
---

# Shrink Context

## Overview

Claude Code's `/compact` command does the actual context reduction; it's a client-side command with no equivalent tool, so it cannot be invoked programmatically. This skill's job is to analyze the conversation, negotiate what to keep with the user, and hand back the exact `/compact <instructions>` command for the user to run.

## When to Use

- User runs `/shrink-context` or asks to shrink/compact the conversation, drop the beginning, summarize everything, etc.
- A PreCompact hook blocked auto-compaction and fed back a reason instructing you to run this skill — treat that reason as the trigger. Tell the user auto-compact was about to run a blind summarization and this is a chance to pick what stays, then run the flow below.

## Process

1. **Identify topics.** Scan the conversation so far and break it into distinct topics/threads. For each: a short label, one-line description, rough position (early/mid/recent), and rough share of the conversation.
2. **Show the breakdown.** Present the topic list as plain numbered text — topic count varies, so don't force it into a fixed-choice question.
3. **Ask for a strategy** (multiple-choice):
   - Summarize everything — one concise recap, no topic favoritism
   - Keep recent, condense the beginning — time-based
   - Keep selected topics in detail, summarize or drop the rest — topic-based
   - Custom instructions — user types free text
4. **If topic-based**, follow up: which topic numbers to keep verbatim, and whether the rest gets summarized to a one-liner or dropped entirely.
5. **Compose the `/compact` command.** Always append an instruction to preserve open TODOs, unresolved questions, and file paths/edits made so far, regardless of strategy — losing these defeats the point of a guided compact.
6. **Hand it off.** Show the user the exact command. Do not attempt to run it yourself.

## Example composed command

```
/compact Keep full detail on: CDP-CCF gap analysis, PreCompact hook design. Summarize briefly: skill-directory exploration. Drop: unrelated scratch-file listing. Always preserve: open TODOs, unresolved questions, and file paths/edits made so far.
```

## Common mistakes

- Forcing the topic list into a 4-option AskUserQuestion — topic count is variable, use plain numbered text instead.
- Dropping the preserve-clause (TODOs/file paths/open questions) when composing the command — always include it.
- Trying to invoke `/compact` directly — there is no tool for it; the user must run the command themselves.
