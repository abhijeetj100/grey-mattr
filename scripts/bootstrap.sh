#!/usr/bin/env bash
# One-time setup for a repo created from this template.
# Run from inside the new repo's clone, after pushing to GitHub:
#   bash scripts/bootstrap.sh
#
# Does what GitHub does NOT copy from a template:
#   1. sets the CLAUDE_CODE_OAUTH_TOKEN repo secret
#   2. reminds you to install the Claude GitHub App on the repo
#   3. runs the label sync workflow
set -euo pipefail

command -v gh >/dev/null || { echo "gh CLI not found: https://cli.github.com"; exit 1; }
gh auth status >/dev/null 2>&1 || { echo "Run: gh auth login"; exit 1; }

repo="$(gh repo view --json nameWithOwner -q .nameWithOwner)"
echo "Bootstrapping $repo"

# 1. Secret ----------------------------------------------------------------
if gh secret list --repo "$repo" | grep -q '^CLAUDE_CODE_OAUTH_TOKEN'; then
  echo "[ok] CLAUDE_CODE_OAUTH_TOKEN already set"
else
  token="${CLAUDE_CODE_OAUTH_TOKEN:-}"
  if [ -z "$token" ]; then
    echo "Generate a token with:  claude setup-token"
    read -rsp "Paste CLAUDE_CODE_OAUTH_TOKEN (input hidden): " token
    echo
  fi
  [ -n "$token" ] || { echo "No token given; aborting."; exit 1; }
  printf '%s' "$token" | gh secret set CLAUDE_CODE_OAUTH_TOKEN --repo "$repo"
  echo "[ok] secret set"
fi

# 2. GitHub App (cannot be automated) ---------------------------------------
echo "[todo] Install the Claude GitHub App and grant it access to $repo:"
echo "       https://github.com/apps/claude"

# 3. Labels -----------------------------------------------------------------
if gh workflow run sync-labels.yml --repo "$repo"; then
  echo "[ok] label sync started (see the Actions tab)"
else
  echo "[warn] could not start label sync; run 'Sync labels' from the Actions tab."
fi

echo "Done. Open an issue with the 'Claude task' template to test."
