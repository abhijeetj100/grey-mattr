## Summary

<!-- What does this PR change and why? Link the issue: Closes #123 -->

## Changes

-

## Testing

<!-- How did you verify this? Commands run, screenshots, etc. -->

## Requesting a Claude review (optional)

Reviews never run automatically. To request one, add labels to this PR
**in this order** (see `docs/claude/code-review.md`):

1. Optional model label: `claude-model:sonnet` | `claude-model:opus` | `claude-model:haiku`
2. Optional effort label: `claude-effort:low` | `claude-effort:medium` | `claude-effort:high` | `claude-effort:xhigh` | `claude-effort:max`
3. Then the trigger label: `claude-review-requested`

No model/effort label means Sonnet 5.5 at medium. When the review finishes the
trigger label is replaced by `claude-review-completed` (or `claude-review-failed`).

Quick CLI version:

```sh
gh pr edit <number> --add-label claude-model:opus --add-label claude-effort:high
gh pr edit <number> --add-label claude-review-requested
```
