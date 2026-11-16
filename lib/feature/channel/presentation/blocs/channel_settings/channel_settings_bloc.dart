import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/network/http_error_message.dart';
import '../../../../../core/utils/async_state.dart';
import '../../../../../core/utils/logger.dart';
import '../../../../chat/data/model/chat_message_mapping.dart';
import '../../../../chat/data/repositories/message_repository.dart';
import '../../../../profile/data/profile_store.dart';
import '../../../../profile/data/repositories/profile_repository.dart';
import '../../../../setting/data/preference_repository.dart';
import '../../../../setting/domain/enums/notification_level.dart';
import '../../../data/model/requests/update_channel_request.dart';
import '../../../data/repositories/channel_repository.dart';
import '../../../domain/channel_member.dart';
import '../../../domain/channel_notification.dart';
import '../../../domain/channel_settings.dart';

part 'channel_settings_event.dart';
part 'channel_settings_state.dart';

/// 채널 설정 화면 상태를 관리하는 Bloc.
///
/// 바꾸는 값은 먼저 화면에 반영하고 서버에 보낸다. 실패하면 그 값만 이전으로 되돌리고
/// 사유를 알린다. 그사이 다른 값이 바뀌었을 수 있어 통째로 되돌리지 않는다.
class ChannelSettingsBloc
    extends Bloc<ChannelSettingsEvent, ChannelSettingsState> {
  ChannelSettingsBloc({
    required this.channelId,
    required ChannelRepository channelRepository,
    required PreferenceRepository preferenceRepository,
    required ProfileRepository profileRepository,
    required MessageRepository messageRepository,
  }) : _channelRepository = channelRepository,
       _preferenceRepository = preferenceRepository,
       _profileRepository = profileRepository,
       _messageRepository = messageRepository,
       super(const ChannelSettingsState.initial()) {
    on<ChannelSettingsRequested>(_onLoad);
    on<ChannelSettingsNameChanged>(_onNameChanged);
    on<ChannelSettingsDescriptionChanged>(_onDescriptionChanged);
    on<ChannelSettingsPrivateToggled>(_onPrivateToggled);
    on<ChannelSettingsNotificationLevelChanged>(_onNotificationLevelChanged);
    on<ChannelSettingsMuteToggled>(_onMuteToggled);
  }

  final int channelId;
  final ChannelRepository _channelRepository;
  final PreferenceRepository _preferenceRepository;
  final ProfileRepository _profileRepository;
  final MessageRepository _messageRepository;

  /// 멤버 행에 겹쳐 보여 줄 최대 인원.
  static const _previewSize = 4;

  /// 음소거는 서버에 `muted_until` 로만 있어, 끄는 시각 없이 켜려면 아주 먼 시각을 넣는다.
  static final _mutedForever = DateTime.utc(9999);

  Future<void> _onLoad(
    ChannelSettingsRequested event,
    Emitter<ChannelSettingsState> emit,
  ) async {
    emit(const ChannelSettingsState.loading());
    try {
      final channelRequest = _channelRepository.fetchChannel(channelId);
      final membersRequest = _channelRepository.fetchMembers(channelId);
      final accountIdRequest = _accountId();
      // 셋은 같이 보내고, 하나라도 실패하면 그 예외를 그대로 받는다.
      await Future.wait([
        channelRequest,
        membersRequest,
        accountIdRequest,
      ], eagerError: true);
      final channel = await channelRequest;
      final members = await membersRequest;
      final notification = await _preferenceRepository.fetchChannelNotification(
        await accountIdRequest,
        channelId,
      );
      final previewIds = [
        for (final member in members.take(_previewSize)) member.userId,
      ];
      final names = await _fetchNames(previewIds);

      emit(
        ChannelSettingsState.success(
          ChannelSettingsData(
            settings: ChannelSettings(
              name: channel.name,
              description: channel.description ?? '',
              isPrivate: channel.isPrivate,
              notification: notification,
              memberPreview: [
                for (final id in previewIds)
                  ChannelMember(
                    profile: chatAuthorOf(id, names[id] ?? ''),
                    avatarColor: chatAvatarColorOf(id),
                  ),
              ],
              memberCount: members.length,
            ),
          ),
        ),
      );
    } catch (e, s) {
      Logger.e('채널 설정 조회 실패', tag: 'ChannelSettings', error: e, stackTrace: s);
      emit(
        ChannelSettingsState.failure(
          e is DioException ? dioErrorMessage(e) : null,
        ),
      );
    }
  }

  Future<void> _onNameChanged(
    ChannelSettingsNameChanged event,
    Emitter<ChannelSettingsState> emit,
  ) {
    final name = event.name.trim();
    if (name.isEmpty) return Future.value();
    return _change(
      emit,
      failure: '채널 이름을 바꾸지 못했어요.',
      apply: (settings) => settings.copyWith(name: name),
      revert: (settings, before) => settings.copyWith(name: before.name),
      request: () => _channelRepository.updateChannel(
        channelId,
        UpdateChannelRequest(name: name),
      ),
    );
  }

  Future<void> _onDescriptionChanged(
    ChannelSettingsDescriptionChanged event,
    Emitter<ChannelSettingsState> emit,
  ) {
    final description = event.description.trim();
    return _change(
      emit,
      failure: '채널 설명을 바꾸지 못했어요.',
      apply: (settings) => settings.copyWith(description: description),
      revert: (settings, before) =>
          settings.copyWith(description: before.description),
      request: () => _channelRepository.updateChannel(
        channelId,
        UpdateChannelRequest(description: description),
      ),
    );
  }

  Future<void> _onPrivateToggled(
    ChannelSettingsPrivateToggled event,
    Emitter<ChannelSettingsState> emit,
  ) => _change(
    emit,
    failure: '공개 범위를 바꾸지 못했어요.',
    apply: (settings) => settings.copyWith(isPrivate: event.value),
    revert: (settings, before) =>
        settings.copyWith(isPrivate: before.isPrivate),
    request: () => _channelRepository.updateChannel(
      channelId,
      UpdateChannelRequest(isPrivate: event.value),
    ),
  );

  Future<void> _onNotificationLevelChanged(
    ChannelSettingsNotificationLevelChanged event,
    Emitter<ChannelSettingsState> emit,
  ) => _changeNotification(
    emit,
    failure: '알림 설정을 바꾸지 못했어요.',
    change: (current) =>
        ChannelNotification(level: event.level, mutedUntil: current.mutedUntil),
  );

  Future<void> _onMuteToggled(
    ChannelSettingsMuteToggled event,
    Emitter<ChannelSettingsState> emit,
  ) => _changeNotification(
    emit,
    failure: '음소거를 바꾸지 못했어요.',
    change: (current) => ChannelNotification(
      level: current.level,
      mutedUntil: event.value ? _mutedForever : null,
    ),
  );

  /// 알림 설정은 서버가 통째로 교체하므로, 바꾸지 않은 값은 지금 값을 그대로 실어 보낸다.
  Future<void> _changeNotification(
    Emitter<ChannelSettingsState> emit, {
    required String failure,
    required ChannelNotification Function(ChannelNotification current) change,
  }) {
    final current = _settings;
    if (current == null) return Future.value();
    final next = change(current.notification);
    return _change(
      emit,
      failure: failure,
      apply: (settings) => settings.copyWith(notification: next),
      revert: (settings, before) =>
          settings.copyWith(notification: before.notification),
      request: () async => _preferenceRepository.updateChannelNotification(
        await _accountId(),
        channelId,
        next,
      ),
    );
  }

  /// [apply] 한 설정을 먼저 보이고 [request] 를 보낸다. 실패하면 [revert] 로 그 값만
  /// 되돌리고 [failure] 를 알린다.
  Future<void> _change(
    Emitter<ChannelSettingsState> emit, {
    required String failure,
    required ChannelSettings Function(ChannelSettings settings) apply,
    required ChannelSettings Function(
      ChannelSettings settings,
      ChannelSettings before,
    )
    revert,
    required Future<Object?> Function() request,
  }) async {
    final before = _settings;
    if (before == null) return;
    _emit(emit, apply(before));
    try {
      await request();
    } catch (e, s) {
      Logger.e('채널 설정 변경 실패', tag: 'ChannelSettings', error: e, stackTrace: s);
      if (isClosed) return;
      final current = _settings;
      if (current == null) return;
      _emit(
        emit,
        revert(current, before),
        error: e is DioException ? dioErrorMessage(e) : failure,
      );
    }
  }

  ChannelSettings? get _settings => switch (state) {
    AsyncSuccess<ChannelSettingsData>(:final data) => data.settings,
    _ => null,
  };

  /// [error] 가 있으면 같은 사유로 연달아 실패해도 화면이 매번 알리게 사유 없는 상태를
  /// 먼저 낸다(같은 상태는 무시되므로).
  void _emit(
    Emitter<ChannelSettingsState> emit,
    ChannelSettings settings, {
    String? error,
  }) {
    final data = ChannelSettingsData(settings: settings);
    if (error != null) emit(ChannelSettingsState.success(data));
    emit(
      ChannelSettingsState.success(
        error == null ? data : data.withError(error),
      ),
    );
  }

  /// 내 계정 id. 로그인 직후 아직 못 읽었으면 한 번 읽는다.
  Future<int> _accountId() async {
    final cached = ProfileStore.instance.currentUserId;
    if (cached != null) return cached;
    final id = (await _profileRepository.fetchMe()).id;
    if (id == null) throw StateError('내 계정 id 를 알 수 없다');
    return id;
  }

  /// 사용자 id → 표시 이름. 못 읽으면 빈 맵이라 `알 수 없음` 으로 보인다.
  Future<Map<int, String>> _fetchNames(List<int> userIds) async {
    if (userIds.isEmpty) return const {};
    try {
      return {
        for (final user in await _messageRepository.fetchDisplayNames(userIds))
          user.id: user.nickname?.isNotEmpty == true
              ? user.nickname!
              : user.name,
      };
    } catch (e, s) {
      Logger.e(
        '채널 설정 멤버 이름 조회 실패',
        tag: 'ChannelSettings',
        error: e,
        stackTrace: s,
      );
      return const {};
    }
  }
}
