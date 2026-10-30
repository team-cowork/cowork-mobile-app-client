import 'package:cowork_design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/async_state.dart';
import '../../../../core/utils/command_bloc.dart';
import '../../../../shared/widgets/create_sheet.dart';
import '../../domain/note_template.dart';

/// 템플릿 이름으로 요청 하나를 보내는 [CommandBloc]. (생성 또는 이름 수정)
typedef _SubmitName = CommandBloc<String, NoteTemplate>;

/// 템플릿 이름을 받는 바텀시트. 새 템플릿과 이름 수정이 같이 쓴다.
///
/// 보내는 동안은 입력과 닫기를 잠그고, 실패하면 입력값을 둔 채 사유를 보여준다.
/// 성공하면 서버가 돌려준 템플릿을 돌려주며 닫힌다.
class TemplateNameSheet extends StatefulWidget {
  const TemplateNameSheet({
    required this.title,
    required this.actionLabel,
    this.initialName = '',
    this.caption,
    super.key,
  });

  /// 시트 제목. (예: 새 템플릿, 이름 수정)
  final String title;

  /// CTA 문구. (예: 템플릿 만들기, 저장)
  final String actionLabel;

  final String initialName;

  /// 입력 칸 아래 안내 문구.
  final String? caption;

  /// 시트를 띄우고 [submit] 이 돌려준 템플릿을 넘긴다. 그냥 닫으면 null.
  static Future<NoteTemplate?> show(
    BuildContext context, {
    required String title,
    required String actionLabel,
    required Future<NoteTemplate> Function(String name) submit,
    String initialName = '',
    String? caption,
  }) => CreateSheet.show<NoteTemplate>(
    context,
    (_) => BlocProvider(
      create: (_) => _SubmitName(submit, tag: 'NoteTemplates'),
      child: TemplateNameSheet(
        title: title,
        actionLabel: actionLabel,
        initialName: initialName,
        caption: caption,
      ),
    ),
  );

  @override
  State<TemplateNameSheet> createState() => _TemplateNameSheetState();
}

class _TemplateNameSheetState extends State<TemplateNameSheet> {
  late final _name = TextEditingController(text: widget.initialName);

  /// 이름이 있고 처음 값과 달라야 보낼 수 있다.
  bool get _canSubmit {
    final name = _name.text.trim();
    return name.isNotEmpty && name != widget.initialName;
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<_SubmitName, AsyncState<NoteTemplate>>(
      listener: (context, state) {
        if (state case AsyncSuccess(:final data)) {
          Navigator.of(context).pop(data);
        }
      },
      builder: (context, state) {
        // 성공 직후 닫히기 전 한 프레임도 잠가 둔다.
        final submitting = state is AsyncLoading || state is AsyncSuccess;

        return CreateSheet(
          title: widget.title,
          dismissible: !submitting,
          children: [
            CoworkTextField(
              controller: _name,
              labelText: '이름',
              hintText: '예: 주간 회의',
              enabled: !submitting,
              textInputAction: TextInputAction.done,
              onChanged: (_) => setState(() {}),
            ),
            if (widget.caption case final caption?)
              Text(
                caption,
                style: AppFont.subtextS.copyWith(
                  color: context.colors.onSurfaceVariant,
                ),
              ),
            if (state case AsyncFailure(:final message))
              CreateSheetError(
                title: '템플릿을 저장하지 못했어요',
                message: message ?? '잠시 후 다시 시도해 주세요.',
              ),
            SizedBox(
              width: double.infinity,
              child: CoworkButton(
                label: submitting ? '저장 중…' : widget.actionLabel,
                size: CoworkButtonSize.large,
                enabled: _canSubmit && !submitting,
                onPressed: () => context.read<_SubmitName>().add(
                  CommandEvent.run(_name.text.trim()),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
