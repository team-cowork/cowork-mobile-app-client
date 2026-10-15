import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/utils/async_state.dart';
import '../../../../../core/utils/logger.dart';
import '../../../../../network/http_error_message.dart';
import '../../../data/chat_repository.dart';
import '../../../data/team_response.dart';
import '../../../domain/channel.dart';
import '../../../domain/enums/workspace_avatar_color.dart';
import '../../../domain/workspace_shortcut.dart';

part 'chat_event.dart';
part 'chat_state.dart';

/// 홈(채팅 목록) 화면 상태를 관리하는 Bloc.
///
/// 팀 목록 → 고른 팀의 채널 목록 순서로 읽는다. 두 단계 중 어디서 실패했는지를
/// 실패 사유 앞에 붙여, 팀 조회가 실패했는데 채널 문제로 보이지 않게 한다.
///
/// ponytail: 실패 단계를 문자열로 붙이는 건 임시다. 화면 제목까지 단계별로 나누는
/// 작업은 #94 에서 한다.
class ChatBloc extends Bloc<ChatEvent, ChatState> {
  ChatBloc(this._repository) : super(const ChatState.initial()) {
    on<ChatRequested>(_onLoad);
    on<ChatTeamSelected>(_onTeamSelected);
  }

  final ChatRepository _repository;

  /// 마지막으로 읽은 팀 목록. 팀을 바꿀 때는 다시 읽지 않고 여기서 고른다.
  List<TeamSummaryResponse> _teams = const [];

  /// 보고 있는 팀. 다시 시도해도 첫 팀으로 튀지 않게 기억한다.
  int? _teamId;

  /// 단축 바 아바타 색. 같은 팀이 늘 같은 색이 되도록 id 로 고른다.
  static const _avatarColors = [
    WorkspaceAvatarColor.red,
    WorkspaceAvatarColor.blue,
    WorkspaceAvatarColor.green,
  ];

  Future<void> _onLoad(ChatRequested event, Emitter<ChatState> emit) async {
    emit(const ChatState.loading());
    try {
      _teams = await _repository.fetchMyTeams();
    } catch (e, s) {
      Logger.e('팀 목록 조회 실패', tag: 'Chat', error: e, stackTrace: s);
      emit(ChatState.failure(_reasonOf('팀 목록 조회 실패', e)));
      return;
    }

    final team = _currentTeam();
    if (team == null) {
      _teamId = null;
      emit(const ChatState.success(_noTeam));
      return;
    }
    await _loadChannels(team, emit);
  }

  Future<void> _onTeamSelected(
    ChatTeamSelected event,
    Emitter<ChatState> emit,
  ) async {
    final team = _teams.where((team) => team.id == event.teamId).firstOrNull;
    if (team == null || team.id == _teamId) return;
    emit(const ChatState.loading());
    await _loadChannels(team, emit);
  }

  /// 보고 있던 팀. 그 팀에서 나갔으면 첫 팀, 팀이 없으면 null.
  TeamSummaryResponse? _currentTeam() =>
      _teams.where((team) => team.id == _teamId).firstOrNull ??
      _teams.firstOrNull;

  /// 속한 팀이 하나도 없을 때의 홈.
  static const ChatHomeData _noTeam = (
    teamId: null,
    workspaceName: '',
    workspaceShortcuts: [],
    channelGroups: [],
  );

  Future<void> _loadChannels(
    TeamSummaryResponse team,
    Emitter<ChatState> emit,
  ) async {
    _teamId = team.id;
    try {
      emit(
        ChatState.success(
          _homeOf(team, await _repository.fetchChannels(team.id)),
        ),
      );
    } catch (e, s) {
      Logger.e('채널 목록 조회 실패', tag: 'Chat', error: e, stackTrace: s);
      emit(ChatState.failure(_reasonOf('채널 목록 조회 실패', e)));
    }
  }

  /// ponytail: 서버 카테고리(프로젝트) 연동 전이라 채널을 한 그룹에 담는다.
  ChatHomeData _homeOf(TeamSummaryResponse team, List<Channel> channels) => (
    teamId: team.id,
    workspaceName: team.name,
    workspaceShortcuts: [
      for (final other in _teams)
        WorkspaceShortcut(
          id: other.id,
          initial: other.name.isEmpty ? '?' : other.name.substring(0, 1),
          color: _avatarColors[other.id % _avatarColors.length],
          isSelected: other.id == team.id,
        ),
    ],
    channelGroups: [ChannelGroup(name: '채널', channels: channels)],
  );

  /// `팀 목록 조회 실패 · (503) 서비스를 잠시 사용할 수 없습니다.` 꼴의 실패 사유.
  static String _reasonOf(String stage, Object error) =>
      '$stage · ${error is DioException ? dioErrorMessage(error) : '잠시 후 다시 시도해 주세요.'}';
}
