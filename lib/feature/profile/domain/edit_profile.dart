import 'package:equatable/equatable.dart';

import '../data/user_response.dart';

/// 프로필 편집 화면에서 사용하는 도메인 모델.
///
/// 편집 폼의 초기값을 담는다. 저장 시 이 값을 서버로 보낸다.
class EditProfile extends Equatable {
  const EditProfile({
    required this.name,
    required this.username,
    required this.statusMessage,
    required this.bio,
    required this.avatarUrl,
    required this.avatarInitial,
    required this.customStatus,
    this.localAvatarPath,
  });

  /// `GET /users/me` 응답을 편집 폼 초기값으로 바꾼다.
  factory EditProfile.fromMe(UserResponse me, {String? localAvatarPath}) {
    final name = me.name ?? '';
    final custom = me.customStatus;
    final presence = me.status;
    return EditProfile(
      name: name,
      username: me.nickname ?? '',
      statusMessage: me.statusMessage ?? '',
      bio: me.description ?? '',
      avatarUrl: me.profileImageUrl ?? '',
      avatarInitial: name.isEmpty ? '?' : name.substring(0, 1),
      customStatus: custom != null && custom.isNotEmpty
          ? custom
          : presence != null && presence.isNotEmpty
          ? presence
          : 'online',
      localAvatarPath: localAvatarPath,
    );
  }

  /// 표시할 이름.
  final String name;

  /// 사용자명 (예: @junjuny0227).
  final String username;

  /// 상태 메시지 (예: PR 리뷰 환영 🙌).
  final String statusMessage;

  /// 자기소개.
  final String bio;

  /// 현재 아바타 이미지 URL. 프로필 화면과 동일한 사진을 표시한다.
  final String avatarUrl;

  /// 아바타 이미지 로드 실패 시 폴백으로 표시할 이니셜 (예: 준).
  final String avatarInitial;

  /// 로컬에서 선택한 아바타 사진 경로. 있으면 [avatarUrl]보다 우선한다.
  final String? localAvatarPath;

  /// 사용자가 고른 상태(예: DO_NOT_DISTURB). 화면에 보이진 않지만 상태 메시지를
  /// 바꿀 때 `PATCH /users/me/status` 가 custom_status 를 필수로 받아 그대로 되돌려
  /// 보내야 한다. 서버는 빈 값을 거부하므로, 고른 적 없으면 접속 상태(`status`)를
  /// 대신 보낸다. 그것도 없으면 `online` 이다.
  final String customStatus;

  @override
  List<Object?> get props => [
    name,
    username,
    statusMessage,
    bio,
    avatarUrl,
    avatarInitial,
    customStatus,
    localAvatarPath,
  ];
}
