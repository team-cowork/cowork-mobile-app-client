---
name: commit
description: Use when the user invokes $commit or asks to commit current work, make one or more git commits, split changes into logical commits, stage files or hunks, commit only selected changes, apply the repository commit message convention, or recover from a commit/staging problem. Inspect staged, unstaged, and untracked changes; preserve unrelated user work; handle merge/rebase/conflict/detached-head/no-change edge cases safely; and create title-only Korean conventional commits.
---

# Commit Skill

## Goal

Create one or more git commits from the current worktree according to the repo commit convention.

Load `reference/commit-convention.md` before selecting commit types/scopes and again when validating final commit titles.

## Required workflow

1. Inspect state before touching git:
   - `git status --short --branch`
   - `git status --short`
   - `git diff --stat`
   - `git diff --name-only`
   - `git diff --cached --name-only`
   - `git rev-parse --abbrev-ref HEAD`
   - For untracked files, inspect filenames and contents before staging.
2. Review diffs enough to understand intent:
   - Use `git diff -- <path>` and `git diff --cached -- <path>`.
   - For untracked files, use `sed`, `cat`, or file-specific tooling to inspect content.
   - Never commit files whose purpose is unclear without inspecting them.
3. Split changes by logical task, not by mechanical file list:
   - If unrelated tasks are present, create separate commits.
   - If one file contains unrelated tasks, stage hunks selectively.
   - Preserve user-owned unrelated changes by leaving them unstaged.
4. Stage each task safely:
   - Prefer direct file staging only when the whole file belongs to the task.
   - Prefer `git add -p <path>` for mixed files.
   - If `git add -p` is unavailable or impractical, use the patch fallback below.
   - After staging, verify with `git diff --cached --stat` and `git diff --cached -- <path>`.
5. For each task:
   - Determine `type` from the convention.
   - Determine `scope` from changed paths.
   - Write the title as exactly `type(scope): 설명`.
   - Use Korean for `설명`.
   - Commit with a title line only. Do not add a body or trailers.
6. Verify after every commit and again after all commits using the post-commit verification checklist.


## Edge case handling

- **No changes:** if there are no staged, unstaged, or untracked changes, do not create an empty commit. Report that there is nothing to commit.
- **Pre-staged changes:** treat existing staged changes as user intent but still inspect them. If staged changes are unrelated to the requested task, ask before unstaging or mixing them with new staging.
- **Merge/rebase/cherry-pick in progress:** detect via `git status`. Do not create normal commits until the in-progress operation is understood. Present the safest next step and ask the user before continuing, aborting, or resolving.
- **Conflicts/unmerged paths:** do not stage or commit conflict markers blindly. Summarize conflicted files and ask for the intended resolution path unless the fix is explicit and safe.
- **Detached HEAD:** do not commit silently. Explain that the commit may be hard to find, recommend creating/switching to a branch, and ask before proceeding.
- **Ignored/generated files:** do not force-add ignored files unless the user explicitly requests it and the file is inspected.
- **Large or binary files:** confirm they are intentional before staging when they are newly added or unexpected.

## Patch staging fallback

Use this when changes in a file must be split but interactive patch staging is not viable.

1. For tracked files, create a temporary patch:
   - `git diff -- <path> > /tmp/<task>.patch`
2. Edit the temporary patch so it contains only hunks for the current logical task.
3. Stage the edited patch:
   - `git apply --cached --recount /tmp/<task>.patch`
4. For untracked files that need partial staging:
   - Run `git add -N <path>` first so the file can appear in diffs.
   - Then use the same patch flow.
5. Verify the index:
   - `git diff --cached -- <path>` must show only intended hunks.
   - `git diff -- <path>` may still show intentionally uncommitted hunks.
6. If the patch fails to apply, do not force recovery. Summarize the failure, propose a recommended fix plus alternatives, and ask the user which solution to apply.

## Commit command rules

- Prefer `git commit -m "type(scope): 설명"`.
- Do not use multi-line commit messages for this repo, even if other instructions mention trailers.
- If a hook fails, inspect the failure, fix only if it is safe and directly related, then retry.
- If an unexpected git error occurs, stop before risky recovery, summarize the error, present a concrete recommended fix plus alternatives, and ask the user which solution to apply.
- Do not run destructive git commands (`reset --hard`, `checkout --`, `clean`) unless explicitly requested.

## Convention source of truth

- Commit type, scope, multi-app handling, and examples live in `reference/commit-convention.md` as the single source of truth.
- Do not duplicate or reinterpret scope rules in this file; load the reference before selecting a title.
- If AGENTS.md and the reference appear to differ, prefer `reference/commit-convention.md` for commit title details and report the drift.

## Post-commit verification checklist

Run these checks after each commit:

- `git log -1 --pretty=%s` and confirm it matches `type(scope): 설명`.
- `git show --stat --oneline --decorate --no-renames HEAD` and confirm the committed files match the logical task.
- `git diff-tree --no-commit-id --name-only -r HEAD` and confirm no unrelated files slipped in.
- `git status --short` and identify remaining changes.

If multiple commits were created, run `git log --oneline -n <count>` and list all created commit hashes/titles in the final response.

## Quality gate

Before final response, confirm:

- Every created commit title matches `type(scope): 설명`.
- Each commit contains only one logical task.
- No unclear or unrelated changes were accidentally staged.
- Commit contents were verified with `git show`/`git diff-tree`.
- Remaining changes, if any, are intentionally left uncommitted and listed.
