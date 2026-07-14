import 'package:cowork_design_system/design_system.dart';
import 'package:equatable/equatable.dart';

/// 프로필 화면에서 사용하는 도메인 모델.
///
/// UI 색상 등은 위젯 쪽에서 매핑한다. 여기서는 표시할 데이터만 담는다.
class Profile extends Equatable {
  const Profile({
    required this.name,
    required this.avatarUrl,
    required this.subtitle,
    required this.badges,
    required this.metaChips,
    required this.streak,
    this.localAvatarPath,
  });

  /// 이름 (예: 김준혁).
  final String name;

  /// 아바타 이미지 URL.
  final String avatarUrl;

  /// 로컬에서 선택한 아바타 사진 경로. 있으면 [avatarUrl]보다 우선한다.
  final String? localAvatarPath;

  /// 이름 아래 한 줄 소개 (예: @joon_hyeok0204 · 프론트엔드 개발자).
  final String subtitle;

  /// 이름 옆 역할/직군 뱃지 목록.
  final List<ProfileBadge> badges;

  /// 학년/GitHub/DataGSM 연동 등 메타 정보 칩 라벨.
  final List<String> metaChips;

  /// GitHub 커밋 스트릭.
  final GithubStreak streak;

  @override
  List<Object?> get props => [
    name,
    avatarUrl,
    subtitle,
    badges,
    metaChips,
    streak,
    localAvatarPath,
  ];
}

/// 이름 옆에 붙는 역할/직군 뱃지.
class ProfileBadge extends Equatable {
  const ProfileBadge({
    required this.label,
    this.color = CoworkBadgeColor.neutral,
  });

  final String label;

  /// 라벨 색상. 기본값은 회색([CoworkBadgeColor.neutral]).
  final CoworkBadgeColor color;

  @override
  List<Object?> get props => [label, color];
}

/// GitHub 커밋 스트릭 정보.
class GithubStreak extends Equatable {
  const GithubStreak({required this.rangeLabel});

  /// 히트맵 상단 라벨 (예: 최근 20주 · 노출 ON).
  final String rangeLabel;

  // ponytail: 히트맵 셀 데이터는 실제 GitHub 연동 시 추가.

  @override
  List<Object?> get props => [rangeLabel];
}
