import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/profile_store.dart';
import '../../domain/edit_profile.dart';

part 'edit_profile_event.dart';
part 'edit_profile_state.dart';

/// 프로필 편집 화면 상태를 관리하는 Bloc.
///
/// 현재 값은 로컬 저장소([ProfileStore])에서 읽고, 저장 시 다시 쓴다.
/// 실제 API 연동 시 [_onLoad]/[_onSubmit] 내부만 교체하면 된다.
class EditProfileBloc extends Bloc<EditProfileEvent, EditProfileState> {
  EditProfileBloc() : super(const EditProfileState.initial()) {
    on<EditProfileRequested>(_onLoad);
    on<EditProfileSubmitted>(_onSubmit);
  }

  Future<void> _onLoad(
    EditProfileRequested event,
    Emitter<EditProfileState> emit,
  ) async {
    emit(const EditProfileState.loading());
    try {
      final store = ProfileStore.instance;
      final profile = EditProfile(
        name: store.name,
        username: store.username,
        statusMessage: store.statusMessage,
        bio: store.bio,
        avatarUrl: store.avatarUrl,
        avatarInitial: store.avatarInitial,
        localAvatarPath: store.localAvatarPath,
      );
      emit(EditProfileState.success(profile));
    } catch (_) {
      emit(const EditProfileState.failure());
    }
  }

  void _onSubmit(EditProfileSubmitted event, Emitter<EditProfileState> emit) {
    // ponytail: 로컬 저장소에 반영. 실제 저장 API 연동 시 이 부분만 교체.
    final store = ProfileStore.instance
      ..name = event.name
      ..username = event.username
      ..statusMessage = event.statusMessage
      ..bio = event.bio
      ..localAvatarPath = event.localAvatarPath;

    emit(
      EditProfileState.success(
        EditProfile(
          name: store.name,
          username: store.username,
          statusMessage: store.statusMessage,
          bio: store.bio,
          avatarUrl: store.avatarUrl,
          avatarInitial: store.avatarInitial,
          localAvatarPath: store.localAvatarPath,
        ),
      ),
    );
  }
}
