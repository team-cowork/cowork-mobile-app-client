import 'package:cowork_design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook/widgetbook.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

import 'main.directories.g.dart';

void main() {
  runApp(const WidgetbookApp());
}

@widgetbook.App()
class WidgetbookApp extends StatelessWidget {
  const WidgetbookApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Widgetbook.material(
      directories: directories,
      addons: [
        MaterialThemeAddon(
          themes: [
            // 위젯북 프리뷰 배경을 흰색으로 고정 (실제 앱 테마는 그대로 두고 여기서만 override)
            WidgetbookTheme(
              name: 'Light',
              data: AppTheme.light().copyWith(
                scaffoldBackgroundColor: Colors.white,
              ),
            ),
            WidgetbookTheme(name: 'Dark', data: AppTheme.dark()),
          ],
        ),
      ],
    );
  }
}
