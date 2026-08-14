import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/utils/async_state.dart';
import '../../../../core/utils/logger.dart';
import '../../../../network/http_error_message.dart';
import '../../data/profile_repository.dart';
import '../../data/profile_store.dart';
import '../../domain/profile.dart';

part 'profile_event.dart';

/// 프로필 화면 상태. 성공 시 [Profile]을 담는다.
typedef ProfileState = AsyncState<Profile>;

/// 프로필 화면 상태를 관리하는 Bloc.
class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc(this._repository) : super(const ProfileState.initial()) {
    on<ProfileRequested>(_onLoad);
  }

  final ProfileRepository _repository;

  Future<void> _onLoad(
    ProfileRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(const ProfileState.loading());
    try {
      emit(
        ProfileState.success(
          Profile.fromMe(
            await _repository.fetchMe(),
            // 업로드에 실패해 서버에 못 올라간 사진이 있으면 그걸 먼저 보여준다.
            localAvatarPath: ProfileStore.instance.localAvatarPath,
          ),
        ),
      );
    } catch (e, s) {
      Logger.e('프로필 조회 실패', tag: 'Profile', error: e, stackTrace: s);
      emit(ProfileState.failure(e is DioException ? dioErrorMessage(e) : null));
    }
  }
}
