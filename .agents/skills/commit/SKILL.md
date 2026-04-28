---
name: commit
description: Use when the user invokes $commit or asks to commit, create commits, split commits, stage git changes, or apply the repo commit convention to staged/unstaged/untracked changes. Inspect the worktree, group files/hunks by logical task, stage only intended changes, commit each task with this repository's one-line Korean conventional commit format, and handle unexpected git errors by asking before risky recovery.
---

# Commit Skill

## Goal

Create one or more git commits from the current worktree according to the repo commit convention.

Load `reference/commit-convention.md` when choosing commit types/scopes or validating commit messages.

## Required workflow

1. Inspect state before touching git:
   - `git status --short`
   - `git diff --stat`
   - `git diff --name-only`
   - `git diff --cached --name-only`
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

## Scope selection quick guide

- `apps/<app-name>/<layer>/...` → `<app-name>/<layer>`
- `packages/<layer>/...` or package-owned shared code → `<layer>`
- Anything outside `apps/` and `packages/` → `global`
- If a task spans multiple apps/packages in the same logical product change, prefer separate commits per app/layer when the changes can stand alone.
- Use `global` for intentionally cross-cutting tasks that cannot honestly be assigned to one app/layer, such as repo config, CI, root scripts, or shared migration wiring.
- If one logical task touches an app and a shared package, prefer two commits when separable: one `shared` commit for the package change and one `<app>/<layer>` commit for app adoption.

## Multi-app handling examples

- Chat feature + issue feature changed independently:
  - `feat(cowork-chat/features): 메시지 입력 기능 추가`
  - `feat(cowork-issue/features): 이슈 필터 기능 추가`
- Shared API change plus app adoption:
  - `refactor(shared): 공통 API 응답 타입 정리`
  - `fix(cowork-chat/entities): 채팅 응답 타입 변경 반영`
- Shell routing change affecting multiple MFEs but implemented in shell only:
  - `feat(shell/app): MFE 라우팅 가드 추가`
- Root config enabling all apps:
  - `chore(global): 워크스페이스 빌드 설정 갱신`

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
