# `@claude` assistant (`claude.yml`)

## When it runs

When `@claude` appears in:

- an issue comment
- a PR review comment
- a submitted PR review
- the title or body of a newly opened or assigned issue

Otherwise the job is skipped. By default the action only responds to users
with write access to the repo.

## Choosing model and effort

Put tags anywhere in the text, case-insensitive:

- `[model:sonnet]`, `[model:opus]`, `[model:haiku]`
- `[effort:low]`, `[effort:medium]`, `[effort:high]`, `[effort:xhigh]`, `[effort:max]`

No tag means Sonnet 5.5 at medium. An unknown value (for example
`[model:gpt]`) is ignored and the default is used. If a tag appears more than
once, the first one wins.

### Examples

```text
@claude fix the login bug in src/auth.ts
```
Sonnet 5.5, medium.

```text
@claude [model:opus] [effort:high] refactor the payment module
```
Opus 5.5, high.

```text
@claude [effort:low] what does this function do?
```
Sonnet 5.5, low.

```text
@claude [model:haiku] [effort:low] add a missing docstring
```
Haiku 5.5, low.

```text
@claude [model:gpt] [effort:turbo] fix it
```
Both values invalid, so Sonnet 5.5, medium.

## How it works

The `Resolve model and effort` step:

1. Reads the triggering text from the event (comment, review, or issue
   title and body) through `env:` variables. Untrusted text is never
   interpolated into the shell script.
2. Lowercases it and matches `[model:x]` and `[effort:y]` with a regex.
3. Accepts only allowlisted values, then maps the model name to a pinned ID.
4. Writes `model` and `effort` to step outputs, which feed
   `claude_args: '--model <id> --effort <level>'`.

The tags stay in the comment text Claude reads. That is harmless.

## Changing the mapping

Edit the `case` blocks in the `Resolve model and effort` step of
`.github/workflows/claude.yml`. See [README.md](README.md) for the table.
