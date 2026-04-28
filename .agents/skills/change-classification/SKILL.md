---
name: change-classification
description: Analyze git diff before committing and split changes into logical commit groups. Use when git diff exists, before commits, or when changes need to be separated into feature, bug fix, refactor, configuration, documentation, test, or generated-file units without mixing unrelated work.
---

# Change Classification

Use this skill before committing when there are unstaged, staged, or untracked changes.

## Preconditions

- A git diff or untracked files exist.
- Do not assume all changes are agent-authored; distinguish user changes from AI changes when possible.

## Workflow

1. Inspect changes:
   - `git status --short`
   - `git diff --stat`
   - `git diff -- <path>` as needed
   - `git diff --cached --stat` if staged changes exist
2. Group files/hunks by logical task:
   - feature
   - fix
   - refactor
   - docs
   - style
   - test
   - chore/config/generated
3. Keep generated files with their source change unless they are regeneration-only cleanup.
4. Separate unrelated changes; do not force everything into one commit.
5. Flag suspected user-authored changes and request confirmation before staging/committing them.

## Output

```yaml
commit_groups:
  - type: "feat|fix|refactor|docs|style|test|chore|perf|cicd"
    scope: "<repo convention scope>"
    summary: "<short Korean commit summary candidate>"
    files:
      - "<path>"
    notes:
      - "<risk, generated pairing, or user-change concern>"
```

## Constraints

- Do not group unrelated changes together.
- Do not commit while validation is failing.
- Do not stage or discard user changes without explicit confirmation.
