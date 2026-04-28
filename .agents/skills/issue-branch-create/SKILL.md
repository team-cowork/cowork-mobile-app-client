---
name: issue-branch-create
description: Create and prepare a new issue-backed work branch before starting a task. Use when a user starts a new task, asks to create an issue/branch, or there is no existing issue or work branch. Confirm the work purpose and obtain explicit user confirmation before creating any issue; then create a branch following the repo branch naming rules.
---

# Issue & Branch Create

Use this skill before starting new work when no suitable issue or work branch exists.

## Preconditions

- Confirm the user provided a clear work purpose.
- Inspect current git state and branch.
- Ensure there is no active work branch for the same task.
- Do not create an issue unless the user explicitly confirms the issue title/body.

## Workflow

1. Ask for the work purpose if it is missing or ambiguous.
2. Check branch/status:
   - `git branch --show-current`
   - `git status --short`
3. Draft an issue title and description from the work purpose.
4. Ask the user to confirm issue creation with the drafted content.
5. After confirmation, create the issue using the available project tool or `gh issue create`.
6. Create a branch from `develop` or `origin/develop` using `<type>/<kebab-case-description>`.
7. Report `issue_id`, `branch_name`, and a short summary.

## Constraints

- Never create an issue without user confirmation.
- Do not work directly on `develop`.
- Do not overwrite or discard uncommitted user changes.
- If branch creation requires fetching/updating remotes and network is unavailable, stop with the exact blocker and a safe next step.

## Output

```yaml
issue_id: "<issue number or URL>"
branch_name: "<type>/<kebab-case-description>"
summary: "<what was prepared>"
```
