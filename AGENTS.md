# AGENTS.md

## 프로젝트 개요

Cowork 모바일 앱 클라이언트 저장소입니다.

- Framework: Flutter
- State Management / DI: Riverpod
- Network: Dio, Retrofit
- Model Generation: freezed, json_serializable
- Architecture: feature layer structure

## 작업 원칙

- 기존 구조와 컨벤션을 우선 따른다.
- 변경 범위를 작게 유지하고, 불필요한 의존성을 추가하지 않는다.
- 사용자 변경사항을 임의로 되돌리지 않는다.
- 작업 후 가능한 검증 명령을 실행하고 결과를 보고한다.
- 모르는 컨벤션은 주변 코드 패턴을 먼저 확인하고 따른다.

## 브랜치 / Git 규칙

- 사용자가 별도로 말하지 않는 한 새 작업 브랜치는 `develop`에서 분기한다.
- `develop` 브랜치에서 직접 작업하거나 직접 push하지 않는다.
- PR/Merge 대상은 사용자가 별도로 말하지 않는 한 `develop`이다.
- 기능/수정 작업은 `develop`에서 만든 별도 브랜치에서 진행하고 PR을 통해 `develop`으로 머지한다.
- 브랜치 이름은 `<type>/<kebab-case-description>` 형식을 따른다. 예: `feat/cowork-chat-message-input`, `fix/cowork-issue-status-update`, `refactor/shell-shared-layout`, `cicd/github-actions-workflow`.
- 브랜치 타입은 `feat`, `fix`, `refactor`, `docs`, `style`, `test`, `chore`, `perf`, `cicd`만 사용한다. CI/CD 작업은 `ci/cd` 대신 `cicd`를 사용한다.
- 파괴적 git 명령은 사용자 명시 요청 없이는 실행하지 않는다.
  - 예: `git reset --hard`, `git clean`, `git checkout -- <path>`

## 커밋 메시지 규칙

커밋 메시지는 제목 한 줄만 작성한다.

```text
type(scope): 설명
```

상세 타입/스코프/예시는 `.agents/skills/commit/reference/commit-convention.md`를 단일 원천으로 따른다. AGENTS.md에는 요약만 유지해 drift를 방지한다.

## PR 규칙

- PR은 `.github/PULL_REQUEST_TEMPLATE.md` 형식을 따른다.
- 기본 PR base branch는 `develop`이다.
- 현재 브랜치와 base branch 기준 commit/diff/stat을 확인하고 작성한다.
- 이슈 번호, 테스트 결과, 스크린샷은 근거 없이 지어내지 않는다.
- 테스트를 실행하지 못했으면 PR 본문에 `미실행`으로 명확히 적는다.
- 관련 없는 uncommitted 변경은 PR 설명에 포함하지 않는다.

## 코드 구조 규칙

- feature layer structure를 따른다.
- 기능 변경 시 관련 feature 경계 안에서 먼저 해결한다.
- 공통화가 필요한 경우에만 shared/core 성격의 위치로 이동한다.
- 새로운 구조나 추상화는 기존 패턴을 먼저 확인한 뒤 최소한으로 추가한다.

## UI / 기능 개발 경계

- API 연결, 데이터 처리, 상태 관리, 기능 로직 개발 시 UI 코드를 절대 건드리지 않는다.
- 퍼블리싱 또는 UI 제작 작업에서는 디자인 시스템에 있는 컴포넌트/토큰/패턴을 우선 활용한다.
- 디자인 시스템에 없는 UI를 만들 때도 기존 스타일과 컴포넌트 패턴을 먼저 확인한다.

## 모델 / 데이터 레이어 규칙

- `data` 레이어 안의 모델은 `freezed`와 `json_serializable`을 함께 사용한다.
- `data` 레이어 외의 immutable/model 성격 객체는 기본적으로 `freezed`를 사용한다.
- generated file은 수동 수정하지 않는다.
- 모델 변경 후 필요한 경우 code generation 명령을 실행한다.
- Flutter/codegen 산출물(`*.g.dart`, `*.freezed.dart` 등)은 원인 source 변경과 같은 커밋에 포함한다.
- 원인 source 변경 없이 재생성/정리만 수행한 generated 변경은 별도 `chore` 또는 `refactor` 커밋으로 분리한다.

## 상태관리 / DI / 네트워크 규칙

- 상태관리는 Riverpod을 사용한다.
- DI도 Riverpod provider 기반으로 구성한다.
- API client는 Retrofit + Dio 패턴을 따른다.
- 신규 API 연결 시 기존 Dio/Retrofit 설정, interceptor, error handling 패턴을 먼저 확인한다.

## 검증 명령

작업 후 가능한 범위에서 아래 명령을 사용한다.

```bash
flutter analyze
flutter test
```

모델/codegen 변경 시 필요한 경우:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

## 스킬 구조 규칙

`.agents/`가 단일 원천이며, `.claude/`는 심볼릭 링크로만 연결한다.

```text
.agents/skills/<skill-name>/
  SKILL.md
  reference/

.claude/skills/<skill-name> -> ../../.agents/skills/<skill-name>
```

스킬을 추가하거나 수정할 때는 반드시 `.agents/skills/` 아래를 수정하고, `.claude/skills/`에는 symlink만 둔다.

## Repo-local 스킬

### `$commit`

현재 git 변경사항을 확인하고 논리 작업 단위로 커밋한다.

- staged / unstaged / untracked 변경 확인
- 파일/헝크 단위 분리
- 커밋 컨벤션 적용
- 예기치 못한 git 오류 발생 시 해결책 제시 후 사용자에게 질문

### `$pr`

현재 브랜치 상태를 기준으로 PR 제목/본문을 작성한다.

- base branch 기준 변경사항 확인
- PR 템플릿 사용
- 관련 uncommitted 변경이 있으면 `$commit` 먼저 권장

### `$issue-work`

이슈 번호 또는 설명을 바탕으로 `develop` 기준 작업 브랜치를 만든다.

- 이슈/요청 내용 파악
- `<type>/<kebab-case-description>` 브랜치명 생성
- `develop`/`origin/develop`에서 작업 브랜치 분기
- 작업 후 `$commit`, `$pr`로 연계

## 안전 규칙

- secret/env 파일은 사용자 명시 요청 없이 생성, 수정, 커밋하지 않는다.
- ignored/generated/large/binary 파일은 의도를 확인하지 않고 강제 추가하지 않는다.
- merge/rebase/cherry-pick 진행 중이거나 conflict 상태면 임의로 진행하지 않고 상황과 해결책을 설명한다.
- detached HEAD 상태에서는 커밋 전 브랜치 생성/전환을 권장하고 사용자 확인을 받는다.
