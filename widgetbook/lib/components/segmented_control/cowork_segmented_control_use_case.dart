import 'package:cowork_design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(
  name: 'SegmentedControl',
  type: CoworkSegmentedControlPreview,
  path: '[Design System]/components/segmented_control',
)
Widget coworkSegmentedControlPreview(BuildContext context) {
  return const CoworkSegmentedControlPreview();
}

class CoworkSegmentedControlPreview extends StatefulWidget {
  const CoworkSegmentedControlPreview({super.key});

  @override
  State<CoworkSegmentedControlPreview> createState() =>
      _CoworkSegmentedControlPreviewState();
}

class _CoworkSegmentedControlPreviewState
    extends State<CoworkSegmentedControlPreview> {
  String _twoSegmentValueM = 'chat';
  String _twoSegmentValueL = 'chat';
  String _threeSegmentValueM = 'chat';
  String _threeSegmentValueL = 'chat';

  static const _twoSegments = [
    CoworkSegment(value: 'chat', label: '채팅'),
    CoworkSegment(value: 'file', label: '파일'),
  ];

  static const _threeSegments = [
    CoworkSegment(value: 'chat', label: '채팅'),
    CoworkSegment(value: 'issue', label: '이슈'),
    CoworkSegment(value: 'meeting', label: '회의록'),
  ];

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
              const Text('Cowork/Segmented Control', style: AppFont.titleL),
              const SizedBox(height: 12),
              const Text(
                '채팅/파일/계정 공유 같은 탭성 전환에 사용합니다.',
                style: AppFont.subtextL,
              ),
              const SizedBox(height: 24),
              const Text('Count=2', style: AppFont.labelM),
              const SizedBox(height: 12),
              SizedBox(
                width: 320,
                child: CoworkSegmentedControl<String>(
                  segments: _twoSegments,
                  groupValue: _twoSegmentValueM,
                  onChanged: (next) => setState(() => _twoSegmentValueM = next),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: 320,
                child: CoworkSegmentedControl<String>(
                  segments: _twoSegments,
                  groupValue: _twoSegmentValueL,
                  size: CoworkSegmentedControlSize.large,
                  onChanged: (next) => setState(() => _twoSegmentValueL = next),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: 320,
                child: CoworkSegmentedControl<String>(
                  segments: _twoSegments,
                  groupValue: 'chat',
                  enabled: false,
                  onChanged: (_) {},
                ),
              ),
              const SizedBox(height: 32),
              const Text('Count=3', style: AppFont.labelM),
              const SizedBox(height: 12),
              SizedBox(
                width: 480,
                child: CoworkSegmentedControl<String>(
                  segments: _threeSegments,
                  groupValue: _threeSegmentValueM,
                  onChanged: (next) =>
                      setState(() => _threeSegmentValueM = next),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: 480,
                child: CoworkSegmentedControl<String>(
                  segments: _threeSegments,
                  groupValue: _threeSegmentValueL,
                  size: CoworkSegmentedControlSize.large,
                  onChanged: (next) =>
                      setState(() => _threeSegmentValueL = next),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: 480,
                child: CoworkSegmentedControl<String>(
                  segments: _threeSegments,
                  groupValue: 'chat',
                  enabled: false,
                  onChanged: (_) {},
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
