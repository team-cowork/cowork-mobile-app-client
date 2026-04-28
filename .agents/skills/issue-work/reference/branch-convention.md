# Branch Convention

## Format

```text
<type>/<kebab-case-description>
```

Examples:

```text
feat/cowork-chat-message-input
fix/cowork-issue-status-update
refactor/shell-shared-layout
cicd/github-actions-workflow
```

## Branch types

| Type | Meaning |
| --- | --- |
| `feat` | 새 기능 |
| `fix` | 버그 수정 |
| `refactor` | 리팩터링 |
| `docs` | 문서 |
| `style` | 스타일 |
| `test` | 테스트 |
| `chore` | 기타 |
| `perf` | 성능 개선 |
| `cicd` | CI/CD 파이프라인 (`ci/cd` 타입일 때 슬래시 대신 사용) |

## Git Flow rules

- 모든 작업 브랜치는 `develop`에서 생성하고 `develop`으로 병합한다.
- `develop`에 직접 커밋하지 않는다.
- `develop`에 직접 push하지 않는다.

## Naming rules

- Description must be English kebab-case.
- Keep the branch name short but specific.
- Do not include spaces, Korean, or extra slashes in the description.
- If an issue number is useful, include it in kebab-case text only when the user/team asks for it; the required format itself does not require issue numbers.
