import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/network/chat_socket.dart';
import '../../../../../core/network/http_error_message.dart';
import '../../../../../core/utils/async_state.dart';
import '../../../../../core/utils/logger.dart';
import '../../../../../shared/utils/initial.dart';
import '../../../../profile/data/repositories/profile_repository.dart';
import '../../../../project/data/model/responses/project_summary_response.dart';
import '../../../../project/data/repositories/project_repository.dart';
import '../../../../team/data/model/responses/team_response.dart';
import '../../../../team/data/model/responses/team_summary_response.dart';
import '../../../../team/data/repositories/team_repository.dart';
import '../../../../team/domain/enums/team_permission.dart';
import '../../../data/model/channel_socket_event.dart';
import '../../../data/repositories/channel_repository.dart';
import '../../../domain/channel.dart';
import '../../../domain/enums/workspace_avatar_color.dart';
import '../../../domain/workspace_shortcut.dart';

part 'channel_list_event.dart';
part 'channel_list_state.dart';

/// 홈 화면에 보일, 고른 팀의 채널 목록을 관리하는 Bloc.
///
/// 팀 목록([TeamRepository]) → 고른 팀의 채널 목록([ChannelRepository]) 순서로
/// 읽는다. 두 단계 중 어디서 실패했는지를 실패 사유 앞에 붙여, 팀 조회가 실패했는데
/// 채널 문제로 보이지 않게 한다.
///
/// 채널은 팀의 프로젝트([ProjectRepository])별로 묶는다. 프로젝트 목록은 채널 목록과
/// 함께 읽되, 실패해도 홈을 실패로 바꾸지 않고 채널을 묶지 않은 채 보여 준다. 묶음은
/// 덤이고 채널을 못 보는 게 더 큰 손해라서다.
///
/// 읽은 뒤에는 다시 조회하지 않고, 보고 있는 팀 방을 소켓으로 구독해 다른 기기·
/// 사람이 만들고 바꾸고 지운 채널을 목록에 반영한다. 다른 사람이 나를 팀에 넣은 것은
/// 소켓 이벤트가 없어 [invitedTeams] 로 받는다.
///
/// 채널 목록과 함께 그 팀에서 내 권한도 읽어, 팀 메뉴가 할 수 없는 항목을 숨기게 한다.
///
/// ponytail: 실패 단계를 문자열로 붙이는 건 임시다. 화면 제목까지 단계별로 나누는
/// 작업은 #94 에서 한다.
class ChannelListBloc extends Bloc<ChannelListEvent, ChannelListState> {
  ChannelListBloc(
    this._teamRepository,
    this._channelRepository,
    this._projectRepository,
    this._socket, {
    required ProfileRepository profileRepository,
    Stream<int> invitedTeams = const Stream.empty(),
  }) : _profileRepository = profileRepository,
       super(const ChannelListState.initial()) {
    on<ChannelListRequested>(_onLoad);
    on<ChannelListTeamSelected>(_onTeamSelected);
    on<ChannelListTeamCreated>(_onTeamCreated);
    on<ChannelListChannelAdded>(_onChannelAdded);
    on<ChannelListProjectAdded>(_onProjectAdded);
    on<ChannelListTeamLeft>((event, emit) => _leaveTeam(event.teamId, emit));
    on<ChannelListTeamsRefreshed>(_onTeamsRefreshed);
    on<_ChannelListSocketEventReceived>(_onSocketEvent);
    on<_ChannelListReconnected>(_onReconnected);
    on<_ChannelListTeamInvited>(_onTeamInvited);

    _socketEvents = _socket.events
        .map(ChannelSocketEvent.from)
        .where((event) => event != null)
        .listen((event) => add(_ChannelListSocketEventReceived(event!)));
    _reconnects = _socket.reconnected.listen(
      (_) => add(const _ChannelListReconnected()),
    );
    _invites = invitedTeams.listen(
      (teamId) => add(_ChannelListTeamInvited(teamId)),
    );
  }

  final TeamRepository _teamRepository;
  final ChannelRepository _channelRepository;
  final ProjectRepository _projectRepository;
  final ChatSocket _socket;
  final ProfileRepository _profileRepository;
  late final StreamSubscription<ChannelSocketEvent?> _socketEvents;
  late final StreamSubscription<void> _reconnects;
  late final StreamSubscription<int> _invites;

