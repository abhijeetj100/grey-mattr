# Claude GitHub workflows

Two GitHub Actions workflows run Claude Code on this repo. Both use
`anthropics/claude-code-action@v1` and authenticate with the
`CLAUDE_CODE_OAUTH_TOKEN` repo secret.

| Workflow | File | Trigger | Details |
|---|---|---|---|
| Claude Code (`@claude` assistant) | `.github/workflows/claude.yml` | `@claude` in an issue, comment or review | [assistant.md](assistant.md) |
| Claude Code Review | `.github/workflows/claude-code-review.yml` | Adding the `claude-review-requested` label to a PR | [code-review.md](code-review.md) |

## Defaults

- Model: **Sonnet 5.5** (`claude-sonnet-5-5`)
- Effort: **medium**
- Both can be overridden per request (see the two docs above).

## Model and effort values

| Option | Allowed values |
|---|---|
| Model | `sonnet`, `opus`, `haiku` |
| Effort | `low`, `medium`, `high`, `xhigh`, `max` |

Anything else is ignored and the default is used.

### Pinned model IDs

Short names map to explicit model IDs, so a new model release never changes
cost silently. Upgrading is a deliberate edit.

| Name | Model ID |
|---|---|
| `sonnet` | `claude-sonnet-5-5` |
| `opus` | `claude-opus-5-5` |
| `haiku` | `claude-haiku-5-5` |

The table lives in the `Resolve model and effort` step of **both** workflow
files (the `case "$model_key" in` block). Edit both to keep them in sync.

## Memory and context

Every run is a fresh job. Nothing is remembered between runs. Claude sees the
issue/PR description, the comment thread (including its own earlier replies),
the diff, `CLAUDE.md`, and anything it previously pushed. It does not keep its
earlier reasoning. Write important decisions into a comment or `CLAUDE.md`.

## One-time setup

- Repo secret `CLAUDE_CODE_OAUTH_TOKEN` must exist (Settings -> Secrets).
- Labels used by the review workflow are defined in `.github/labels.yml` and
  synced to GitHub by `.github/workflows/sync-labels.yml`. It runs when that
  file changes on `master`; run it once manually (Actions tab -> Sync labels
  -> Run workflow) in a new repo. Edit the file to add or change labels.

## Known caveats

- The action may refuse to run while a workflow file on the PR differs from
  the default branch. Merge workflow changes first, then test.
- Passing `--effort` through `claude_args` is not documented by the action;
  it works only if the installed Claude Code version accepts the flag. Check
  the first run's logs.

## Run summary comment

After every Claude run, a follow-up comment is posted on the issue or PR with
one line like:

```text
Claude run: model `claude-sonnet-5-5` | effort `medium` | time 1m 23s | tokens 1200 in / 340 out (5000 cached) | cost $0.1234 | run log
```

- Posted by `.github/scripts/claude-run-footer.sh` from the `Post run summary`
  step in both workflows. It reads time, tokens and cost from the action's
  execution file. Model and effort are the values the workflow requested.
- It is a separate comment, not appended to Claude's own reply.
- The comment must never contain the Claude mention, or it would re-trigger
  the assistant workflow.
- If a field is missing from the execution file it shows `n/a`.
