import 'package:cowork_app/feature/setting/domain/enums/setting_toggle_enum.dart';
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/utils/async_state.dart';
import '../../../../../core/utils/logger.dart';
import '../../../../../network/http_error_message.dart';
import '../../../../profile/data/repositories/profile_repository.dart';
import '../../../data/account_preference.dart';
import '../../../data/preference_repository.dart';
import '../../../data/push_repository.dart';
import '../../../domain/enums/notification_level.dart';
import '../../../domain/setting.dart';

part 'settings_event.dart';
part 'settings_state.dart';

/// 설정 화면 상태를 관리하는 Bloc.
///
/// 알림 토글은 preference 서비스의 `notification_level` 에 저장하고, 푸시를 켜고
/// 끌 때 이 기기를 notification 서비스에 등록·해제한다. 토글은 먼저 바꿔 보여 주고
/// 저장이 실패하면 되돌린다.
class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  SettingsBloc({
    required ProfileRepository profile,
    required PreferenceRepository preference,
    required PushRepository push,
  }) : _profile = profile,
       _preferences = preference,
       _push = push,
       super(const SettingsState.initial()) {
    on<SettingsRequested>(_onLoad);
    on<SettingsToggled>(_onToggle);
  }

  final ProfileRepository _profile;
  final PreferenceRepository _preferences;
  final PushRepository _push;

  /// 설정 경로의 계정 id. `/users/me` 에서 얻는다.
  late int _accountId;

  /// 마지막으로 서버와 맞춘 계정 설정. 저장할 때 이걸 바탕으로 바꾼 필드만 덮는다.
  late AccountPreference _preference;

  Future<void> _onLoad(
    SettingsRequested event,
    Emitter<SettingsState> emit,
  ) async {
    emit(const SettingsState.loading());
    try {
      final id = (await _profile.fetchMe()).id;
      if (id == null) throw StateError('내 프로필 응답에 id 가 없다');
      _preference = await _preferences.fetchAccount(id);
      _accountId = id;
      emit(
        SettingsState.success(
          SettingsData(
            Settings(
              linkedAccount: 'DataGSM',
              notificationLevel: _preference.notificationLevel,
              commitStreakPublic: true,
              version: '1.0.0',
            ),
          ),
        ),
      );
    } catch (e, s) {
      Logger.e('설정 조회 실패', tag: 'Settings', error: e, stackTrace: s);
      emit(
        SettingsState.failure(e is DioException ? dioErrorMessage(e) : null),
      );
    }
  }

  Future<void> _onToggle(
    SettingsToggled event,
    Emitter<SettingsState> emit,
  ) async {
    final state = this.state;
    if (state is! AsyncSuccess<SettingsData> || state.data.saving) return;
    final current = state.data.settings;

    switch (event.toggle) {
      case SettingsToggle.commitStreakPublic:
        // 로컬로만 반영. preference·user 서비스에 공개 여부 필드가 없다.
        emit(
          SettingsState.success(
            SettingsData(current.copyWith(commitStreakPublic: event.value)),
          ),
        );
      case SettingsToggle.pushNotification:
        // 다시 켤 때는 끄기 전 수준(ALL/MENTIONS)이 남아 있지 않아 멘션으로 켠다.
        await _save(
          current,
          event.value ? NotificationLevel.mentions : NotificationLevel.none,
          emit,
        );
      case SettingsToggle.mentionOnly:
        // 푸시가 꺼져 있으면 화면이 토글을 막는다. 이벤트가 와도 무시한다.
        if (!current.pushNotification) return;
        await _save(
          current,
          event.value ? NotificationLevel.mentions : NotificationLevel.all,
          emit,
        );
    }
  }

  /// [level] 로 바꿔 보여 주고 저장한다. 실패하면 [current] 로 되돌린다.
  ///
  /// 켤 때는 기기 등록 → 수준 저장, 끌 때는 수준 저장 → 기기 해제 순서다.
  /// 서버는 푸시를 보낼 때 계정 수준이 아니라 기기 등록 여부(와 채널 설정)를 본다.
  /// 그래서 켜다가 수준 저장이 실패하면, 토글만 되돌리지 않고 이번에 등록한 기기도
  /// 해제한다. 남겨 두면 토글은 꺼져 있는데 푸시가 온다.
  Future<void> _save(
    Settings current,
    NotificationLevel level,
    Emitter<SettingsState> emit,
  ) async {
    final turningOn = !current.pushNotification && level.pushEnabled;
    final turningOff = current.pushNotification && !level.pushEnabled;

    emit(
      SettingsState.success(
        SettingsData(current.copyWith(notificationLevel: level), saving: true),
      ),
    );

    void rollback(String message) =>
        emit(SettingsState.success(SettingsData(current, saveError: message)));

    var registered = false;
    try {
      if (turningOn) {
        if (!await _push.enable()) {
          return rollback('알림 권한이 꺼져 있어요. 기기 설정에서 허용해 주세요.');
        }
        registered = true;
      }
      _preference = await _preferences.updateAccount(
        _accountId,
        _preference.withNotificationLevel(level),
      );
      if (turningOff) await _disablePush();
      emit(
        SettingsState.success(
          SettingsData(
            current.copyWith(notificationLevel: _preference.notificationLevel),
          ),
        ),
      );
    } catch (e, s) {
      Logger.e('알림 설정 저장 실패', tag: 'Settings', error: e, stackTrace: s);
      if (registered) await _disablePush();
      rollback(switch (e) {
        PushUnavailableException() => '이 빌드에서는 푸시 알림을 쓸 수 없어요.',
        DioException() => dioErrorMessage(e),
        _ => '설정을 저장하지 못했어요.',
      });
    }
  }

  /// 기기 해제. 실패해도 로그만 남기고 토글 결과는 바꾸지 않는다.
  Future<void> _disablePush() async {
    try {
      await _push.disable();
    } catch (e, s) {
      Logger.e('푸시 기기 해제 실패', tag: 'Settings', error: e, stackTrace: s);
    }
  }
}
