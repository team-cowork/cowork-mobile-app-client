import 'package:cowork_design_system/design_system.dart';
import 'package:equatable/equatable.dart';

import '../data/user_response.dart';
import 'enums/user_status.dart';

/// 값이 있는 문자열만 통과시킨다. 서버는 nullable 필드를 null 로도, 빈 문자열로도
/// 내려주기 때문에 둘 다 "없음"으로 본다.
String? _text(Object? value) =>
    value is String && value.isNotEmpty ? value : null;

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
    this.status = UserStatus.offline,
    this.localAvatarPath,
  });

  /// `GET /users/me` 응답을 프로필 화면 모델로 바꾼다.
  ///
  /// nullable 필드가 많고 빈 문자열도 내려오므로, 값이 있는 것만 골라 넣는다.
  factory Profile.fromMe(
    UserResponse me, {
    String? localAvatarPath,
    Map<DateTime, int> commitsByDay = const {},
  }) {
    final nickname = _text(me.nickname);
    final specialty = _text(me.specialty);
    final githubId = _text(me.githubId);
    final studentNumber = _text(me.studentNumber);
    final major = _text(me.major);
    final roles = me.roles;

    return Profile(
      name: _text(me.name) ?? '',
      avatarUrl: _text(me.profileImageUrl) ?? '',
      localAvatarPath: localAvatarPath,
      status: UserStatus.from(me.status),
      subtitle: [
        if (nickname != null) '@$nickname',
        if (specialty != null) specialty,
      ].join(' · '),
      // 첫 역할만 브랜드 색이다. 전부 강조하면 강조가 아니게 된다.
      badges: [
        for (final (index, role) in roles.indexed)
          ProfileBadge(
            label: role,
            color: index == 0
                ? CoworkBadgeColor.brand
                : CoworkBadgeColor.neutral,
          ),
      ],
      metaChips: [
        if (studentNumber != null) studentNumber,
        if (major != null) major,
        if (githubId != null) 'GitHub @$githubId',
      ],
      // GitHub ID 는 DataGSM 계정에 딸려 오므로 앱에서 등록할 수단이 없다.
      // 없으면 히트맵 대신 어디서 등록하는지 알려 준다.
      streak: githubId == null
          ? const GithubStreak(
              rangeLabel: '',
              notice: 'DataGSM에 접속해 GitHub ID를 등록해 주세요.',
            )
          : GithubStreak(
              rangeLabel: '최근 ${GithubStreak.weeks}주',
              commitsByDay: commitsByDay,
            ),
    );
  }

  /// 이름 (예: 김준혁).
  final String name;

  /// 아바타 이미지 URL.
  final String avatarUrl;

  /// 로컬에서 선택한 아바타 사진 경로. 있으면 [avatarUrl]보다 우선한다.
  final String? localAvatarPath;

  /// 접속 상태. 아바타 오른쪽 아래 점 색으로 나타난다.
  final UserStatus status;

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
    status,
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
  const GithubStreak({
    required this.rangeLabel,
    this.commitsByDay = const {},
    this.notice,
  });

  /// 히트맵이 보여주는 주 수. GitHub 공개 이벤트가 90일치라 그 안쪽으로 잡는다.
  static const int weeks = 13;

  /// 히트맵 상단 라벨 (예: 최근 13주).
  final String rangeLabel;

  /// 날짜(자정 기준)별 커밋 수. 없는 날은 키가 없다.
  final Map<DateTime, int> commitsByDay;

  /// 히트맵 대신 보여줄 안내. GitHub ID 가 없어 가져올 게 없을 때 쓴다.
  final String? notice;

  @override
  List<Object?> get props => [rangeLabel, commitsByDay, notice];
}
