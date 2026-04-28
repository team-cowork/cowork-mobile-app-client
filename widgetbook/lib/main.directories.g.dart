// dart format width=80
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_import, prefer_relative_imports, directives_ordering

// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AppGenerator
// **************************************************************************

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:widgetbook/widgetbook.dart' as _widgetbook;
import 'package:widgetbook_workspace/design_system_use_cases.dart'
    as _widgetbook_workspace_design_system_use_cases;

final directories = <_widgetbook.WidgetbookNode>[
  _widgetbook.WidgetbookCategory(
    name: 'Design System',
    children: [
      _widgetbook.WidgetbookFolder(
        name: 'theme',
        children: [
          _widgetbook.WidgetbookComponent(
            name: 'DesignSystemPreview',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Dark',
                builder: _widgetbook_workspace_design_system_use_cases
                    .darkThemePreview,
              ),
              _widgetbook.WidgetbookUseCase(
                name: 'Light',
                builder: _widgetbook_workspace_design_system_use_cases
                    .lightThemePreview,
              ),
            ],
          ),
        ],
      ),
    ],
  ),
];
