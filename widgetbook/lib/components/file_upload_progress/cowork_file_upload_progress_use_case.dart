import 'dart:async';

import 'package:cowork_design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(
  name: 'File Upload Progress',
  type: CoworkFileUploadProgressPreview,
  path: '[Design System]/components/file_upload_progress',
)
Widget coworkFileUploadProgressPreview(BuildContext context) {
  return const CoworkFileUploadProgressPreview();
}

class CoworkFileUploadProgressPreview extends StatefulWidget {
  const CoworkFileUploadProgressPreview({super.key});

  @override
  State<CoworkFileUploadProgressPreview> createState() =>
      _CoworkFileUploadProgressPreviewState();
}

class _CoworkFileUploadProgressPreviewState
    extends State<CoworkFileUploadProgressPreview> {
  double _progress = 0.0;
  double _step = 0.01; // 한 틱당 증가 폭 (1% ~ 10%)
  bool _running = false;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _toggle() {
    if (_running) {
      _stop();
      return;
    }
    if (_progress >= 1.0) _progress = 0.0; // 완료 후 다시 누르면 처음부터
    setState(() => _running = true);
    _timer = Timer.periodic(const Duration(milliseconds: 150), (_) {
      setState(() {
        _progress = (_progress + _step).clamp(0.0, 1.0);
        if (_progress >= 1.0) _stop();
      });
    });
  }

  void _stop() {
    _timer?.cancel();
    _timer = null;
    if (mounted) setState(() => _running = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.s20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Cowork/File Upload Progress', style: AppFont.titleL),
            const SizedBox(height: AppSpacing.s12),
            const Text(
              '100MB 제한과 과도한 업로드 제어 상태를 표시합니다.',
              style: AppFont.subtextL,
            ),
            const SizedBox(height: AppSpacing.s24),

            // 인터랙티브 데모: 버튼으로 업로드 진행을 시작/중지한다.
            Row(
              children: [
                const Text('Interactive', style: AppFont.labelM),
                const Spacer(),
                FilledButton.tonalIcon(
                  onPressed: _toggle,
                  icon: Icon(_running ? Icons.pause : Icons.play_arrow),
                  label: Text(_running ? '중지' : '시작'),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.s12),
            // 증가 폭(틱당 % 상승) 조절 슬라이더. 1% ~ 10%.
            Row(
              children: [
                Text(
                  '증가 폭  ${(_step * 100).round()}%',
                  style: AppFont.subtextL,
                ),
                Expanded(
                  child: Slider(
                    value: _step,
                    min: 0.01,
                    max: 0.10,
                    divisions: 9,
                    label: '${(_step * 100).round()}%',
                    onChanged: (v) => setState(() => _step = v),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.s12),
            CoworkFileUploadProgress(
              filename: 'issue-log.png',
              progress: _progress,
            ),

            const SizedBox(height: AppSpacing.s32),
            const Text('States', style: AppFont.labelM),
            const SizedBox(height: AppSpacing.s12),
            const CoworkFileUploadProgress(
              filename: 'sprint-demo.mov',
              progress: 0.18,
            ),
            const SizedBox(height: AppSpacing.s12),
            const CoworkFileUploadProgress(
              filename: 'design-spec.pdf',
              progress: 0.72,
            ),
            const SizedBox(height: AppSpacing.s12),
            const CoworkFileUploadProgress(
              filename: 'design-spec-final-v3.pdf',
              progress: 1.0,
              label: '완료',
            ),
          ],
        ),
      ),
    );
  }
}
