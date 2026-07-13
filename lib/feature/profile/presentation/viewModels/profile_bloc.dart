import 'package:cowork_design_system/design_system.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/profile_store.dart';
import '../../domain/profile.dart';

part 'profile_event.dart';
part 'profile_state.dart';

/// 프로필 화면 상태를 관리하는 Bloc.
///
/// 현재는 목(mock) 데이터를 반환한다. 실제 API 연동 시 [_onLoad] 내부만 교체하면 된다.
class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc() : super(const ProfileState.initial()) {
    on<ProfileRequested>(_onLoad);
  }

  Future<void> _onLoad(
    ProfileRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(const ProfileState.loading());
    try {
      // ponytail: 이름/사용자명/사진은 로컬 저장소에서, 나머지는 목 데이터.
      // 실제 프로필 API 연동 시 이 부분만 교체.
      final store = ProfileStore.instance;
      final profile = Profile(
        name: store.name,
        avatarUrl: store.avatarUrl,
        localAvatarPath: store.localAvatarPath,
        subtitle: '${store.username} · 프론트엔드 개발자',
        badges: const [
          ProfileBadge(label: 'OWNER', color: CoworkBadgeColor.brand),
          ProfileBadge(label: '프론트엔드'),
        ],
        metaChips: const [
          'GSM 3학년 1반',
          'GitHub @joon_hyeok0204',
          'DataGSM 연동됨',
        ],
        streak: const GithubStreak(rangeLabel: '최근 20주 · 노출 ON'),
      );
      emit(ProfileState.success(profile));
    } catch (_) {
      emit(const ProfileState.failure());
    }
  }
}
