import 'package:cowork_design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/async_state.dart';
import '../../../../core/utils/command_bloc.dart';
import '../../../../shared/widgets/create_sheet.dart';
import '../../data/model/responses/join_team_response.dart';
import '../../data/repositories/team_repository.dart';

/// 초대 코드로 팀에 들어가는 요청 하나를 실행하는 [CommandBloc].
typedef _JoinTeam = CommandBloc<String, JoinTeamResponse>;

/// 초대 코드로 팀에 참여하는 바텀시트.
///
/// 웹 `초대 코드로 참여하기` 모달처럼 코드 한 칸만 받는다. 참여하는 동안은 입력과
/// 닫기를 잠그고, 실패하면 입력값을 둔 채 서버가 준 사유(없는 코드·만료·이미 멤버)를
/// 보여준다. 성공하면 서버 응답을 돌려주며 닫힌다.
class JoinTeamSheet extends StatefulWidget {
  const JoinTeamSheet({super.key});

  /// 시트를 띄우고 참여 결과를 돌려준다. 참여하지 않고 닫으면 null.
  static Future<JoinTeamResponse?> show(BuildContext context) {
    final repository = context.read<TeamRepository>();
    return CreateSheet.show<JoinTeamResponse>(
      context,
      (_) => BlocProvider(
        create: (_) => _JoinTeam(repository.joinTeam, tag: 'Team'),
        child: const JoinTeamSheet(),
      ),
    );
  }

  @override
  State<JoinTeamSheet> createState() => _JoinTeamSheetState();
}

class _JoinTeamSheetState extends State<JoinTeamSheet> {
  String _code = '';

  /// 메신저에서 복사해 붙이면 앞뒤 공백이 딸려 오기 쉬워 잘라 보낸다.
  String get _trimmed => _code.trim();

  void _submit(BuildContext context) =>
      context.read<_JoinTeam>().add(CommandEvent.run(_trimmed));

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<_JoinTeam, AsyncState<JoinTeamResponse>>(
      listener: (context, state) {
        if (state case AsyncSuccess(:final data)) {
          Navigator.of(context).pop(data);
        }
      },
      builder: (context, state) {
        // 성공 직후 닫히기 전 한 프레임도 잠가 둔다.
        final submitting = state is AsyncLoading || state is AsyncSuccess;
        final canSubmit = _trimmed.isNotEmpty && !submitting;

        return CreateSheet(
          title: '초대 코드로 참여',
          dismissible: !submitting,
          children: [
            CoworkTextField(
              labelText: '초대 코드',
              hintText: '받은 초대 코드를 입력하세요',
              enabled: !submitting,
              textInputAction: TextInputAction.done,
              onChanged: (value) => setState(() => _code = value),
              onSubmitted: (_) {
                if (canSubmit) _submit(context);
              },
            ),
            if (state case AsyncFailure(:final message))
              CreateSheetError(
                title: '팀에 참여하지 못했어요',
                message: message ?? '잠시 후 다시 시도해 주세요.',
              ),
            SizedBox(
              width: double.infinity,
              child: CoworkButton(
                label: submitting ? '참여하는 중…' : '참여하기',
                size: CoworkButtonSize.large,
                enabled: canSubmit,
                onPressed: () => _submit(context),
              ),
            ),
          ],
        );
      },
    );
  }
}
