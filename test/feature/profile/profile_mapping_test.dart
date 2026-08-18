import 'package:cowork_app/feature/profile/data/profile_store.dart';
import 'package:cowork_app/feature/profile/data/user_response.dart';
import 'package:cowork_app/feature/profile/domain/edit_profile.dart';
import 'package:cowork_app/feature/profile/domain/enums/user_status.dart';
import 'package:cowork_app/feature/profile/domain/profile.dart';
import 'package:cowork_design_system/design_system.dart';
import 'package:flutter_test/flutter_test.dart';

/// `GET /users/me` 응답 예시. name/status/email/sex 외에는 전부 nullable 이다.
const _me = {
  'id': 7,
  'name': '김준혁',
  'status': 'ONLINE',
  'email': 'joon@gsm.hs.kr',
  'sex': 'MALE',
  'nickname': 'joon_hyeok0204',
  'specialty': '프론트엔드 개발자',
  'description': '실서비스 트러블슈팅을 좋아합니다.',
  'status_message': 'PR 리뷰 환영',
  'student_number': 'GSM 3학년 1반',
  'major': '소프트웨어개발과',
  'github_id': 'joon',
  'profile_image_url': 'https://cdn.test/a.png',
  'roles': ['OWNER', '프론트엔드'],
};

void main() {
  test('응답 모델이 스네이크 케이스 필드를 그대로 읽는다', () {
    // 개발 서버 실제 응답. null 과 빈 배열이 섞여 온다.
    final user = UserResponse.fromJson(const {
      'id': 211,
      'major': 'AI',
      'name': '이주언',
      'status': 'offline',
      'description': null,
      'email': 's24068@gsm.hs.kr',
      'nickname': 'leejueon',
      'sex': 'MAN',
      'specialty': null,
      'status_expires_at': null,
      'status_message': null,
      'student_number': '3413',
      'student_role': 'GENERAL_STUDENT',
      'account_description': null,
      'github_id': null,
      'profile_image_url': null,
      'roles': <String>[],
    });

    expect(user.id, 211);
    expect(user.name, '이주언');
    expect(user.studentNumber, '3413');
    expect(user.statusMessage, isNull);
    expect(user.roles, isEmpty);
  });

  test('roles 키가 없어도 빈 배열이다', () {
    // 없음을 null 로 주는 서버라 목록 필드는 여기서 막아야 화면이 안 깨진다.
    expect(UserResponse.fromJson(const {}).roles, isEmpty);
  });

  test('프로필 화면 모델로 옮긴다', () {
    final profile = Profile.fromMe(UserResponse.fromJson(_me));

    expect(profile.name, '김준혁');
    expect(profile.avatarUrl, 'https://cdn.test/a.png');
    expect(profile.subtitle, '@joon_hyeok0204 · 프론트엔드 개발자');
    expect(profile.badges.map((b) => b.label), ['OWNER', '프론트엔드']);
    expect(profile.badges.first.color, CoworkBadgeColor.brand);
    expect(profile.badges.last.color, CoworkBadgeColor.neutral);
    expect(profile.metaChips, ['GSM 3학년 1반', '소프트웨어개발과', 'GitHub @joon']);
  });

  test('접속 상태는 대소문자를 가리지 않고, 모르는 값은 offline 이다', () {
    // 서버가 `ONLINE` 도 `offline` 도 준다. 모를 때 초록으로 켜 두면 안 된다.
    UserStatus statusOf(String? raw) =>
        Profile.fromMe(UserResponse.fromJson({'status': raw})).status;

    expect(statusOf('ONLINE'), UserStatus.online);
    expect(statusOf('offline'), UserStatus.offline);
    expect(statusOf('DO_NOT_DISTURB'), UserStatus.doNotDisturb);
    expect(statusOf('처음 보는 값'), UserStatus.offline);
    expect(statusOf(null), UserStatus.offline);
  });

  test('nullable 필드가 비어도 화면이 깨지지 않는다', () {
    // 빈 문자열도 null 과 같이 "없음"으로 본다. 서버가 둘 다 내려준다.
    final profile = Profile.fromMe(
      UserResponse.fromJson(const {
        'name': '김준혁',
        'nickname': null,
        'specialty': '',
        'profile_image_url': null,
        'roles': <String>[],
      }),
    );

    expect(profile.subtitle, isEmpty);
    expect(profile.avatarUrl, isEmpty, reason: '빈 URL 이어야 이니셜 폴백이 뜬다');
    expect(profile.badges, isEmpty);
    expect(profile.metaChips, isEmpty);
  });

  test('편집 폼 초기값으로 옮긴다', () {
    final edit = EditProfile.fromMe(
      UserResponse.fromJson(_me),
      localAvatarPath: '/tmp/a.jpg',
    );

    expect(edit.name, '김준혁');
    expect(edit.username, 'joon_hyeok0204', reason: '@ 없이 서버 값 그대로 보낸다');
    expect(edit.bio, '실서비스 트러블슈팅을 좋아합니다.');
    expect(edit.statusMessage, 'PR 리뷰 환영');
    expect(edit.status, 'ONLINE', reason: '상태 메시지 변경 시 되돌려 보내야 한다');
    expect(edit.avatarInitial, '김');
    expect(edit.localAvatarPath, '/tmp/a.jpg');
  });

  test('이름이 비면 이니셜 폴백은 물음표다', () {
    expect(
      EditProfile.fromMe(UserResponse.fromJson(const {})).avatarInitial,
      '?',
    );
  });

  test('회의록 작성자 기본값은 목 값으로 남아 있다', () {
    // 프로필을 한 번도 안 불렀을 때 회의록 작성자가 빈칸이 되지 않는지.
    expect(ProfileStore.instance.name, isNotEmpty);
    expect(ProfileStore.instance.avatarInitial, isNotEmpty);
  });
}
