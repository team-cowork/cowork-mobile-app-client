import 'package:equatable/equatable.dart';

/// 프로필 편집 화면에서 사용하는 도메인 모델.
///
/// 편집 폼의 초기값을 담는다. 저장 시 이 값을 서버로 보낸다.
class EditProfile extends Equatable {
  const EditProfile({
    required this.name,
    required this.username,
    required this.statusMessage,
    required this.bio,
    required this.avatarInitial,
  });

  /// 표시할 이름.
  final String name;

  /// 사용자명 (예: @junjuny0227).
  final String username;

  /// 상태 메시지 (예: PR 리뷰 환영 🙌).
  final String statusMessage;

  /// 자기소개.
  final String bio;

  /// 아바타 폴백에 표시할 이니셜 (예: 준).
  final String avatarInitial;

  @override
  List<Object?> get props => [name, username, statusMessage, bio, avatarInitial];
}