  /// 마지막으로 읽은 팀 목록. 팀을 바꿀 때는 다시 읽지 않고 여기서 고른다.
  List<TeamSummaryResponse> _teams = const [];

  /// 보이는 채널 전체를 서버 순서(position) 그대로. 그룹은 이걸로 매번 다시 묶는다.
  ///
  /// 그룹을 펼쳐 되돌리면 그룹 순서로 섞여, 채널이 다른 그룹으로 옮겨 갈 때 서버
  /// 순서를 잃는다. 그래서 묶기 전 목록을 따로 든다.
  List<Channel> _channels = const [];

  /// 보고 있는 팀의 프로젝트. 채널을 이 순서대로 묶는다.
  List<ProjectSummaryResponse> _projects = const [];

  /// 마지막으로 시작한 프로젝트 목록 읽기 번호. 늦게 끝난 이전 읽기가 새 목록을 덮지
  /// 않도록, 끝났을 때 번호가 그대로인 읽기만 반영한다.
  int _projectsRequest = 0;

  /// 채널 목록을 읽는 동안 프로젝트가 바뀌었다. 같이 읽던 프로젝트 목록이 그 변경보다
  /// 먼저 찍혔을 수 있어, 목록을 받은 뒤 한 번 더 읽는다.
  bool _projectsChangedWhileLoading = false;

  /// 보고 있는 팀. 다시 시도해도 첫 팀으로 튀지 않게 기억한다.
  int? _teamId;

  /// 소켓으로 구독 중인 팀 방.
  int? _followedTeamId;

  /// 채널 목록을 읽는 동안 온 변경. 목록을 받은 뒤 순서대로 반영한다.
  final _pending = <ChannelListChange>[];

  /// 재연결 후 목록을 다시 읽는 동안 반영한 변경. 응답으로 목록을 바꾼 뒤 다시 반영해,
  /// 응답이 그 변경보다 먼저 찍힌 목록이어도 덮이지 않게 한다. 읽는 중이 아니면 null.
  List<ChannelListChange>? _resyncChanges;

  /// 보고 있는 팀에서 내 권한. 아직 못 읽었거나 읽기에 실패했으면 null 이다.
  Set<TeamPermission>? _permissions;

  /// 보고 있는 팀의 소유자가 나인지. 아직 못 읽었거나 읽기에 실패했으면 null 이다.
  bool? _isOwner;

  /// 단축 바 아바타 색. 같은 팀이 늘 같은 색이 되도록 id 로 고른다.
  static const _avatarColors = [
    WorkspaceAvatarColor.red,
    WorkspaceAvatarColor.blue,
    WorkspaceAvatarColor.green,
  ];

  Future<void> _onLoad(
    ChannelListRequested event,
    Emitter<ChannelListState> emit,
  ) async {
    emit(const ChannelListState.loading());
    try {
      _teams = await _teamRepository.fetchMyTeams();
    } catch (e, s) {
      Logger.e('팀 목록 조회 실패', tag: 'Chat', error: e, stackTrace: s);
      emit(ChannelListState.failure(_reasonOf('팀 목록 조회 실패', e)));
      return;
    }

    final team = _currentTeam();
    if (team == null) {
      _showNoTeam(emit);
      return;
    }
    await _loadChannels(team, emit);
  }

  /// [ChannelListTeamSelected.teamId] 팀으로 옮긴다.
  ///
  /// 알림으로 들어온 팀(새로 초대된 팀 등)은 아직 읽은 목록에 없을 수 있어 팀 목록을
  /// 다시 읽어 찾는다. 그래도 없으면(그 사이 빠진 팀) 보던 팀에 남는다.
  Future<void> _onTeamSelected(
    ChannelListTeamSelected event,
    Emitter<ChannelListState> emit,
  ) async {
    if (event.teamId == _teamId) return;
    var team = _teams.where((team) => team.id == event.teamId).firstOrNull;
    emit(const ChannelListState.loading());
    if (team == null) {
      try {
        _teams = await _teamRepository.fetchMyTeams();
      } catch (e, s) {
        Logger.e('팀 목록 조회 실패', tag: 'Chat', error: e, stackTrace: s);
        emit(ChannelListState.failure(_reasonOf('팀 목록 조회 실패', e)));
        return;
      }
      team =
          _teams.where((team) => team.id == event.teamId).firstOrNull ??
          _currentTeam();
      if (team == null) {
        _showNoTeam(emit);
        return;
      }
    }
    await _loadChannels(team, emit);
  }

