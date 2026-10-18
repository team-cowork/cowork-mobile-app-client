import 'package:equatable/equatable.dart';

import '../data/user_response.dart';

/// 프로필 편집 화면에서 사용하는 도메인 모델.
///
/// 편집 폼의 초기값을 담는다. 저장 시 이 값을 서버로 보낸다. 상태와 상태 메시지는
/// 상태 설정 시트가 따로 다룬다.
class EditProfile extends Equatable {
  const EditProfile({
    required this.name,
    required this.username,
    required this.bio,
    required this.avatarUrl,
    required this.avatarInitial,
    this.localAvatarPath,
  });

  /// `GET /users/me` 응답을 편집 폼 초기값으로 바꾼다.
  factory EditProfile.fromMe(UserResponse me, {String? localAvatarPath}) {
    final name = me.name ?? '';
    return EditProfile(
      name: name,
      username: me.nickname ?? '',
      bio: me.description ?? '',
      avatarUrl: me.profileImageUrl ?? '',
      avatarInitial: name.isEmpty ? '?' : name.substring(0, 1),
      localAvatarPath: localAvatarPath,
    );
  }

  /// 표시할 이름.
  final String name;

  /// 사용자명 (예: @junjuny0227).
  final String username;

  /// 자기소개.
  final String bio;

  /// 현재 아바타 이미지 URL. 프로필 화면과 동일한 사진을 표시한다.
  final String avatarUrl;

  /// 아바타 이미지 로드 실패 시 폴백으로 표시할 이니셜 (예: 준).
  final String avatarInitial;

  /// 로컬에서 선택한 아바타 사진 경로. 있으면 [avatarUrl]보다 우선한다.
  final String? localAvatarPath;

  @override
  List<Object?> get props => [
    name,
    username,
    bio,
    avatarUrl,
    avatarInitial,
    localAvatarPath,
  ];
}
