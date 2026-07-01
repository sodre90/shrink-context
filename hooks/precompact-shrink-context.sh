#!/bin/bash
# PreCompact hook: one-shot intercept for the shrink-context skill.
#
# matcher "auto":   first auto-compact per session is blocked so Claude can
#                    run the shrink-context skill instead of a blind summarization.
#                    A second consecutive auto-compact (grace already used) is let through.
# matcher "manual":  clears the marker, recharging the grace for next time.
#
# No `set -e`: malformed input must fail safe (let compaction proceed) by
# falling through the empty-session_id check below, not by aborting mid-script.
set -uo pipefail

mode="${1:-}"
input=$(cat)
session_id=$(echo "$input" | jq -r '.session_id // empty' 2>/dev/null)

if [ -z "$session_id" ]; then
  exit 0
fi

marker="${TMPDIR:-/tmp}/claude-shrink-context-${session_id}.marker"

if [ "$mode" = "manual" ]; then
  rm -f "$marker"
  exit 0
fi

if [ -f "$marker" ]; then
  rm -f "$marker"
  exit 0
fi

touch "$marker"
echo "Auto-compact was about to run a blind summarization of this conversation. Invoke the shrink-context skill now so the user can pick what to keep before compacting. (One-shot grace: this will not block again until a compaction actually happens.)" >&2
exit 2
