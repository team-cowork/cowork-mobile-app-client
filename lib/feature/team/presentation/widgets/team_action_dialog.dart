import 'package:cowork_design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/async_state.dart';
import '../../../../core/utils/command_bloc.dart';

/// 다이얼로그가 보내는 요청 하나를 실행하는 [CommandBloc].
typedef _Action = CommandBloc<void, void>;

/// 확인을 받고 되돌릴 수 없는 팀 요청(팀 나가기·팀 삭제) 하나를 보내는 다이얼로그.
///
/// 확인만 받고 닫은 뒤 보내면 실패를 알릴 곳이 마땅치 않다. 그래서 다이얼로그 안에서
/// 보내고, 보내는 동안은 버튼과 닫기를 잠근다. 실패하면 본문 자리에 사유를 보여 다시
/// 누를 수 있게 두고, 성공해야 닫힌다.
class TeamActionDialog extends StatelessWidget {
  const TeamActionDialog({
    required this.title,
    required this.message,
    required this.confirmLabel,
    required this.runningLabel,
    required this.failureTitle,
    super.key,
  });

  final String title;

  /// 무엇이 사라지는지 알리는 본문.
  final String message;

  final String confirmLabel;

  /// 보내는 동안 확인 버튼에 보일 문구. (예: `나가는 중…`)
  final String runningLabel;

  /// 실패했을 때 본문 첫 줄. 둘째 줄에 사유가 붙는다.
  final String failureTitle;

  /// 다이얼로그를 띄우고 [action] 이 성공하면 true 를 돌려준다. 취소하면 false.
  static Future<bool> show(
    BuildContext context, {
    required String title,
    required String message,
    required String confirmLabel,
    required String runningLabel,
    required String failureTitle,
    required Future<void> Function() action,
  }) async =>
      await showDialog<bool>(
        context: context,
        builder: (_) => BlocProvider(
          create: (_) => _Action((_) => action(), tag: 'Team'),
          child: TeamActionDialog(
            title: title,
            message: message,
            confirmLabel: confirmLabel,
            runningLabel: runningLabel,
            failureTitle: failureTitle,
          ),
        ),
      ) ??
      false;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<_Action, AsyncState<void>>(
      listener: (context, state) {
        if (state is AsyncSuccess) Navigator.of(context).pop(true);
      },
      builder: (context, state) {
        // 성공 직후 닫히기 전 한 프레임도 잠가 둔다.
        final running = state is AsyncLoading || state is AsyncSuccess;
        return PopScope(
          canPop: !running,
          child: CoworkDialog(
            title: title,
            message: switch (state) {
              AsyncFailure(:final message) =>
                '$failureTitle\n${message ?? '잠시 후 다시 시도해 주세요.'}',
              _ => message,
            },
            confirmLabel: running ? runningLabel : confirmLabel,
            cancelLabel: '취소',
            confirmColor: CoworkButtonColor.danger,
            onCancel: running ? null : () => Navigator.of(context).pop(false),
            onConfirm: running
                ? null
                : () => context.read<_Action>().add(
                    const CommandEvent<void>.run(null),
                  ),
          ),
        );
      },
    );
  }
}
