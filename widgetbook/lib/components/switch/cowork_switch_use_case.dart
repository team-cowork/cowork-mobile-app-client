import 'package:cowork_design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(
  name: 'Switch',
  type: CoworkSwitchPreview,
  path: '[Design System]/components/switch',
)
Widget coworkSwitchPreview(BuildContext context) {
  return const CoworkSwitchPreview();
}

class CoworkSwitchPreview extends StatefulWidget {
  const CoworkSwitchPreview({super.key});

  @override
  State<CoworkSwitchPreview> createState() => _CoworkSwitchPreviewState();
}

class _CoworkSwitchPreviewState extends State<CoworkSwitchPreview> {
  bool _onEnabled = true;
  bool _offEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.light(),
      child: Scaffold(
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Cowork/Switch', style: AppFont.titleL),
              const SizedBox(height: 12),
              const Text(
                '보안 모드, 공개/비공개, 알림 등 Boolean 설정에 사용합니다.',
                style: AppFont.subtextL,
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 16,
                runSpacing: 12,
                children: [
                  CoworkSwitch(
                    value: _onEnabled,
                    onChanged: (next) => setState(() => _onEnabled = next),
                  ),
                  CoworkSwitch(
                    value: _offEnabled,
                    onChanged: (next) => setState(() => _offEnabled = next),
                  ),
                  CoworkSwitch(value: true, enabled: false, onChanged: (_) {}),
                  CoworkSwitch(value: false, enabled: false, onChanged: (_) {}),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