  /// 새로 만든 팀으로 옮긴다.
  ///
  /// 서버는 팀을 만들 때 채널을 만들지 않으므로 채널 목록을 읽지 않고 빈 목록으로
  /// 보여준다. 만든 직후엔 채널 서비스가 아직 새 팀 멤버십을 모를 수 있어(이벤트로
  /// 전파된다) 바로 읽으면 403 이 날 수 있다는 점도 있다.
  void _onTeamCreated(
    ChannelListTeamCreated event,
    Emitter<ChannelListState> emit,
  ) {
    final team = event.team;
    _teams = [..._teams.where((other) => other.id != team.id), team];
    _teamId = team.id;
    _resetProjects();
    // 권한도 읽지 않는다. 모르면 메뉴를 다 보이고 서버가 막게 둔다.
    _permissions = null;
    // 만든 사람이 소유자가 된다.
    _isOwner = true;
    _follow(team.id);
    emit(ChannelListState.success(_homeOf(team, const [])));
  }

  /// 새 채널을 목록 끝에 붙인다.
  ///
  /// 서버는 새 채널을 팀의 마지막 순서로 저장하므로, 목록을 다시 읽지 않고 붙여도
  /// 서버 순서와 같다. 다시 읽으면 홈 전체가 로딩 화면으로 깜빡인다.
  void _onChannelAdded(
    ChannelListChannelAdded event,
    Emitter<ChannelListState> emit,
  ) {
    final teamId = _teamId;
    if (teamId == null) return;
    // 소켓으로 온 변경과 같은 경로로 반영해, 다시 읽는 동안이면 함께 지켜진다.
    _apply(ChannelUpserted(teamId: teamId, channel: event.channel), emit);
  }

  /// 프로젝트 생성 시트가 서버에 만든 프로젝트를 빈 그룹으로 붙인다.
  ///
  /// 서버는 새 프로젝트를 팀의 마지막 순서로 둔다. 곧 올 `project:created` 가 목록을
  /// 다시 읽어 맞춘다.
  void _onProjectAdded(
    ChannelListProjectAdded event,
    Emitter<ChannelListState> emit,
  ) {
    if (_teamId == null) return;
    // 이 프로젝트가 없던 때 시작한 읽기가 늦게 와서 지우지 않게 한다.
    _projectsRequest++;
    _projects = [
      ..._projects.where((project) => project.id != event.project.id),
      event.project,
    ];
    _editChannels(emit, (channels) => channels);
  }

  Future<void> _onSocketEvent(
    _ChannelListSocketEventReceived event,
    Emitter<ChannelListState> emit,
  ) async {
    switch (event.event) {
      case final ChannelListChange change
          when state is AsyncLoading<ChannelListData>:
        // 목록을 읽는 중이라 고칠 목록이 없다. 받은 뒤 [_loadChannels] 가 반영한다.
        _pending.add(change);
      case final ChannelListChange change:
        _apply(change, emit);
      case TeamAccessRevoked(:final teamId):
        await _leaveTeam(teamId, emit);
      case ProjectsChanged(:final teamId) when teamId == _teamId:
        if (state is AsyncLoading<ChannelListData>) {
          _projectsChangedWhileLoading = true;
        } else {
          await _refreshProjects(emit);
        }
      case ProjectsChanged():
        // 다른 팀의 프로젝트다. 그 팀으로 옮길 때 새로 읽는다.
        break;
    }
  }

