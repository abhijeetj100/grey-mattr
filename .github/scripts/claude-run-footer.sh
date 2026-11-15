#!/usr/bin/env bash
# Posts a one-line run summary (model, effort, time, tokens, cost) as a comment.
#
# Inputs (env): EXEC_FILE, MODEL, EFFORT, TARGET (issue/PR number), RUN_URL,
#               GH_TOKEN, GITHUB_REPOSITORY
#
# Never write the Claude mention in the comment body: it would re-trigger
# the assistant workflow.
set -uo pipefail

if [ -z "${EXEC_FILE:-}" ] || [ ! -f "$EXEC_FILE" ] || [ -z "${TARGET:-}" ]; then
  echo "No execution file or target; skipping footer."
  exit 0
fi

# The execution file is a JSON array; the last element is the result message.
read -r cost dur_ms in_tok out_tok cache_read < <(
  jq -r '
    . as $all
    | ((map(select(.type == "result")) | last) // $all[-1]) as $r
    | [
        ($r.total_cost_usd // "n/a"),
        ($r.duration_ms // "n/a"),
        ($r.usage.input_tokens // "n/a"),
        ($r.usage.output_tokens // "n/a"),
        ($r.usage.cache_read_input_tokens // 0)
      ] | @tsv' "$EXEC_FILE" 2>/dev/null
) || true

fmt_cost="n/a"
if [[ "${cost:-n/a}" != "n/a" ]]; then
  fmt_cost="$(printf '$%.4f' "$cost")"
fi

fmt_time="n/a"
if [[ "${dur_ms:-n/a}" != "n/a" ]]; then
  secs=$(( dur_ms / 1000 ))
  fmt_time="$(( secs / 60 ))m $(( secs % 60 ))s"
fi

body="Claude run: model \`${MODEL:-unknown}\` | effort \`${EFFORT:-unknown}\` | time ${fmt_time} | tokens ${in_tok:-n/a} in / ${out_tok:-n/a} out (${cache_read:-0} cached) | cost ${fmt_cost} | [run log](${RUN_URL:-})"

gh issue comment "$TARGET" --repo "$GITHUB_REPOSITORY" --body "$body" \
  || echo "Could not post footer comment."
