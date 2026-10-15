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
    on<ChatRefreshed>(_onRefresh);
    on<ChatTeamSelected>(_onTeamSelected);
    on<ChatChannelAdded>(_onChannelAdded);
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

  /// 팀·채널을 다시 읽어, 로딩 화면 없이 보이는 목록을 바꾼다.
  ///
  /// 보이는 목록이 있을 때만 한다. 실패하면 보이던 목록을 그대로 둔다. 사용자가
  /// 하던 일을 백그라운드 갱신 실패로 오류 화면이 가로막으면 안 되기 때문이다.
  Future<void> _onRefresh(ChatRefreshed event, Emitter<ChatState> emit) async {
    if (state is! AsyncSuccess<ChatHomeData>) return;
    final before = _teamId;
    try {
      final teams = await _repository.fetchMyTeams();
      final team =
          teams.where((team) => team.id == before).firstOrNull ??
          teams.firstOrNull;
      final channels = team == null
          ? const <Channel>[]
          : await _repository.fetchChannels(team.id);

      // 읽는 사이 다른 팀으로 옮겼다면 이 결과는 낡았다.
      if (state is! AsyncSuccess<ChatHomeData> || _teamId != before) return;
      _teams = teams;
      _teamId = team?.id;
      emit(ChatState.success(team == null ? _noTeam : _homeOf(team, channels)));
    } catch (e, s) {
      Logger.e('홈 새로고침 실패', tag: 'Chat', error: e, stackTrace: s);
    }
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

  /// 새 채널을 목록 끝에 붙인다.
  ///
  /// 서버는 새 채널을 팀의 마지막 순서로 저장하므로, 목록을 다시 읽지 않고 붙여도
  /// 서버 순서와 같다. 다시 읽으면 홈 전체가 로딩 화면으로 깜빡인다.
  void _onChannelAdded(ChatChannelAdded event, Emitter<ChatState> emit) {
    final current = state;
    if (current is! AsyncSuccess<ChatHomeData>) return;
    final team = _currentTeam();
    if (team == null) return;
    final channels = current.data.channelGroups.expand(
      (group) => group.channels,
    );
    // 새로고침이 먼저 끝나 이미 목록에 있으면 두 번 붙이지 않는다.
    if (channels.any((channel) => channel.id == event.channel.id)) return;
    emit(ChatState.success(_homeOf(team, [...channels, event.channel])));
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
