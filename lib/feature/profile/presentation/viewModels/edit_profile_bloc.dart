import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/async_state.dart';
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
  /// ponytail: 화면은 저장을 누른 즉시 닫히므로 실패해도 화면에 뜨지 않는다.
  /// 다만 프로필 화면이 돌아오면서 서버 값을 다시 읽어 오므로 저장이 안 된 건
  /// 그 자리에서 드러난다. 실패 문구까지 띄우려면 저장 결과를 기다렸다 닫아야 한다.
  Future<void> _onSubmit(
    EditProfileSubmitted event,
    Emitter<EditProfileState> emit,
  ) async {
    final store = ProfileStore.instance..localAvatarPath = event.localAvatarPath;
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
    } catch (_) {
      emit(const EditProfileState.failure());
    }
  }
}
