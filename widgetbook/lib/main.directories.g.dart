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
import 'package:widgetbook_workspace/components/button/cowork_button_use_case.dart'
    as _widgetbook_workspace_components_button_cowork_button_use_case;
import 'package:widgetbook_workspace/components/button/cowork_icon_button_use_case.dart'
    as _widgetbook_workspace_components_button_cowork_icon_button_use_case;
import 'package:widgetbook_workspace/components/dialog/cowork_dialog_use_case.dart'
    as _widgetbook_workspace_components_dialog_cowork_dialog_use_case;
import 'package:widgetbook_workspace/components/segmented_control/cowork_segmented_control_use_case.dart'
    as _widgetbook_workspace_components_segmented_control_cowork_segmented_control_use_case;
import 'package:widgetbook_workspace/components/switch/cowork_switch_use_case.dart'
    as _widgetbook_workspace_components_switch_cowork_switch_use_case;
import 'package:widgetbook_workspace/components/text_fields/cowork_text_fields_use_case.dart'
    as _widgetbook_workspace_components_text_fields_cowork_text_fields_use_case;
import 'package:widgetbook_workspace/theme/design_system_preview.dart'
    as _widgetbook_workspace_theme_design_system_preview;

final directories = <_widgetbook.WidgetbookNode>[
  _widgetbook.WidgetbookCategory(
    name: 'Design System',
    children: [
      _widgetbook.WidgetbookFolder(
        name: 'components',
        children: [
          _widgetbook.WidgetbookFolder(
            name: 'button',
            children: [
              _widgetbook.WidgetbookComponent(
                name: 'CoworkButtonPreview',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'Button',
                    builder:
                        _widgetbook_workspace_components_button_cowork_button_use_case
                            .coworkButtonPreview,
                  ),
                ],
              ),
              _widgetbook.WidgetbookComponent(
                name: 'CoworkIconButtonPreview',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'IconButton',
                    builder:
                        _widgetbook_workspace_components_button_cowork_icon_button_use_case
                            .coworkIconButtonPreview,
                  ),
                ],
              ),
            ],
          ),
          _widgetbook.WidgetbookFolder(
            name: 'dialog',
            children: [
              _widgetbook.WidgetbookComponent(
                name: 'CoworkDialogPreview',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'Dialog',
                    builder:
                        _widgetbook_workspace_components_dialog_cowork_dialog_use_case
                            .coworkDialogPreview,
                  ),
                ],
              ),
            ],
          ),
          _widgetbook.WidgetbookFolder(
            name: 'segmented_control',
            children: [
              _widgetbook.WidgetbookComponent(
                name: 'CoworkSegmentedControlPreview',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'SegmentedControl',
                    builder:
                        _widgetbook_workspace_components_segmented_control_cowork_segmented_control_use_case
                            .coworkSegmentedControlPreview,
                  ),
                ],
              ),
            ],
          ),
          _widgetbook.WidgetbookFolder(
            name: 'switch',
            children: [
              _widgetbook.WidgetbookComponent(
                name: 'CoworkSwitchPreview',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'Switch',
                    builder:
                        _widgetbook_workspace_components_switch_cowork_switch_use_case
                            .coworkSwitchPreview,
                  ),
                ],
              ),
            ],
          ),
          _widgetbook.WidgetbookFolder(
            name: 'text_fields',
            children: [
              _widgetbook.WidgetbookComponent(
                name: 'CoworkTextFieldPreview',
                useCases: [
                  _widgetbook.WidgetbookUseCase(
                    name: 'TextField',
                    builder:
                        _widgetbook_workspace_components_text_fields_cowork_text_fields_use_case
                            .coworkTextFieldPreview,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
      _widgetbook.WidgetbookFolder(
        name: 'theme',
        children: [
          _widgetbook.WidgetbookComponent(
            name: 'DesignSystemPreview',
            useCases: [
              _widgetbook.WidgetbookUseCase(
                name: 'Dark',
                builder: _widgetbook_workspace_theme_design_system_preview
                    .darkThemePreview,
              ),
              _widgetbook.WidgetbookUseCase(
                name: 'Light',
                builder: _widgetbook_workspace_theme_design_system_preview
                    .lightThemePreview,
              ),
            ],
          ),
        ],
      ),
    ],
  ),
];
