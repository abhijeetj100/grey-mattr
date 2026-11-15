# Code review (`claude-code-review.yml`)

Claude reviews a PR only when asked, by label. It does **not** run on every
push, which saves tokens and avoids noisy comments. Adding labels requires
triage/write access, so only maintainers can trigger it.

## Labels

| Label | Who sets it | Meaning |
|---|---|---|
| `claude-review-requested` | You | Starts a review. Removed by the workflow when it finishes. |
| `claude-review-completed` | Workflow | Review succeeded. |
| `claude-review-failed` | Workflow | Review failed; check the run logs. |
| `claude-model:sonnet` / `opus` / `haiku` | You (optional) | Model to use. |
| `claude-effort:low` / `medium` / `high` / `xhigh` / `max` | You (optional) | Effort to use. |

Defaults when no model or effort label is present: Sonnet 5.5, medium.

The model and effort labels are left on the PR after the review, so a
re-review reuses them. Change or remove them whenever you want something
different.

## Requesting a review

Add the model and effort labels **first**, then add `claude-review-requested`
**last**. Only the request label starts a run, and the workflow reads all
labels at that moment.

### Examples

Default review (Sonnet 5.5, medium):
```text
add label: claude-review-requested
```

Deep review with Opus:
```text
add labels: claude-model:opus, claude-effort:high
then add:   claude-review-requested
```

Quick cheap pass:
```text
add labels: claude-model:haiku, claude-effort:low
then add:   claude-review-requested
```

With the CLI:
```sh
gh pr edit 12 --add-label claude-model:opus --add-label claude-effort:high
gh pr edit 12 --add-label claude-review-requested
```

## Re-reviewing after new commits

Add `claude-review-requested` again. The workflow clears the old
`claude-review-completed` / `claude-review-failed` label at the start of the
run, so the PR always shows the latest result.

## Conflicting or unknown labels

If a PR has two `claude-model:*` labels, two `claude-effort:*` labels, or an
unknown value, the workflow falls back to the default for that setting and
posts a PR comment explaining what it used.

## Lifecycle

```text
label added: claude-review-requested
  -> resolve model/effort from labels (+ comment if conflicts)
  -> clear stale completed/failed labels
  -> run /code-review:code-review --comment (inline PR comments)
  -> always: remove claude-review-requested,
             add claude-review-completed or claude-review-failed
```

The final label step uses `if: always()`, so the request label never gets
stuck after a failure.

## Permissions and concurrency

- `contents: read`, `pull-requests: write`, `issues: write`, `id-token: write`
  (write access is needed to edit labels and post the notice comment).
- A per-PR concurrency group (`claude-review-<PR number>`) prevents duplicate
  runs. Later runs queue instead of cancelling.

## Changing the mapping

Edit the `Resolve model and effort from labels` step in
`.github/workflows/claude-code-review.yml`: the `jq` filters hold the label
prefixes, and the `case` blocks hold the allowed values and pinned model IDs.
See [README.md](README.md) for the table.
