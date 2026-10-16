import 'dart:async';

import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/utils/async_state.dart';
import '../../../../../core/utils/logger.dart';
import '../../../../../network/chat_socket.dart';
import '../../../../../network/http_error_message.dart';
import '../../../data/model/channel_socket_event.dart';
import '../../../data/repositories/chat_repository.dart';
import '../../../data/model/responses/team_summary_response.dart';
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
/// 읽은 뒤에는 다시 조회하지 않고, 보고 있는 팀 방을 소켓으로 구독해 다른 기기·
/// 사람이 만들고 바꾸고 지운 채널을 목록에 반영한다.
///
/// ponytail: 실패 단계를 문자열로 붙이는 건 임시다. 화면 제목까지 단계별로 나누는
/// 작업은 #94 에서 한다.
class ChatBloc extends Bloc<ChatEvent, ChatState> {
  ChatBloc(this._repository, this._socket) : super(const ChatState.initial()) {
    on<ChatRequested>(_onLoad);
    on<ChatTeamSelected>(_onTeamSelected);
    on<ChatTeamCreated>(_onTeamCreated);
    on<ChatChannelAdded>(_onChannelAdded);
    on<_ChatSocketEventReceived>(_onSocketEvent);

    _socketEvents = _socket.events
        .map(ChannelSocketEvent.from)
        .where((event) => event != null)
        .listen((event) => add(_ChatSocketEventReceived(event!)));
  }

  final ChatRepository _repository;
  final ChatSocket _socket;
  late final StreamSubscription<ChannelSocketEvent?> _socketEvents;

  /// 마지막으로 읽은 팀 목록. 팀을 바꿀 때는 다시 읽지 않고 여기서 고른다.
  List<TeamSummaryResponse> _teams = const [];

  /// 보고 있는 팀. 다시 시도해도 첫 팀으로 튀지 않게 기억한다.
  int? _teamId;

  /// 소켓으로 구독 중인 팀 방.
  int? _followedTeamId;

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
      _showNoTeam(emit);
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

  /// 새로 만든 팀으로 옮긴다.
  ///
  /// 서버는 팀을 만들 때 채널을 만들지 않으므로 채널 목록을 읽지 않고 빈 목록으로
  /// 보여준다. 만든 직후엔 채널 서비스가 아직 새 팀 멤버십을 모를 수 있어(이벤트로
  /// 전파된다) 바로 읽으면 403 이 날 수 있다는 점도 있다.
  void _onTeamCreated(ChatTeamCreated event, Emitter<ChatState> emit) {
    final team = event.team;
    _teams = [..._teams.where((other) => other.id != team.id), team];
    _teamId = team.id;
    _follow(team.id);
    emit(ChatState.success(_homeOf(team, const [])));
  }

  /// 새 채널을 목록 끝에 붙인다.
  ///
  /// 서버는 새 채널을 팀의 마지막 순서로 저장하므로, 목록을 다시 읽지 않고 붙여도
  /// 서버 순서와 같다. 다시 읽으면 홈 전체가 로딩 화면으로 깜빡인다.
  void _onChannelAdded(ChatChannelAdded event, Emitter<ChatState> emit) =>
      _upsert(event.channel, emit);

  Future<void> _onSocketEvent(
    _ChatSocketEventReceived event,
    Emitter<ChatState> emit,
  ) async {
    switch (event.event) {
      case ChannelUpserted(:final teamId, :final channel):
        if (teamId == _teamId) _upsert(channel, emit);
      case ChannelRemoved(:final channelId):
        _editChannels(
          emit,
          (channels) => [
            for (final channel in channels)
              if (channel.id != channelId) channel,
          ],
        );
      case TeamAccessRevoked(:final teamId):
        await _leaveTeam(teamId, emit);
    }
  }

  /// 같은 id 가 있으면 그 자리에서 바꾸고, 없으면 끝에 붙인다.
  ///
  /// 내가 만든 채널은 시트 결과와 `channel:created` 이벤트로 두 번 오므로 id 로
  /// 하나만 남긴다.
  void _upsert(Channel channel, Emitter<ChatState> emit) => _editChannels(
    emit,
    (channels) => channels.any((other) => other.id == channel.id)
        ? [
            for (final other in channels)
              other.id == channel.id ? channel : other,
          ]
        : [...channels, channel],
  );

  /// 내가 [teamId] 팀에서 빠졌다. 보던 팀이면 다른 팀으로 옮긴다.
  Future<void> _leaveTeam(int teamId, Emitter<ChatState> emit) async {
    _teams = [
      for (final team in _teams)
        if (team.id != teamId) team,
    ];
    if (teamId != _teamId) {
      // 단축 바에서 그 팀만 뺀다.
      _editChannels(emit, (channels) => channels);
      return;
    }

    final next = _teams.firstOrNull;
    if (next == null) {
      _showNoTeam(emit);
      return;
    }
    emit(const ChatState.loading());
    await _loadChannels(next, emit);
  }

  /// 보이는 채널 목록을 [edit] 결과로 바꾼다. 보이는 목록이 없으면 하지 않는다.
  void _editChannels(
    Emitter<ChatState> emit,
    List<Channel> Function(List<Channel> channels) edit,
  ) {
    final current = state;
    if (current is! AsyncSuccess<ChatHomeData>) return;
    final team = _currentTeam();
    if (team == null) return;
    final channels = [
      for (final group in current.data.channelGroups) ...group.channels,
    ];
    emit(ChatState.success(_homeOf(team, edit(channels))));
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

  void _showNoTeam(Emitter<ChatState> emit) {
    _teamId = null;
    _follow(null);
    emit(const ChatState.success(_noTeam));
  }

  Future<void> _loadChannels(
    TeamSummaryResponse team,
    Emitter<ChatState> emit,
  ) async {
    _teamId = team.id;
    // 목록을 읽는 사이에 생긴 변경도 받도록 읽기 전에 구독한다.
    _follow(team.id);
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

  /// 소켓 구독을 [teamId] 팀 방 하나로 맞춘다. null 이면 모두 나간다.
  void _follow(int? teamId) {
    if (teamId == _followedTeamId) return;
    final previous = _followedTeamId;
    if (previous != null) _socket.leaveTeam(previous);
    if (teamId != null) _socket.joinTeam(teamId);
    _followedTeamId = teamId;
  }

  @override
  Future<void> close() async {
    // 방 구독부터 끊는다. 구독 취소(cancel)는 비동기라 기다리는 동안 이벤트가 더 온다.
    _follow(null);
    await _socketEvents.cancel();
    return super.close();
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
