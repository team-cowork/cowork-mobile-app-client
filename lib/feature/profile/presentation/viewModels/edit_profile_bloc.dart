import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/async_state.dart';
import '../../../../core/utils/logger.dart';
import '../../../../network/http_error_message.dart';
import '../../data/profile_repository.dart';
import '../../data/profile_store.dart';
import '../../data/user_request.dart';
import '../../data/user_response.dart';
import '../../domain/edit_profile.dart';

part 'edit_profile_event.dart';

/// 프로필 편집 화면 상태. 성공 시 [EditProfile]을 담는다.
typedef EditProfileState = AsyncState<EditProfile>;

/// 프로필 편집 화면 상태를 관리하는 Bloc.
class EditProfileBloc extends Bloc<EditProfileEvent, EditProfileState> {
  EditProfileBloc(this._repository) : super(const EditProfileState.initial()) {
    on<EditProfileRequested>(_onLoad);
    on<EditProfileSubmitted>(_onSubmit);
  }

  final ProfileRepository _repository;

  Future<void> _onLoad(
    EditProfileRequested event,
    Emitter<EditProfileState> emit,
  ) async {
    emit(const EditProfileState.loading());
    try {
      emit(
        EditProfileState.success(
          EditProfile.fromMe(
            await _repository.fetchMe(),
            localAvatarPath: ProfileStore.instance.localAvatarPath,
          ),
        ),
      );
    } catch (_) {
      emit(const EditProfileState.failure());
    }
  }

  /// 저장. 이름·사용자명·자기소개는 `PATCH /users/me`, 상태 메시지는 전용
  /// 엔드포인트라 값이 바뀐 경우에만 한 번 더 부른다. 새로 고른 사진이 있으면
  /// 먼저 올린다. 그래야 뒤따르는 수정 응답에 새 사진 URL 이 실려 온다.
  ///
  /// 저장이 끝날 때까지 로딩을 내보낸다. 화면은 성공을 받고서야 닫히므로,
  /// 프로필 화면이 다시 읽는 시점엔 저장이 이미 서버에 반영돼 있다.
  Future<void> _onSubmit(
    EditProfileSubmitted event,
    Emitter<EditProfileState> emit,
  ) async {
    final store = ProfileStore.instance..localAvatarPath = event.localAvatarPath;
    emit(const EditProfileState.loading());
    try {
      final uploaded = event.localAvatarPath;
      if (uploaded != null) {
        await _repository.uploadProfileImage(uploaded);
        // 서버가 사진을 들고 있으니 로컬 경로는 버린다. 남겨 두면 다음 저장에서
        // 같은 파일을 또 올리고, 파일이 지워진 뒤엔 깨진 사진이 뜬다.
        store.localAvatarPath = null;
      } else if (event.removeAvatar) {
        await _repository.deleteProfileImage();
      }

      EditProfile toProfile(UserResponse me) =>
          EditProfile.fromMe(me, localAvatarPath: store.localAvatarPath);

      var profile = toProfile(
        await _repository.updateMe(
          UpdateMeRequest(
            name: event.name,
            nickname: event.username,
            description: event.bio,
          ),
        ),
      );
      if (event.statusMessage != profile.statusMessage) {
        profile = toProfile(
          await _repository.updateStatus(
            UpdateStatusRequest(
              status: profile.status,
              message: event.statusMessage.isEmpty ? null : event.statusMessage,
            ),
          ),
        );
      }
      emit(EditProfileState.success(profile));
    } catch (e, s) {
      // 어느 단계에서 엎어졌는지는 로그로만 남기고, 화면엔 사용자 문구만 준다.
      Logger.e('프로필 저장 실패', tag: 'Profile', error: e, stackTrace: s);
      emit(
        EditProfileState.failure(
          e is DioException ? dioErrorMessage(e) : '프로필을 저장하지 못했어요.',
        ),
      );
    }
  }
}
