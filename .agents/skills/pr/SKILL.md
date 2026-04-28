---
name: pr
description: Use when the user invokes $pr or asks to create, write, draft, update, review, or prepare a pull request title/body/description from the current branch. Inspect branch/base status, commits, diffs, PR template, and uncommitted work; coordinate with $commit when changes should be committed first; then produce a copy-ready Korean PR title and template-shaped body without inventing issue numbers, tests, or screenshots.
---

# PR Skill

## Goal

Draft a pull request description from the current branch state using this repository's PR template.

Load `reference/pr-template.md` immediately after branch/base inspection, before drafting any PR body, and reload/check it when validating required sections. If `.github/PULL_REQUEST_TEMPLATE.md` exists, compare against it and prefer the live repository template when it differs.

## Required workflow

1. Inspect branch context:
   - `git branch --show-current`
   - `git status --short`
   - `git remote -v`
   - Identify the base branch, preferring `origin/main` when present unless the user specifies another base.
2. Load the PR template reference before drafting:
   - Read `reference/pr-template.md`.
   - If `.github/PULL_REQUEST_TEMPLATE.md` exists, read it too and prefer its live contents if different.
3. Inspect branch work against base:
   - `git merge-base --fork-point <base> HEAD 2>/dev/null || git merge-base <base> HEAD`
   - `git log --oneline --decorate <base>...HEAD`
   - `git diff --stat <base>...HEAD`
   - `git diff --name-status <base>...HEAD`
4. Review changed content enough to understand intent:
   - Use `git show --stat --oneline <commit>` for branch commits.
   - Use `git diff <base>...HEAD -- <path>` for important files.
   - If uncommitted changes exist, inspect them separately with `git diff --stat`, `git diff --name-status`, and relevant file diffs.
5. If uncommitted changes are related and should be part of the PR, recommend running `$commit` first instead of silently including them. If the user asked only for a draft, continue with a clear note that the body is based on committed changes unless otherwise stated.
6. Draft the PR body in Korean using the repository template sections exactly.
7. Be honest about uncertainty:
   - Do not invent issue numbers. Leave `Closes #` only if the issue is unknown.
   - Do not claim tests were run unless tool output proves it.
   - If no screenshots are needed, write `해당 없음` in the screenshot section.
   - If uncommitted changes exist, clearly state whether the PR body includes only committed changes or also notes uncommitted work.
8. Final response should include:
   - Base branch and current branch.
   - Commit range used.
   - The PR title suggestion.
   - A copy-ready PR body in a fenced markdown block.
   - Remaining risks or missing information, if any.

## PR title rules

- Prefer a concise Korean title that summarizes the whole branch, not just the latest commit.
- If the branch contains exactly one meaningful commit, the latest commit title may be reused when it accurately summarizes the PR.
- If multiple commits exist, synthesize a broader PR title from the commit range and changed files.
- Use the repo commit style (`type(scope): 설명`) when it remains natural for PR titles; otherwise omit the prefix only if the repository/user context requires a plain title.
- Do not include a body, issue closure, or checklist text in the title.
- If no trustworthy title can be inferred, provide the best suggestion and list what information is missing.

## Template filling rules

- `💡 개요`: one short paragraph explaining purpose and result.
- `🔗 관련 이슈`: keep `Closes #` if no issue is discoverable from branch name, commits, or user input.
- `📃 작업내용`: bullet list of concrete changes from committed diffs.
- `🔍 테스트 방법`: list only performed verifications; if none were run, write `- 미실행: ...` with a reason.
- `🖼️ 스크린샷`: `해당 없음` unless visual/UI evidence exists or the user provides screenshots.
- `🙋‍♂️ 질문사항`: keep the repository default reviewer note unless there is a specific question.
- `✅ 체크리스트`: mark `[x]` only when verified; leave `[ ]` for unverified claims.


## Related skill handoff

- Use `$commit` before `$pr` when related work is still uncommitted and the user wants a PR for final branch contents.
- Do not auto-commit from `$pr` unless the user explicitly asks to commit. Instead, recommend the `$commit` handoff and explain which files appear related.
- If the user asks for both commit and PR, run `$commit` first, then re-run PR branch inspection from the new HEAD.

## Handling uncommitted changes

- Never silently include uncommitted changes in the PR summary.
- If uncommitted changes are unrelated to the branch work, list them under risks/missing information and exclude them from the PR body.
- If they are related but not committed, mention that the PR body is based on committed changes and that the uncommitted files should be committed or intentionally excluded before opening the PR.

## Git error handling

If an unexpected git error occurs, stop before risky recovery, summarize the error, present a concrete recommended fix plus alternatives, and ask the user which solution to apply.

Do not run destructive git commands (`reset --hard`, `checkout --`, `clean`) unless explicitly requested.

## Quality gate

Before final response, confirm:

- The PR body uses the exact repository template sections.
- The branch/base/range used for analysis are stated.
- Every claimed change is supported by commit or diff inspection.
- Test/checklist items are not marked complete without evidence.
- Unknown issue numbers, screenshots, and questions are handled explicitly.
