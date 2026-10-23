import 'package:cowork_design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/async_state.dart';
import '../../../../core/utils/command_bloc.dart';
import '../../../../core/utils/create_sheet.dart';
import '../../data/model/requests/create_team_request.dart';
import '../../data/model/responses/team_summary_response.dart';
import '../../data/repositories/team_repository.dart';

/// 팀 생성 요청 하나를 실행하는 [CommandBloc].
typedef _CreateTeam = CommandBloc<CreateTeamRequest, TeamSummaryResponse>;

/// 팀 생성 바텀시트.
///
/// 웹 `팀 만들기` 모달과 같은 항목(이름, 선택 설명)을 받는다. 채널 시트처럼 만드는
/// 동안은 입력과 닫기를 잠그고, 실패하면 입력값을 둔 채 사유를 보여준다. 성공하면
/// 서버가 만든 팀을 돌려주며 닫힌다.
///
/// ponytail: 웹은 이름 50자·설명 100자로 막는데 [CoworkTextField] 에 글자 수 제한이
/// 없어 아직 못 막는다. 넘치면 서버가 거절한 사유가 시트에 뜬다.
class NewTeamSheet extends StatefulWidget {
  const NewTeamSheet({super.key});

  /// 시트를 띄우고 만든 팀을 돌려준다. 만들지 않고 닫으면 null.
  static Future<TeamSummaryResponse?> show(BuildContext context) {
    final repository = context.read<TeamRepository>();
    return CreateSheet.show<TeamSummaryResponse>(
      context,
      (_) => BlocProvider(
        create: (_) => _CreateTeam(repository.createTeam, tag: 'Chat'),
        child: const NewTeamSheet(),
      ),
    );
  }

  @override
  State<NewTeamSheet> createState() => _NewTeamSheetState();
}

class _NewTeamSheetState extends State<NewTeamSheet> {
  String _name = '';
  String _description = '';

  /// 이름이 있어야 팀을 만들 수 있다.
  bool get _canSubmit => _name.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<_CreateTeam, AsyncState<TeamSummaryResponse>>(
      listener: (context, state) {
        if (state case AsyncSuccess(:final data)) {
          Navigator.of(context).pop(data);
        }
      },
      builder: (context, state) {
        // 성공 직후 닫히기 전 한 프레임도 잠가 둔다.
        final submitting = state is AsyncLoading || state is AsyncSuccess;
        final description = _description.trim();

        return CreateSheet(
          title: '새 팀',
          dismissible: !submitting,
          children: [
            CoworkTextField(
              labelText: '팀 이름',
              hintText: '팀 이름을 입력하세요',
              enabled: !submitting,
              textInputAction: TextInputAction.next,
              onChanged: (value) => setState(() => _name = value),
            ),
            CoworkTextField(
              labelText: '팀 설명',
              hintText: '팀을 한 줄로 소개해 보세요 (선택)',
              enabled: !submitting,
              textInputAction: TextInputAction.done,
              onChanged: (value) => setState(() => _description = value),
            ),
            if (state case AsyncFailure(:final message))
              CreateSheetError(
                title: '팀을 만들지 못했어요',
                message: message ?? '잠시 후 다시 시도해 주세요.',
              ),
            SizedBox(
              width: double.infinity,
              child: CoworkButton(
                label: submitting ? '팀 생성 중…' : '팀 만들기',
                size: CoworkButtonSize.large,
                enabled: _canSubmit && !submitting,
                onPressed: () => context.read<_CreateTeam>().add(
                  CommandEvent.run(
                    CreateTeamRequest(
                      name: _name.trim(),
                      description: description.isEmpty ? null : description,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
