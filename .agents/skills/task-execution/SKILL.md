---
name: task-execution
description: Gate actual task execution against the current issue and branch. Use when work is based on an issue/branch but implementation is forbidden or must be explicitly blocked; classify the request, prevent code implementation, and report the allowed non-implementation next steps.
---

# Task Execution Gate

Use this skill when an issue and branch exist but the current instruction says implementation work is forbidden.

## Rule

- Do not modify production code, tests, generated files, or UI for implementation.
- Allow only read-only inspection, planning, validation, classification, documentation of findings, or user-approved workflow setup.

## Workflow

1. Identify the current issue/branch context.
2. Determine whether the requested action is implementation.
3. If it is implementation, stop before editing and explain that implementation is prohibited by this skill.
4. Offer safe alternatives:
   - summarize requirements
   - inspect current code read-only
   - draft a plan
   - classify existing changes
   - run validation commands if changes already exist
5. If the action is non-implementation, proceed within that limited scope.

## Output

```yaml
allowed: true|false
reason: "<why the request is allowed or blocked>"
next_steps:
  - "<safe next step>"
```
