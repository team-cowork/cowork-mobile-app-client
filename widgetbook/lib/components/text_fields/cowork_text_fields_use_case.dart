import 'package:cowork_design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:widgetbook_annotation/widgetbook_annotation.dart' as widgetbook;

@widgetbook.UseCase(
  name: 'TextField',
  type: CoworkTextFieldPreview,
  path: '[Design System]/components/text_fields',
)
Widget coworkTextFieldPreview(BuildContext context) {
  return const CoworkTextFieldPreview();
}

class CoworkTextFieldPreview extends StatelessWidget {
  const CoworkTextFieldPreview({super.key});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.light(),
      child: const Scaffold(
        body: SingleChildScrollView(
          padding: EdgeInsets.all(28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Cowork/TextField', style: AppFont.titleL),
              SizedBox(height: 12),
              Text('로그인, 검색, 설정 폼에 사용하는 단일 라인 입력입니다.', style: AppFont.subtextL),
              SizedBox(height: 16),
              Wrap(
                spacing: 16,
                runSpacing: 12,
                children: [
                  CoworkTextField(
                    hintText: 'name@cowork.dev',
                    labelText: '이메일',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