  /// 소켓이 끊김 복구(2분) 없이 다시 붙었다. 끊긴 동안 생기거나 바뀌거나 지워진 채널,
  /// 빠진 팀은 이벤트로 오지 않으므로 내 팀 목록과 보고 있는 팀의 채널 목록을 다시 읽어
  /// 맞춘다.
  ///
  /// 화면을 로딩으로 바꾸지 않고 목록만 갈아 끼운다. 목록이 없거나(읽는 중·실패) 다시
  /// 읽는 사이 다른 팀으로 옮겼다면 하지 않는다. 읽기에 실패하면 보던 목록을 둔다.
  /// 읽는 사이 소켓으로 온 변경은 응답으로 바꾼 뒤 다시 반영한다.
  Future<void> _onReconnected(
    _ChannelListReconnected event,
    Emitter<ChannelListState> emit,
  ) async {
    final team = _currentTeam();
    if (state is! AsyncSuccess<ChannelListData> || team == null) return;

    final changes = _resyncChanges = <ChannelListChange>[];
    final List<TeamSummaryResponse> teams;
    final List<Channel> channels;
    final List<ProjectSummaryResponse>? projects;
    // 끊긴 동안 바뀐 프로젝트도 이벤트로 오지 않는다. 채널과 함께 다시 읽는다.
    final projectsRequest = _fetchProjects(team.id);
    try {
      // 403 만 보고 팀에서 빠졌다고 판단하면 막 만든 팀의 일시적인 403 에도 팀을 떠나
      // 버리므로, 팀 목록으로 확인한다.
      teams = await _teamRepository.fetchMyTeams();
      if (!teams.any((other) => other.id == team.id)) {
        if (isClosed || team.id != _teamId) return;
        // 끊긴 동안 팀에서 빠졌다. team:access:revoked 를 받은 것과 같게 처리한다.
        _resyncChanges = null;
        await _leaveTeam(team.id, emit);
        return;
      }
      channels = await _channelRepository.fetchChannels(team.id);
      // 기다리는 것은 모두 여기서 끝낸다. 아래 확인과 화면 갱신 사이에 기다림이 끼면 그
      // 사이 다른 팀으로 옮겨도 옛 팀 화면을 내보내고, [_resyncChanges] 가 이미 비워져
      // 그 사이 온 변경을 응답으로 덮어 잃는다. 실패해도 던지지 않는다.
      projects = await projectsRequest;
    } catch (e, s) {
      Logger.e('재연결 후 채널 목록 조회 실패', tag: 'Chat', error: e, stackTrace: s);
      return;
    } finally {
      if (identical(_resyncChanges, changes)) _resyncChanges = null;
    }
    if (isClosed || team.id != _teamId) return;
    if (state is! AsyncSuccess<ChannelListData>) return;

    _teams = teams;
    _applyProjects(projects);
    emit(
      ChannelListState.success(
        _homeOf(teams.firstWhere((other) => other.id == team.id), channels),
      ),
    );
    // 같은 변경이 응답에 이미 들어 있어도 upsert·삭제라 다시 반영해도 결과가 같다.
    for (final change in changes) {
      _apply(change, emit);
    }
  }

  /// 팀 설정에서 돌아왔다. 이름이 바뀌었거나 팀이 지워졌을 수 있어 팀 목록만 다시 읽는다.
  ///
  /// 화면을 로딩으로 바꾸지 않고 팀 이름·단축 바만 바꾼다. 보던 팀이 목록에 없으면
  /// 다른 팀으로 옮긴다. 읽기에 실패하면 보던 화면을 둔다.
  Future<void> _onTeamsRefreshed(
    ChannelListTeamsRefreshed event,
    Emitter<ChannelListState> emit,
  ) async {
    final teamId = _teamId;
    if (state is! AsyncSuccess<ChannelListData> || teamId == null) return;

    final List<TeamSummaryResponse> teams;
    try {
      teams = await _teamRepository.fetchMyTeams();
    } catch (e, s) {
      Logger.e('팀 목록 다시 읽기 실패', tag: 'Chat', error: e, stackTrace: s);
      return;
    }
    // 기다리는 사이 다른 팀으로 옮겼으면 그쪽이 읽은 목록이 더 새롭다.
    if (isClosed || teamId != _teamId) return;

    _teams = teams;
    if (teams.any((team) => team.id == teamId)) {
      _editChannels(emit, (channels) => channels);
    } else {
      await _leaveTeam(teamId, emit);
    }
  }

