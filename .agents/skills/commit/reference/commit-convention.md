# Commit Convention

## Format

```text
type(scope): 설명
```

- Title only: do not include a body, footers, or trailers.
- Description (`설명`) must be concise Korean.

## Types

| Type | Use for |
| --- | --- |
| `feat` | 새 기능 추가 |
| `fix` | 버그 수정 |
| `docs` | 문서 수정 |
| `style` | 코드 포맷 등 동작에 영향 없는 변경 |
| `refactor` | 기능 변경 없는 코드 개선 |
| `test` | 테스트 추가 및 수정 |
| `chore` | 빌드, 설정 등 기타 변경 |
| `perf` | 성능 개선 |
| `ci/cd` | CI/CD 파이프라인 |

## Scope rules

| Changed location | Scope format | Example |
| --- | --- | --- |
| `apps/` 하위 MFE | `<app-name>/<layer>` | `cowork-chat/features` |
| `packages/` 하위 | `<layer>` | `shared` |
| 루트 (`apps/`, `packages/` 외부) | `global` | `global` |

## MFE apps

| App | Area |
| --- | --- |
| `cowork-chat` | 채팅 |
| `cowork-issue` | 이슈 트래킹 |
| `cowork-profile` | 사용자 프로필 |
| `shell` | 호스트 앱, 레이아웃, 라우팅 |

## FSD layers

Use the layer segment present in the path, commonly:

| Layer | Meaning |
| --- | --- |
| `app` | 앱 초기화, 프로바이더, 전역 설정 |
| `pages` | 라우트/페이지 조합 |
| `widgets` | 독립적인 UI 블록 |
| `features` | 사용자 행동 중심 기능 |
| `entities` | 도메인 모델과 상태 |
| `shared` | 공통 유틸, UI, API, 설정 |

## Single-area examples

| Wrong | Correct | Reason |
| --- | --- | --- |
| `feat(global): 메시지 입력 컴포넌트 추가` | `feat(cowork-chat/features): 메시지 입력 컴포넌트 추가` | `apps/` 내부 변경은 app/layer 형식 사용 |
| `fix(cowork-issue): 이슈 상태 업데이트 버그 수정` | `fix(cowork-issue/entities): 이슈 상태 업데이트 버그 수정` | MFE 변경 시 레이어 필수 |
| `refactor(cowork-chat): 공통 버튼 컴포넌트 개선` | `refactor(shared): 공통 버튼 컴포넌트 개선` | `packages/` 변경은 레이어만 사용 |

## Multi-app and cross-area examples

| Situation | Commit plan | Why |
| --- | --- | --- |
| Chat and issue features changed independently | `feat(cowork-chat/features): 메시지 입력 기능 추가` + `feat(cowork-issue/features): 이슈 필터 기능 추가` | 서로 독립적인 작업이므로 분리 |
| Shared UI package changed and chat app adopted it | `refactor(shared): 버튼 컴포넌트 속성 정리` + `refactor(cowork-chat/features): 메시지 버튼 속성 변경 반영` | shared 변경과 app 반영을 분리 가능 |
| Shell-only route/layout change affects all MFEs | `feat(shell/app): 공통 라우팅 가드 추가` | 실제 변경 위치가 shell app layer |
| Root build config changes for every app | `chore(global): 워크스페이스 빌드 설정 갱신` | 루트 설정은 global |
| Same bug requires entity fixes in two apps | `fix(cowork-chat/entities): 읽음 상태 계산 수정` + `fix(cowork-issue/entities): 상태 동기화 계산 수정` | 앱/레이어별 영향이 명확함 |

## Global scope examples

Use `global` for repository-level changes such as:

- `.github/`, CI/CD config, repository scripts, lint/build config
- root docs and metadata
- mobile-native folders or non-MFE roots when this convention is used in a non-`apps`/`packages` repository

Avoid `global` when all changed files live under one `apps/<app>/<layer>` or one package layer.
