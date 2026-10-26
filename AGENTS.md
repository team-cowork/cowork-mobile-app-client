# AGENTS.md

## 프로젝트 개요

Cowork 모바일 앱 클라이언트 저장소입니다.

- Framework: Flutter
- State Management: flutter_bloc (Bloc + `AsyncState`), 값 비교는 equatable
- Network: 미도입 (현재 데이터는 인메모리 `*Store` 싱글턴)
- Model Generation: API 요청·응답 모델만 freezed + json_serializable (build_runner)
- Architecture: feature layer structure

## 작업 원칙

- 기존 구조와 컨벤션을 우선 따른다.
- 변경 범위를 작게 유지하고, 불필요한 의존성을 추가하지 않는다.
- 사용자 변경사항을 임의로 되돌리지 않는다.
- 작업 후 가능한 검증 명령을 실행하고 결과를 보고한다.
- 모르는 컨벤션은 주변 코드 패턴을 먼저 확인하고 따른다.
- 해석이 갈리거나 확실하지 않은 부분은 임의로 정하지 않고 사용자에게 먼저 묻는다. 확실한 것만 작업한다.

## 작업 완료 보고

작업을 끝내면 요약 보고서를 작성한다.

- 무엇을 왜 바꿨는지 한두 줄 요약
- 변경한 파일과 각 파일에서 한 일
- 검증 결과. 실행한 명령과 결과를 적고, 못 돌렸으면 `미실행`과 이유를 적는다.
- 기능 추가/수정이면 동작 흐름도 함께 적는다. 진입점 → 상태/데이터 흐름 → 화면 반영 순서.
- 확실하지 않은 부분은 추측으로 적지 않고 질문으로 남긴다.

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
- `lib/` 최상위는 아래처럼 나눈다.
  - `core/`: 앱이 돌아가기 위한 기반 설비. 비즈니스 의미가 거의 없고 앱 전체에 하나씩 있는 기술적인 것. 기능이 하나도 없는 빈 앱에도 있을 법한 것만 둔다. (네트워크 클라이언트·인터셉터·소켓, 로깅, 앱 생명주기, `AsyncState`·`CommandBloc` 같은 상태 기본 타입, 로컬 저장소 래퍼) 디자인 토큰·테마는 `cowork_design_system` 패키지에 있다.
  - `shared/`: 여러 feature 가 같이 쓰는 재사용 부품. feature 에서 쓰다가 다른 feature 에서도 쓰게 되면 끌어내린다. (`widgets/` 공통 위젯, `domain/` 여러 feature 에 걸친 엔티티, `extensions/`, `utils/` 포맷터)
  - `feature/<name>/`: 기능 단위 코드.
  - `app/`: feature 들을 조립하는 앱 셸. (라우터, 탭 셸, 인증 분기)
- 의존 방향은 `app` → `feature` → `shared` → `core` 한쪽으로만 둔다. `core` 와 `shared` 는 `feature` 와 `app` 을 import 하지 않는다.
  - 예외: `core/network/` 는 토큰·주소 때문에 아직 `feature/auth` 를 import 한다. 토큰 저장·갱신을 core 로 내리면 끊는다.
- 기능 변경 시 관련 feature 경계 안에서 먼저 해결한다.
- 공통화가 필요한 경우에만 `shared/` 로, 기반 설비만 `core/` 로 이동한다.
- 새로운 구조나 추상화는 기존 패턴을 먼저 확인한 뒤 최소한으로 추가한다.
- 위젯은 쓰이는 곳 수로 위치를 정한다. 여러 feature에서 쓰면 `shared/widgets/` 또는 design_system, 한 feature의 여러 화면에서 쓰면 `feature/<name>/presentation/widgets/`, 한 화면에서만 쓰면 그 화면 파일 안 private 클래스로 둔다.
- 위젯 테스트가 직접 참조하는 위젯은 두 번째 소비자가 있는 것으로 보고 `widgets/` 에 남긴다.

## UI / 기능 개발 경계

- API 연결, 데이터 처리, 상태 관리, 기능 로직 개발 시 UI 코드를 절대 건드리지 않는다.
- 퍼블리싱 또는 UI 제작 작업에서는 디자인 시스템에 있는 컴포넌트/토큰/패턴을 우선 활용한다.
- 디자인 시스템에 없는 UI를 만들 때도 기존 스타일과 컴포넌트 패턴을 먼저 확인한다.

## 모델 / 데이터 레이어 규칙

- 코드 생성은 API 요청·응답 모델에만 쓴다. domain 모델, Bloc 이벤트/상태는 `equatable`로 직접 작성한다.
- API 연동 feature 의 `data/` 는 아래처럼 나눈다. 모델은 파일 하나에 클래스 하나다.
  - `data/repositories/`: `*_repository.dart`
  - `data/model/requests/`: `*_request.dart` (`@Freezed(fromJson: false, toJson: true)`)
  - `data/model/responses/`: `*_response.dart` (`@freezed` + `fromJson`)
  - 요청·응답과 앱 모델 사이 변환 도우미는 `data/model/` 에 둔다.
- Bloc 이벤트/상태는 `sealed` 베이스 + `final class` 서브타입 + `Equatable` 패턴을 따른다. (`notes_event.dart`, `core/utils/async_state.dart` 참고)
- freezed 는 3.x 를 쓴다. 4.x 는 Dart 3.13 이상이 필요하다.
- generated file은 수동 수정하지 않는다.
- Flutter/codegen 산출물(`*.g.dart`, `*.freezed.dart` 등)은 원인 source 변경과 같은 커밋에 포함한다.
- 원인 source 변경 없이 재생성/정리만 수행한 generated 변경은 별도 `chore` 또는 `refactor` 커밋으로 분리한다.

## 상태관리 / DI / 네트워크 규칙

- 상태관리는 flutter_bloc을 사용한다. 화면 단위 Bloc은 `feature/<name>/presentation/blocs/<bloc>/` 아래 `_bloc`/`_event`/`_state` 세 파일로 둔다.
- 시트/폼처럼 화면이 닫히면 버려지는 입력값은 Bloc 없이 `StatefulWidget` + `setState` 로 든다.
- 단일 데이터를 불러오는 화면은 `AsyncState<T>` + `BlocScaffold`를 쓴다. 로딩/실패 화면을 개별 구현하지 않는다.
- Bloc 주입은 `BlocProvider`로 한다. 별도 DI 컨테이너는 쓰지 않는다.
- 백엔드 연동 전까지 데이터는 `data/*_store.dart` 인메모리 싱글턴에 둔다. 실제 API 연동 시 이 싱글턴을 리포지토리로 교체한다.

## 검증 명령

작업 후 가능한 범위에서 아래 명령을 사용한다.

```bash
flutter analyze
flutter test
```

API 요청·응답 모델을 추가/변경했을 때 (생성 파일도 커밋한다):

```bash
dart run build_runner build --delete-conflicting-outputs
```

위젯북 유즈케이스를 추가/변경했을 때:

```bash
cd widgetbook && flutter pub run build_runner build --delete-conflicting-outputs
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

루트 `CLAUDE.md`는 `@AGENTS.md` 한 줄짜리 import다. 규칙은 AGENTS.md에만 적는다.

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
