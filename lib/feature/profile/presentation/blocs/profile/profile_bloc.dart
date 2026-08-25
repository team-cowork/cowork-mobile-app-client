import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/utils/async_state.dart';
import '../../../../../core/utils/logger.dart';
import '../../../../../network/http_error_message.dart';
import '../../../data/github_repository.dart';
import '../../../data/profile_repository.dart';
import '../../../data/profile_store.dart';
import '../../../domain/profile.dart';

part 'profile_event.dart';
part 'profile_state.dart';

/// 프로필 화면 상태를 관리하는 Bloc.
class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc(this._repository, this._github)
    : super(const ProfileState.initial()) {
    on<ProfileRequested>(_onLoad);
  }

  final ProfileRepository _repository;
  final GithubRepository _github;

  Future<void> _onLoad(
    ProfileRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(const ProfileState.loading());
    try {
      final me = await _repository.fetchMe();
      final githubId = me.githubId;
      emit(
        ProfileState.success(
          Profile.fromMe(
            me,
            // 업로드에 실패해 서버에 못 올라간 사진이 있으면 그걸 먼저 보여준다.
            localAvatarPath: ProfileStore.instance.localAvatarPath,
            // ponytail: 프로필 뒤에 순서대로 부른다. 스트릭이 늦으면 화면 전체가
            // 그만큼 늦는다. 눈에 띄면 프로필만 먼저 띄우고 스트릭을 나중에 얹는다.
            commitsByDay: githubId == null || githubId.isEmpty
                ? const {}
                : await _github.commitsByDay(githubId),
          ),
        ),
      );
    } catch (e, s) {
      Logger.e('프로필 조회 실패', tag: 'Profile', error: e, stackTrace: s);
      emit(ProfileState.failure(e is DioException ? dioErrorMessage(e) : null));
    }
  }
}
