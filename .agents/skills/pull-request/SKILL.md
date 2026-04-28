---
name: pull-request
description: Create or prepare a pull request after work, commits, and validation are complete. Use when the current branch is ready for PR, all changes are committed, validation succeeded, and a PR title/body/creation is requested; block PR creation if uncommitted changes remain.
---

# Pull Request

Use this skill only after work is complete, committed, and validated.

## Preconditions

- Current branch is a work branch, not `develop`.
- All intended changes are committed.
- Validation succeeded or any missing checks are clearly documented.
- There are no uncommitted changes.

## Workflow

1. Inspect branch and cleanliness:
   - `git branch --show-current`
   - `git status --short`
2. Compare against base branch (`develop` unless instructed otherwise):
   - `git log --oneline develop..HEAD`
   - `git diff --stat develop...HEAD`
3. Read `.github/PULL_REQUEST_TEMPLATE.md` if present.
4. Draft a Korean PR title from the issue/work summary.
5. Fill the PR body with changes and test evidence; do not invent issue numbers, screenshots, or tests.
6. Link the issue when known.
7. Create the PR with the available project tool or `gh pr create` only when all preconditions hold.

## Output

```yaml
pr_url: "<created PR URL or empty if only drafted>"
summary: "<PR title and key changes>"
```

## Constraints

- Do not create a PR with uncommitted changes.
- Do not create a PR after failed validation.
- Do not include unrelated uncommitted work in the PR description.
