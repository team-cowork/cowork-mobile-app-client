import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/network/http_error_message.dart';
import '../../../../../core/utils/async_state.dart';
import '../../../../../core/utils/logger.dart';
import '../../../data/model/responses/invite_response.dart';
import '../../../data/repositories/team_repository.dart';

part 'invite_codes_event.dart';
part 'invite_codes_state.dart';

/// [teamId] 팀에서 지금 쓸 수 있는 초대 코드 목록을 관리하는 Bloc.
///
/// 만료·무효화된 코드는 서버 목록에 섞여 오지만 더 할 수 있는 게 없어 빼고, 최신순으로
/// 둔다. 코드를 만드는 요청은 화면의 `CommandBloc` 이 보내고 결과만
/// [InviteCodeAdded] 로 받는다.
///
/// 목록 조회부터 서버가 `manage_invites` 권한을 확인하므로, 목록이 403 이면 이 팀에서
/// 초대할 권한이 없다는 뜻이다. 화면은 이 실패를 그대로 보여 준다.
class InviteCodesBloc extends Bloc<InviteCodesEvent, InviteCodesState> {
  InviteCodesBloc(this._repository, {required this.teamId})
    : super(const InviteCodesState.initial()) {
    on<InviteCodesRequested>(_onLoad);
    on<InviteCodeAdded>(_onAdded);
    on<InviteCodeRevokeRequested>(_onRevoke);
  }

  final TeamRepository _repository;
  final int teamId;

  final _failures = StreamController<String>.broadcast();

  /// 목록은 그대로 두고 한 번만 알릴 실패 문구. 화면이 SnackBar 로 띄운다.
  Stream<String> get failures => _failures.stream;

  Future<void> _onLoad(
    InviteCodesRequested event,
    Emitter<InviteCodesState> emit,
  ) async {
    emit(const InviteCodesState.loading());
    try {
      final invites = await _repository.fetchInvites(teamId);
      emit(InviteCodesState.success(_usable(invites)));
    } catch (e, s) {
      Logger.e('초대 코드 조회 실패', tag: 'Team', error: e, stackTrace: s);
      emit(InviteCodesState.failure(failureMessageOf(e)));
    }
  }

  /// 새로 만든 코드를 맨 위에 붙인다. 목록을 다시 읽으면 화면이 로딩으로 깜빡인다.
  void _onAdded(InviteCodeAdded event, Emitter<InviteCodesState> emit) {
    if (state case AsyncSuccess(:final data)) {
      emit(InviteCodesState.success(_usable([event.invite, ...data])));
    }
  }

  /// 서버에서 무효화한 뒤 목록에서 뺀다. 실패하면 목록은 두고 [failures] 로 알린다.
  Future<void> _onRevoke(
    InviteCodeRevokeRequested event,
    Emitter<InviteCodesState> emit,
  ) async {
    final code = event.inviteCode;
    try {
      await _repository.revokeInvite(teamId, code);
    } catch (e, s) {
      Logger.e('초대 코드 무효화 실패', tag: 'Team', error: e, stackTrace: s);
      // 기다리는 사이 화면을 떠났으면 [failures] 도 닫혀 있다.
      if (!isClosed) {
        _failures.add(failureMessageOf(e) ?? '초대 코드를 무효화하지 못했어요.');
      }
      return;
    }
    // 기다리는 사이 목록이 바뀌었을 수 있으니(새 코드 추가) 지금 목록에서 뺀다.
    if (state case AsyncSuccess(:final data)) {
      emit(
        InviteCodesState.success([
          for (final invite in data)
            if (invite.inviteCode != code) invite,
        ]),
      );
    }
  }

  /// 쓸 수 있는 코드만 최신순으로. 같은 코드가 두 번 오면 앞의 것만 둔다.
  static List<InviteResponse> _usable(List<InviteResponse> invites) {
    final seen = <String>{};
    final usable = [
      for (final invite in invites)
        if (!invite.expired && seen.add(invite.inviteCode)) invite,
    ];
    // 시각을 못 읽은 코드는 뒤로 보낸다. sort 는 안정 정렬이라 같은 값끼리는 순서가
    // 그대로다.
    final epoch = DateTime.fromMillisecondsSinceEpoch(0);
    usable.sort(
      (a, b) => (b.createdAt ?? epoch).compareTo(a.createdAt ?? epoch),
    );
    return usable;
  }

  @override
  Future<void> close() async {
    await _failures.close();
    return super.close();
  }
}
