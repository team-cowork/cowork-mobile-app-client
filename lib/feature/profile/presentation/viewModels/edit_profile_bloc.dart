import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/edit_profile.dart';

part 'edit_profile_event.dart';
part 'edit_profile_state.dart';

/// 프로필 편집 화면 상태를 관리하는 Bloc.
///
/// 현재는 목(mock) 데이터를 반환한다. 실제 API 연동 시 [_onLoad] 내부만 교체하면 된다.
class EditProfileBloc extends Bloc<EditProfileEvent, EditProfileState> {
  EditProfileBloc() : super(const EditProfileState.initial()) {
    on<EditProfileRequested>(_onLoad);
  }

  Future<void> _onLoad(
    EditProfileRequested event,
    Emitter<EditProfileState> emit,
  ) async {
    emit(const EditProfileState.loading());
    try {
      // ponytail: 목 데이터. 실제 프로필 조회 API 연동 시 이 부분만 교체.
      const profile = EditProfile(
        name: '',
        username: '@junjuny0227',
        statusMessage: '',
        bio: '백엔드 개발자 · GSM 2학년 3반. 실서비스 트러블슈팅을 좋아합니다.',
        avatarInitial: '준',
      );
      emit(const EditProfileState.success(profile));
    } catch (_) {
      emit(const EditProfileState.failure());
    }
  }
}
