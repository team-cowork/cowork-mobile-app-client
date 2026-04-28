---
name: validation
description: Validate changed code after work completion and before commit or PR. Use when code changes exist, before committing, or before creating a pull request to verify requirements, errors, exceptions, and available Flutter checks such as flutter analyze and flutter test; block commit/PR on validation failure.
---

# Validation Gate

Use this skill after changes and before commits or PRs.

## Preconditions

- Code or project files have changed.
- Requirements or intended outcome are known.

## Workflow

1. Review the requirement and the changed files.
2. Check for obvious errors, exception paths, generated-file consistency, and repo convention violations.
3. Run the strongest practical verification:
   - `flutter analyze`
   - `flutter test`
   - `dart run build_runner build --delete-conflicting-outputs` when model/codegen sources changed
4. If a command cannot run, record why and do not claim it passed.
5. If validation fails, report failures and block commit/PR until fixed.
6. If validation succeeds, report evidence and allow the next workflow step.

## Output

```yaml
result: success|fail
checks:
  - name: "<command or review>"
    result: "passed|failed|not-run"
    evidence: "<short output or reason>"
issues:
  - "<blocking issue, empty if none>"
```

## Constraints

- Do not commit or create a PR after failed validation.
- Do not invent test results.
- Prefer exact command evidence over assumptions.
