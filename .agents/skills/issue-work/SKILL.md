---
name: issue-work
description: Use when the user invokes $issue-work or asks to start work from an issue, create an issue branch, parse an issue, prepare a branch from develop, or begin implementation from an issue description. Inspect the issue/request, choose a branch type and kebab-case description, ensure work branches are created from develop without working directly on develop, and hand off to implementation, $commit, and $pr when requested.
---

# Issue Work Skill

## Goal

Turn an issue number or issue description into a safe work branch created from `develop`, then summarize the intended work.

Load `reference/branch-convention.md` before choosing or validating a branch name.

## Required workflow

1. Inspect current git state before branch operations:
   - `git status --short --branch`
   - `git branch --show-current`
   - `git remote -v`
2. Protect user work:
   - If there are uncommitted changes, do not switch branches silently.
   - If changes are unrelated or unclear, summarize them and ask whether to commit/stash/continue from the current branch.
   - Do not run destructive commands.
3. Understand the issue/request:
   - If the user gave an issue number and GitHub CLI is available, inspect it with `gh issue view <number>` when network/auth allow it.
   - If `gh` is unavailable or blocked, use the issue text provided by the user.
   - Extract task type, short English kebab-case summary, likely scope, and acceptance criteria.
4. Choose branch name:
   - Format: `<type>/<kebab-case-description>`.
   - Use branch types from `reference/branch-convention.md`.
   - Use `cicd` for CI/CD branches, not `ci/cd`.
   - Prefer concise English kebab-case descriptions.
5. Create branch from `develop`:
   - Fetch `origin/develop` when network is available and safe.
   - Create the work branch from `origin/develop` when available; otherwise local `develop`.
   - Never work directly on `develop` and never push directly to `develop`.
6. Report result:
   - Current branch name.
   - Base used (`origin/develop` or local `develop`).
   - Issue summary and planned work.
   - Any blockers or unverified assumptions.

## Branch creation commands

Preferred flow when there are no blocking local changes:

```bash
git fetch origin develop
git switch -c <type>/<kebab-case-description> origin/develop
```

Fallback when `origin/develop` is unavailable but local `develop` exists:

```bash
git switch develop
git switch -c <type>/<kebab-case-description>
```

If the target branch already exists:

- Do not overwrite it.
- Inspect `git branch --list <branch>` and `git status --short --branch`.
- Recommend either switching to the existing branch or creating a suffixed branch name such as `<branch>-2`, then ask the user which to use.

## Type selection guide

- `feat`: new feature or user-visible capability.
- `fix`: bug fix.
- `refactor`: behavior-preserving code restructuring.
- `docs`: documentation-only work.
- `style`: formatting/style-only work.
- `test`: test-only work.
- `chore`: maintenance/config/tooling work.
- `perf`: performance improvement.
- `cicd`: CI/CD pipeline work.

## Safety rules

- Do not create commits as part of this skill unless the user explicitly asks to commit.
- Do not push branches unless the user explicitly asks to push.
- Do not create a branch from `main` unless the user explicitly overrides the repo rule.
- If git fetch/switch fails unexpectedly, stop before risky recovery, summarize the error, propose a recommended fix plus alternatives, and ask the user which solution to apply.

## Handoffs

- After implementation, use `$commit` to split and commit work by logical task.
- After commits are ready, use `$pr` to draft a PR targeting `develop`.
- If the user asks for issue-to-PR completion, run this skill first, then implementation, then `$commit`, then `$pr`.

## Quality gate

Before final response, confirm:

- The branch name matches `<type>/<kebab-case-description>`.
- The branch type is one of the allowed branch types.
- The branch was created from `develop`/`origin/develop`, not `main`.
- The agent is not on `develop` after branch creation.
- Uncommitted pre-existing work was not lost or silently carried across.
