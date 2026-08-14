/// `/users/*` 응답 본문.
///
/// 조회·수정·상태 변경이 모두 같은 사용자 표현을 돌려주므로 응답 모델은 하나다.
/// 게이트웨이 envelope 을 벗긴 `data` 를 받는다(`unwrapPayload`).
///
/// 서버가 값 없음을 null 로도, 빈 문자열로도 내려주기 때문에 여기서는 받은 그대로
/// 담고, "없음"으로 볼지는 화면 모델이 정한다.
class UserResponse {
  const UserResponse({
    this.id,
    this.name,
    this.email,
    this.nickname,
    this.status,
    this.statusMessage,
    this.statusExpiresAt,
    this.description,
    this.accountDescription,
    this.specialty,
    this.major,
    this.studentNumber,
    this.studentRole,
    this.githubId,
    this.profileImageUrl,
    this.sex,
    this.roles = const [],
  });

  factory UserResponse.fromJson(Map<String, dynamic> json) => UserResponse(
    id: json['id'] as int?,
    name: json['name'] as String?,
    email: json['email'] as String?,
    nickname: json['nickname'] as String?,
    status: json['status'] as String?,
    statusMessage: json['status_message'] as String?,
    statusExpiresAt: json['status_expires_at'] as String?,
    description: json['description'] as String?,
    accountDescription: json['account_description'] as String?,
    specialty: json['specialty'] as String?,
    major: json['major'] as String?,
    studentNumber: json['student_number'] as String?,
    studentRole: json['student_role'] as String?,
    githubId: json['github_id'] as String?,
    profileImageUrl: json['profile_image_url'] as String?,
    sex: json['sex'] as String?,
    roles: (json['roles'] as List?)?.whereType<String>().toList() ?? const [],
  );

  /// 사용자 id. 회의록 소유 판별에 쓴다.
  final int? id;

  final String? name;
  final String? email;
  final String? nickname;

  /// 접속 상태. 서버가 `offline` 처럼 소문자로 내려준다.
  final String? status;

  final String? statusMessage;

  /// 상태 만료 시각(ISO8601). 아직 화면에서 쓰지 않아 문자열 그대로 둔다.
  final String? statusExpiresAt;

  /// 자기소개.
  final String? description;

  /// 계정 설명. `description` 과 별개 필드다.
  final String? accountDescription;

  /// 직군 (예: 프론트엔드 개발자).
  final String? specialty;

  final String? major;

  /// 학번 코드 (예: 3413).
  final String? studentNumber;

  final String? studentRole;
  final String? githubId;
  final String? profileImageUrl;
  final String? sex;

  /// 역할 목록. 없으면 빈 배열로 온다.
  final List<String> roles;
}

/// `POST /users/me/profile-image/presigned` 응답.
///
/// [uploadUrl] 은 스토리지로 바로 가는 절대 URL 이고, [objectKey] 는 업로드 뒤
/// confirm 에 되돌려 보낼 값이다.
class PresignedUploadResponse {
  const PresignedUploadResponse({
    required this.objectKey,
    required this.uploadUrl,
  });

  /// 둘 중 하나라도 비면 던진다. 빈 URL 로 올리면 업로드가 스토리지가 아니라
  /// API 게이트웨이로 날아가고, 실패가 한참 뒤에야 엉뚱한 모습으로 드러난다.
  factory PresignedUploadResponse.fromJson(Map<String, dynamic> json) {
    final objectKey = json['object_key'] as String?;
    final uploadUrl = json['upload_url'] as String?;
    if (objectKey == null ||
        objectKey.isEmpty ||
        uploadUrl == null ||
        uploadUrl.isEmpty) {
      throw const FormatException(
        'presigned 응답에 object_key/upload_url 이 없습니다.',
      );
    }
    return PresignedUploadResponse(objectKey: objectKey, uploadUrl: uploadUrl);
  }

  final String objectKey;
  final String uploadUrl;
}
