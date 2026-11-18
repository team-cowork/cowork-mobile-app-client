import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/network/http_error_message.dart';
import '../../../../../core/utils/async_state.dart';
import '../../../../../core/utils/logger.dart';
import '../../../../profile/data/repositories/profile_repository.dart';
import '../../../data/model/requests/update_team_request.dart';
import '../../../data/repositories/team_repository.dart';
import '../../../domain/enums/team_permission.dart';
import '../../../domain/team_settings.dart';

part 'team_settings_event.dart';
part 'team_settings_state.dart';

/// 팀 설정 화면 상태를 관리하는 Bloc.
///
/// 팀 정보와 함께 팀에서 내 권한을 읽어, 화면이 바꿀 수 없는 항목은 아예 보이지 않게
/// 한다. 소유자는 모두 할 수 있고, 그 밖의 멤버는 역할 권한으로 정한다
/// ([TeamRepository.fetchMyPermissions]).
///
/// 이름·설명·아이콘 삭제는 먼저 화면에 반영하고 서버에 보낸다. 실패하면 그 값만 이전으로
/// 되돌리고 사유를 알린다. 아이콘 업로드는 서버가 준 URL 이 있어야 보일 수 있어, 올리는
/// 동안 표시만 하고 끝난 뒤 바꾼다.
class TeamSettingsBloc extends Bloc<TeamSettingsEvent, TeamSettingsState> {
  TeamSettingsBloc({
    required this.teamId,
    required TeamRepository teamRepository,
    required ProfileRepository profileRepository,
  }) : _teamRepository = teamRepository,
       _profileRepository = profileRepository,
       super(const TeamSettingsState.initial()) {
    on<TeamSettingsRequested>(_onLoad);
    on<TeamSettingsNameChanged>(_onNameChanged);
    on<TeamSettingsDescriptionChanged>(_onDescriptionChanged);
    on<TeamSettingsIconPicked>(_onIconPicked);
    on<TeamSettingsIconRemoved>(_onIconRemoved);
  }

  final int teamId;
  final TeamRepository _teamRepository;
  final ProfileRepository _profileRepository;

  Future<void> _onLoad(
    TeamSettingsRequested event,
    Emitter<TeamSettingsState> emit,
  ) async {
    emit(const TeamSettingsState.loading());
    try {
      final teamRequest = _teamRepository.fetchTeam(teamId);
      final myIdRequest = _profileRepository.fetchMyId();
      // 둘은 같이 보내고, 하나라도 실패하면 그 예외를 그대로 받는다.
      await Future.wait([teamRequest, myIdRequest], eagerError: true);
      final team = await teamRequest;
      final myId = await myIdRequest;
      // 소유자인지는 팀 상세로 안다. 소유자면 역할을 읽지 않는다.
      final permissions = await _teamRepository.fetchMyPermissions(
        team,
        userId: myId,
      );

      emit(
        TeamSettingsState.success(
          TeamSettingsData(
            settings: TeamSettings(
              name: team.name,
              description: team.description ?? '',
              iconUrl: team.iconUrl,
              canManage: permissions.contains(TeamPermission.manageTeam),
              canDelete: permissions.contains(TeamPermission.deleteTeam),
            ),
          ),
        ),
      );
    } catch (e, s) {
      Logger.e('팀 설정 조회 실패', tag: 'TeamSettings', error: e, stackTrace: s);
      emit(TeamSettingsState.failure(failureMessageOf(e)));
    }
  }

  Future<void> _onNameChanged(
    TeamSettingsNameChanged event,
    Emitter<TeamSettingsState> emit,
  ) {
    final name = event.name.trim();
    if (name.isEmpty) return Future.value();
    return _change(
      emit,
      failure: '팀 이름을 바꾸지 못했어요.',
      apply: (settings) => settings.copyWith(name: name),
      revert: (settings, before) => settings.copyWith(name: before.name),
      request: () =>
          _teamRepository.updateTeam(teamId, UpdateTeamRequest(name: name)),
    );
  }