  /// 다른 사람이 나를 [_ChannelListTeamInvited.teamId] 팀에 바로 넣었다(알림
  /// `MEMBER_INVITED`). 팀 목록을 다시 읽어 그 팀을 보이게 한다.
  ///
  /// 팀이 없던 홈이면 그 팀으로 들어간다. 빈 화면이 초대받으면 여기에 보인다고
  /// 안내하기 때문이다. 보던 팀이 있으면 보던 화면은 두고 단축 바에만 붙인다.
  ///
  /// 목록이 없으면(읽는 중·실패) 하지 않는다. 그 읽기나 다시 시도가 새 팀까지 읽는다.
  /// 다시 읽기에 실패해도 보던 화면은 그대로 둔다.
  Future<void> _onTeamInvited(
    _ChannelListTeamInvited event,
    Emitter<ChannelListState> emit,
  ) async {
    if (state is! AsyncSuccess<ChannelListData>) return;
    if (_teams.any((team) => team.id == event.teamId)) return;

    final List<TeamSummaryResponse> teams;
    try {
      teams = await _teamRepository.fetchMyTeams();
    } catch (e, s) {
      Logger.e('초대받은 팀 목록 조회 실패', tag: 'Chat', error: e, stackTrace: s);
      return;
    }
    if (isClosed || state is! AsyncSuccess<ChannelListData>) return;

    final viewing = _teamId;
    if (viewing == null) {
      _teams = teams;
      final next =
          teams.where((team) => team.id == event.teamId).firstOrNull ??
          teams.firstOrNull;
      if (next == null) return;
      emit(const ChannelListState.loading());
      await _loadChannels(next, emit);
      return;
    }
    // 읽는 사이 만든 팀이 아직 응답에 없으면, 지금 보는 팀을 잃고 다른 팀 이름으로
    // 그려진다. 그런 낡은 응답은 버린다. 정말 빠진 팀은 소켓·재연결이 처리한다.
    if (!teams.any((team) => team.id == viewing)) return;
    _teams = teams;
    // 채널은 그대로 두고 단축 바만 다시 그린다.
    _editChannels(emit, (channels) => channels);
  }

  void _apply(ChannelListChange change, Emitter<ChannelListState> emit) {
    _resyncChanges?.add(change);
    switch (change) {
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
    }
  }

  /// 같은 id 가 있으면 그 자리에서 바꾸고, 없으면 끝에 붙인다.
  ///
  /// 내가 만든 채널은 시트 결과와 `channel:created` 이벤트로 두 번 오므로 id 로
  /// 하나만 남긴다.
  void _upsert(Channel channel, Emitter<ChannelListState> emit) =>
      _editChannels(
        emit,
        (channels) => channels.any((other) => other.id == channel.id)
            ? [
                for (final other in channels)
                  other.id == channel.id ? channel : other,
              ]
            : [...channels, channel],
      );

  /// 내가 [teamId] 팀에서 빠졌다. 보던 팀이면 다른 팀으로 옮긴다.
  Future<void> _leaveTeam(int teamId, Emitter<ChannelListState> emit) async {
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
    emit(const ChannelListState.loading());
    await _loadChannels(next, emit);
  }

  /// 보이는 채널 목록을 [edit] 결과로 바꾼다. 보이는 목록이 없으면 하지 않는다.
  void _editChannels(
    Emitter<ChannelListState> emit,
    List<Channel> Function(List<Channel> channels) edit,
  ) {
    final current = state;
    if (current is! AsyncSuccess<ChannelListData>) return;
    final team = _currentTeam();
    if (team == null) return;
    emit(ChannelListState.success(_homeOf(team, edit(_channels))));
  }

  /// 보고 있던 팀. 그 팀에서 나갔으면 첫 팀, 팀이 없으면 null.
  TeamSummaryResponse? _currentTeam() =>
      _teams.where((team) => team.id == _teamId).firstOrNull ??
      _teams.firstOrNull;

  /// 속한 팀이 하나도 없을 때의 홈.
  static const ChannelListData _noTeam = (
    teamId: null,
    workspaceName: '',
    isTeamOwner: false,
    canInviteMembers: false,
    canCreateChannels: false,
    canCreateProjects: false,
    workspaceShortcuts: [],
    channelGroups: [],
  );

  void _showNoTeam(Emitter<ChannelListState> emit) {
    _teamId = null;
    _channels = const [];
    _resetProjects();
    _follow(null);
    emit(const ChannelListState.success(_noTeam));
  }

