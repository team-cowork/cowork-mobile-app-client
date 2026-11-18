import 'package:cowork_design_system/design_system.dart';
import 'package:flutter/material.dart';

/// 설정 화면에서 글 한 항목(이름·설명)을 고치는 시트. 고친 내용을 돌려주고, 취소하면
/// null.
class EditTextSheet extends StatefulWidget {
  const EditTextSheet({
    required this.title,
    required this.initialText,
    required this.allowEmpty,
    required this.singleLine,
    super.key,
  });

  final String title;
  final String initialText;

  /// 비워서 저장할 수 있는지. 이름은 비울 수 없다.
  final bool allowEmpty;

  /// 한 줄만 받는지. 이름에 줄바꿈이 들어가면 목록·헤더가 두 줄로 보인다.
  final bool singleLine;

  static Future<String?> show(
    BuildContext context, {
    required String title,
    required String initialText,
    required bool allowEmpty,
    bool singleLine = false,
  }) => showModalBottomSheet<String>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.neutral800,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => EditTextSheet(
      title: title,
      initialText: initialText,
      allowEmpty: allowEmpty,
      singleLine: singleLine,
    ),
  );

  @override
  State<EditTextSheet> createState() => _EditTextSheetState();
}

class _EditTextSheetState extends State<EditTextSheet> {
  late final _controller = TextEditingController(text: widget.initialText);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _save() {
    final text = _controller.text.trim();
    if (!widget.allowEmpty && text.isEmpty) return;
    Navigator.of(context).pop(text);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          AppSpacing.s20,
          AppSpacing.s16,
          AppSpacing.s20,
          AppSpacing.s24 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: AppSpacing.s16,
          children: [
            Text(
              widget.title,
              style: AppFont.labelM.copyWith(color: AppColors.darkOnSurface),
            ),
            if (widget.singleLine)
              CoworkTextField(
                controller: _controller,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _save(),
              )
            else
              CoworkTextArea(controller: _controller, minLines: 1),
            ValueListenableBuilder(
              valueListenable: _controller,
              builder: (context, value, _) => CoworkButton(
                label: '저장',
                size: CoworkButtonSize.large,
                enabled: widget.allowEmpty || value.text.trim().isNotEmpty,
                onPressed: _save,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