  Future<void> _onDescriptionChanged(
    TeamSettingsDescriptionChanged event,
    Emitter<TeamSettingsState> emit,
  ) {
    final description = event.description.trim();
    return _change(
      emit,
      failure: '팀 설명을 바꾸지 못했어요.',
      apply: (settings) => settings.copyWith(description: description),
      revert: (settings, before) =>
          settings.copyWith(description: before.description),
      request: () => _teamRepository.updateTeam(
        teamId,
        UpdateTeamRequest(description: description),
      ),
    );
  }

  Future<void> _onIconPicked(
    TeamSettingsIconPicked event,
    Emitter<TeamSettingsState> emit,
  ) async {
    final before = _settings;
    if (before == null || before.uploadingIcon) return;
    _emit(emit, before.copyWith(uploadingIcon: true));
    try {
      final iconUrl = await _teamRepository.uploadTeamIcon(teamId, event.path);
      final current = _settings;
      if (isClosed || current == null) return;
      _emit(emit, current.copyWith(iconUrl: iconUrl, uploadingIcon: false));
    } catch (e, s) {
      Logger.e('팀 아이콘 업로드 실패', tag: 'TeamSettings', error: e, stackTrace: s);
      final current = _settings;
      if (isClosed || current == null) return;
      _emit(
        emit,
        current.copyWith(uploadingIcon: false),
        error: failureMessageOf(e, '팀 아이콘을 바꾸지 못했어요.'),
      );
    }
  }

  Future<void> _onIconRemoved(
    TeamSettingsIconRemoved event,
    Emitter<TeamSettingsState> emit,
  ) {
    final before = _settings;
    // 올리는 중에 지우면 업로드가 끝나며 아이콘이 다시 생긴다. 화면도 그동안 잠근다.
    if (before == null || before.uploadingIcon || before.iconUrl == null) {
      return Future.value();
    }
    return _change(
      emit,
      failure: '팀 아이콘을 지우지 못했어요.',
      apply: (settings) => settings.copyWith(clearIcon: true),
      revert: (settings, before) => settings.copyWith(iconUrl: before.iconUrl),
      request: () => _teamRepository.removeTeamIcon(teamId),
    );
  }

  /// [apply] 한 설정을 먼저 보이고 [request] 를 보낸다. 실패하면 [revert] 로 그 값만
  /// 되돌리고 [failure] 를 알린다.
  Future<void> _change(
    Emitter<TeamSettingsState> emit, {
    required String failure,
    required TeamSettings Function(TeamSettings settings) apply,
    required TeamSettings Function(TeamSettings settings, TeamSettings before)
    revert,
    required Future<Object?> Function() request,
  }) async {
    final before = _settings;
    if (before == null) return;
    _emit(emit, apply(before));
    try {
      await request();
    } catch (e, s) {
      Logger.e('팀 설정 변경 실패', tag: 'TeamSettings', error: e, stackTrace: s);
      if (isClosed) return;
      final current = _settings;
      if (current == null) return;
      _emit(emit, revert(current, before), error: failureMessageOf(e, failure));
    }
  }

  TeamSettings? get _settings => switch (state) {
    AsyncSuccess<TeamSettingsData>(:final data) => data.settings,
    _ => null,
  };

  /// [error] 가 있으면 같은 사유로 연달아 실패해도 화면이 매번 알리게 사유 없는 상태를
  /// 먼저 낸다(같은 상태는 무시되므로).
  void _emit(
    Emitter<TeamSettingsState> emit,
    TeamSettings settings, {
    String? error,
  }) {
    final data = TeamSettingsData(settings: settings);
    if (error != null) emit(TeamSettingsState.success(data));
    emit(
      TeamSettingsState.success(error == null ? data : data.withError(error)),
    );
  }
}