  Future<void> _loadChannels(
    TeamSummaryResponse team,
    Emitter<ChannelListState> emit,
  ) async {
    _teamId = team.id;
    // 목록을 읽는 사이에 생긴 변경도 받도록 읽기 전에 구독한다. 그 사이 온 변경은
    // [_pending] 에 모인다. 이전 팀을 읽는 동안 모인 것은 이 팀과 관계없어 버린다.
    _pending.clear();
    _follow(team.id);
    _resetProjects();
    _projectsChangedWhileLoading = false;
    // 채널 목록과 같이 읽는다. 실패해도 던지지 않으므로 채널이 먼저 실패해도 남은
    // Future 가 처리되지 않은 오류가 되지 않는다.
    final projects = _fetchProjects(team.id);
    // 내 권한은 채널 목록과 같이 읽는다. 실패해도 던지지 않는다.
    _permissions = null;
    _isOwner = null;
    final accessRequest = _fetchAccess(team.id);

    final List<Channel> channels;
    try {
      channels = await _channelRepository.fetchChannels(team.id);
    } catch (e, s) {
      Logger.e('채널 목록 조회 실패', tag: 'Chat', error: e, stackTrace: s);
      if (team.id == _teamId) {
        emit(ChannelListState.failure(_reasonOf('채널 목록 조회 실패', e)));
      }
      return;
    }
    final access = await accessRequest;
    // 기다리는 사이 다른 팀으로 옮겼다면(팀에서 빠져 다음 팀을 읽는 등) 늦게 온 이
    // 응답이 지금 팀 화면을 덮지 않게 버린다.
    if (team.id != _teamId) return;
    _applyProjects(await projects);
    if (isClosed || team.id != _teamId) return;

    _permissions = access.permissions;
    _isOwner = access.isOwner;
    emit(ChannelListState.success(_homeOf(team, channels)));
    // 같은 변경이 목록에 이미 들어 있어도 upsert·삭제라 다시 반영해도 결과가 같다.
    final pending = [..._pending];
    _pending.clear();
    for (final change in pending) {
      _apply(change, emit);
    }
    if (_projectsChangedWhileLoading) {
      _projectsChangedWhileLoading = false;
      await _refreshProjects(emit);
    }
  }

  /// [teamId] 팀의 프로젝트 목록을 읽는다. 실패하면 로그를 남기고 null 을 준다.
  ///
  /// 끝났을 때 이보다 나중에 시작한 읽기가 있거나 다른 팀으로 옮겼어도 null 이다.
  Future<List<ProjectSummaryResponse>?> _fetchProjects(int teamId) async {
    final request = ++_projectsRequest;
    final List<ProjectSummaryResponse> projects;
    try {
      projects = await _projectRepository.fetchTeamProjects(teamId);
    } catch (e, s) {
      // 프로젝트 없이도 채널은 보여 줄 수 있어 홈을 실패로 바꾸지 않는다.
      Logger.e('프로젝트 목록 조회 실패', tag: 'Chat', error: e, stackTrace: s);
      return null;
    }
    if (request != _projectsRequest || teamId != _teamId) return null;
    return projects;
  }

  /// 읽은 프로젝트 목록을 반영한다. null(실패·낡은 응답)이면 보던 목록을 둔다.
  void _applyProjects(List<ProjectSummaryResponse>? projects) {
    if (projects != null) _projects = projects;
  }

  /// 프로젝트 목록만 다시 읽어 그룹을 다시 묶는다. 화면을 로딩으로 바꾸지 않는다.
  Future<void> _refreshProjects(Emitter<ChannelListState> emit) async {
    final teamId = _teamId;
    if (teamId == null) return;
    final projects = await _fetchProjects(teamId);
    if (isClosed || projects == null) return;
    _applyProjects(projects);
    _editChannels(emit, (channels) => channels);
  }

  /// 팀이 바뀌었다. 이전 팀의 프로젝트와 진행 중인 읽기를 버린다.
  void _resetProjects() {
    _projects = const [];
    _projectsRequest++;
  }

