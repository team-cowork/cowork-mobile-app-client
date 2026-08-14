---
name: run-app
description: Launch the cowork Flutter app on an Android emulator and see a change actually rendered - device choice, the OAuth-free preview harness for reaching a single screen, and the screenshot limitation on this project's emulators. Use when asked to run/start the app, verify a change in the real app, or screenshot a screen.
---

# cowork 앱 실행하기

## 준비

FVM 으로 Flutter 3.44.0 을 고정한다(`.fvmrc`). 모든 명령 앞에 `fvm` 을 붙인다.

```bash
fvm flutter analyze     # 커밋 전 항상
fvm flutter test        # 위젯/유닛 테스트
```

## 디바이스는 Android 에뮬레이터뿐

```bash
fvm flutter emulators                    # cowork, Pixel_9
fvm flutter emulators --launch cowork    # 부팅까지 30초쯤
fvm flutter devices                      # emulator-5554 로 잡히는지 확인
```

다른 타깃은 막혀 있다. 시도해서 시간 버리지 말 것:

- **Windows 데스크톱** — `flutter doctor` 가 Windows 10 SDK 없음을 경고한다. 빌드 실패한다.
- **웹(Chrome)** — 프로필 쪽이 `dart:io` 의 `File` 을 쓴다(`profile_repository`,
  `edit_profile_view`, `profile_card`). 웹에서는 컴파일 자체가 안 된다.

## 화면 하나만 보고 싶을 때: 프리뷰 하네스

앱을 그냥 띄우면 `AuthGate` 가 DataGSM OAuth 로그인 화면을 내민다. 실계정과
리다이렉트가 필요해서, 화면 확인용으로는 무겁다.

`tool/preview_profile.dart` 는 dio 어댑터만 스텁으로 갈아 끼우고 화면·위젯은 앱과
같은 것을 쓴다. 로그인을 건너뛰고 프로필 화면이 바로 뜬다.

```bash
fvm flutter run -t tool/preview_profile.dart -d emulator-5554 > /run.log 2>&1
```

다른 화면이 필요하면 이 파일을 복사해 응답 맵과 `home:` 만 바꾼다. 저장은 400 을
돌려주도록 해 놨으니 편집 → 저장으로 실패 화면까지 볼 수 있다.

**로그는 파일로 리다이렉트한다.** `| tail` 로 파이프하면 `flutter run` 이 안 끝나서
tail 이 버퍼를 안 비우고, 로그가 통째로 안 보인다.

```bash
grep -q "Flutter run key commands" /run.log   # 뜨면 붙은 것
```

## 화면 확인: 에뮬레이터 창을 직접 봐야 한다

**`adb exec-out screencap` 은 이 프로젝트 앱 화면을 못 잡는다.** 순수 `#000000` 만
돌아온다(런처 화면은 정상 캡처되므로 adb 문제는 아니다). Impeller 를 꺼도
(`--no-enable-impeller`) 같다. `flutter screenshot --type=skia` 는 `.skp` 라 이미지로
못 본다.

그래서 렌더 결과 확인은 **사람이 에뮬레이터 창을 보는 것**이 유일한 경로다. 색·간격
같은 걸 봐야 하면 사용자에게 무엇을 봐 달라고 할지 구체적으로 적어서 부탁한다.

에이전트가 스스로 확인할 수 있는 건 여기까지다:

```bash
ADB="$HOME/AppData/Local/Android/Sdk/platform-tools/adb.exe"
"$ADB" shell dumpsys activity activities | grep ResumedActivity   # 앱이 앞에 있는지
grep -iE "EXCEPTION|^I/flutter" /run.log                          # Dart 오류
```

레이아웃이 깨지는지(오버플로·무한 제약)는 화면 대신 위젯 테스트로 잡는다.
`tester.takeException()` 이 `isNull` 인지 보면 된다 —
`test/feature/profile/github_streak_test.dart` 에 예시가 있다.
