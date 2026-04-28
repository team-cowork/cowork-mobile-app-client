# Cowork Design System

Cowork 앱 전반에서 공유하는 디자인 토큰과 테마를 제공하는 Flutter package입니다.

## Package

```yaml
dependencies:
  cowork_design_system:
    path: packages/design_system
```

앱 코드에서는 barrel 파일만 import합니다.

```dart
import 'package:cowork_design_system/design_system.dart';
```

## 제공 항목

| Export | 설명 |
| --- | --- |
| `AppTheme` | 앱 공통 `ThemeData` 생성기 |
| `LightTheme`, `DarkTheme` | 라이트/다크 테마 preset |
| `AppColors` | primary, semantic, neutral color token |
| `AppFont` | display/headline/body/label text style token |
| `AppIcon` | 공통 icon token |
| `AppSpacing` | 공통 spacing token |

## 앱에서 사용하기

```dart
MaterialApp(
  title: 'cowork',
  theme: AppTheme.light(),
  darkTheme: AppTheme.dark(),
  themeMode: ThemeMode.system,
  home: const HomePage(),
);
```

컴포넌트 내부에서는 직접 숫자/색상값을 반복하지 말고 디자인 시스템 토큰을 우선 사용합니다.

```dart
Padding(
  padding: const EdgeInsets.all(AppSpacing.md),
  child: Text(
    'Cowork',
    style: AppFont.headlineM.copyWith(color: AppColors.primary),
  ),
);
```

## 파일 구조

```text
packages/design_system/
  lib/
    design_system.dart
    src/
      constants/
      theme/
        color/
        config/
        icon/
        text_style/
```

- 외부 앱은 `lib/design_system.dart`만 import합니다.
- `src/` 내부 파일은 패키지 내부 구현 세부사항으로 취급합니다.
- 새 토큰/컴포넌트를 추가하면 `design_system.dart` export도 함께 갱신합니다.

## Widgetbook으로 확인하기

디자인 시스템 카탈로그는 루트의 `widgetbook/` Flutter 앱에서 확인합니다.

```bash
cd widgetbook
flutter run -d chrome
```

현재 포함된 use case:

- Design System / theme / DesignSystemPreview / Light
- Design System / theme / DesignSystemPreview / Dark

## Widgetbook use case 추가하기

1. `widgetbook/lib/*_use_cases.dart` 파일에 use case를 추가합니다.
2. `widgetbook_annotation`의 `@UseCase`를 사용합니다.
3. `build_runner`로 directories 파일을 재생성합니다.

예시:

```dart
@widgetbook.UseCase(
  name: 'Primary',
  type: ElevatedButton,
  path: '[Design System]/buttons',
)
Widget primaryButtonUseCase(BuildContext context) {
  return ElevatedButton(
    onPressed: () {},
    child: const Text('Primary'),
  );
}
```

생성 명령:

```bash
cd widgetbook
dart run build_runner build --delete-conflicting-outputs
```

감시 모드:

```bash
cd widgetbook
dart run build_runner watch --delete-conflicting-outputs
```

> `*.g.dart`는 루트 `.gitignore`에서 기본적으로 무시되지만, Widgetbook 카탈로그에 필요한 `widgetbook/lib/main.directories.g.dart`는 PR에 포함해야 합니다.

## 검증

디자인 시스템 변경 후 가능한 범위에서 아래 명령을 실행합니다.

```bash
flutter analyze
flutter analyze packages/design_system
flutter analyze widgetbook
flutter test
cd widgetbook && flutter build web
```

Widgetbook use case를 수정했다면 먼저 아래 명령으로 generated file을 갱신합니다.

```bash
cd widgetbook
dart run build_runner build --delete-conflicting-outputs
```