  /// [teamId] 팀의 소유자가 나인지와 내 권한. 못 읽은 값은 null 이다.
  ///
  /// 소유자인지는 팀 상세의 `ownerId` 로 본다. 팀 설정 화면과 같은 기준이다.
  /// 둘 다 메뉴 항목을 숨기는 데만 쓰고 서버가 다시 검사하므로, 못 읽었다고 홈을
  /// 실패로 만들지 않는다.
  Future<({bool? isOwner, Set<TeamPermission>? permissions})> _fetchAccess(
    int teamId,
  ) async {
    final TeamResponse team;
    final int myId;
    try {
      final teamRequest = _teamRepository.fetchTeam(teamId);
      final myIdRequest = _profileRepository.fetchMyId();
      await Future.wait([teamRequest, myIdRequest], eagerError: true);
      team = await teamRequest;
      myId = await myIdRequest;
    } catch (e, s) {
      Logger.e('팀 상세 조회 실패', tag: 'Chat', error: e, stackTrace: s);
      return (isOwner: null, permissions: null);
    }
    final isOwner = team.isOwnedBy(myId);
    try {
      final permissions = await _teamRepository.fetchMyPermissions(
        team,
        userId: myId,
      );
      return (isOwner: isOwner, permissions: permissions);
    } catch (e, s) {
      Logger.e('팀 권한 조회 실패', tag: 'Chat', error: e, stackTrace: s);
      return (isOwner: isOwner, permissions: null);
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
    await _reconnects.cancel();
    await _invites.cancel();
    return super.close();
  }

  /// [team] 홈 화면 데이터. 채널은 [_groupsOf] 로 묶는다.
  ///
  /// 묶기 전 [channels] 는 다음 변경에 쓰도록 [_channels] 에 남긴다.
  ChannelListData _homeOf(TeamSummaryResponse team, List<Channel> channels) {
    _channels = channels;
    return _homeData(team, channels);
  }

  ChannelListData _homeData(TeamSummaryResponse team, List<Channel> channels) =>
      (
        teamId: team.id,
        workspaceName: team.name,
        // 모르면 소유자가 아니라고 본다. 나가기가 보이고, 소유자면 서버가 막는다.
        isTeamOwner: _isOwner ?? false,
        // 권한을 모르면 보인다. 숨겨서 쓸 수 있는 사람이 못 쓰는 것보다, 보이고 서버가
        // 막는 쪽(초대 화면의 403 안내)이 낫다.
        canInviteMembers:
            _permissions?.contains(TeamPermission.manageInvites) ?? true,
        canCreateChannels:
            _permissions?.contains(TeamPermission.manageChannels) ?? true,
        canCreateProjects:
            _permissions?.contains(TeamPermission.manageProjects) ?? true,
        workspaceShortcuts: [
          for (final other in _teams)
            WorkspaceShortcut(
              id: other.id,
              initial: initialOf(other.name),
              color: _avatarColors[other.id % _avatarColors.length],
              isSelected: other.id == team.id,
            ),
        ],
        channelGroups: _groupsOf(channels),
      );

  /// 채널을 프로젝트 순서대로 묶고, 어느 프로젝트에도 속하지 않은 채널은 맨 끝
  /// `채널` 그룹에 둔다. (웹 사이드바와 같은 순서)
  ///
  /// 채널이 없는 프로젝트도 빈 그룹으로 둬 그 프로젝트에 채널을 만들 수 있게 한다.
  /// 목록에 없는 프로젝트(볼 수 없거나 아직 못 읽은)의 채널은 이름 없는 그룹을 만들지
  /// 않고 `채널` 그룹에 둔다.
  List<ChannelGroup> _groupsOf(List<Channel> channels) {
    final known = {for (final project in _projects) project.id};
    return [
      for (final project in _projects)
        ChannelGroup(
          name: project.name,
          projectId: project.id,
          channels: [
            for (final channel in channels)
              if (channel.projectId == project.id) channel,
          ],
        ),
      ChannelGroup(
        name: '채널',
        channels: [
          for (final channel in channels)
            if (!known.contains(channel.projectId)) channel,
        ],
      ),
    ];
  }

  /// `팀 목록 조회 실패 · (503) 서비스를 잠시 사용할 수 없습니다.` 꼴의 실패 사유.
  static String _reasonOf(String stage, Object error) =>
      '$stage · ${failureMessageOf(error, '잠시 후 다시 시도해 주세요.')}';
}
